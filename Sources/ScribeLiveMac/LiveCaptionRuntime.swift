import Foundation
import SwiftUI
import ScribeCore
import AudioInput
import SpeechPipeline

@MainActor
final class LiveCaptionRuntime: ObservableObject {
    @Published private(set) var lines: [CaptionLine] = []
    @Published private(set) var isRunning = false
    @Published private(set) var statusMessage = "Ready"

    private let permissions = PermissionManager()
    private var microphone: MicrophoneInputSource?
    private let recognizer = AppleSpeechRecognizer()
    private let sessionID = UUID()

    func start() async {
        guard !isRunning else {
            return
        }

        statusMessage = "Requesting permissions"
        await permissions.requestAll()

        guard permissions.microphoneAuthorized else {
            statusMessage = "Microphone permission denied"
            return
        }

        guard permissions.speechAuthorized else {
            statusMessage = "Speech recognition permission denied"
            return
        }

        let microphone = MicrophoneInputSource()
        self.microphone = microphone

        do {
            statusMessage = "Starting microphone"
            try await microphone.start()
            isRunning = true
            statusMessage = "Listening"

            let transcriptStream = recognizer.transcribe(
                sessionID: sessionID,
                source: .microphone,
                audioStream: microphone.audioStream
            )

            Task { [weak self] in
                for await segment in transcriptStream {
                    await self?.append(segment: segment)
                }
            }
        } catch {
            statusMessage = "Failed to start microphone"
            isRunning = false
        }
    }

    func stop() async {
        guard isRunning else {
            return
        }

        await microphone?.stop()
        microphone = nil
        isRunning = false
        statusMessage = "Stopped"
    }

    private func append(segment: TranscriptSegment) {
        let line = CaptionLine(
            original: segment.text,
            translated: segment.translatedText ?? "",
            speaker: segment.speakerID ?? "Microphone"
        )

        lines.append(line)
    }
}
