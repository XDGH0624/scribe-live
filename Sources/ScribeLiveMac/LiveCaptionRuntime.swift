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
    @Published var selectedSource: RuntimeAudioSource = .microphone

    private let permissions = PermissionManager()
    private let overlayController = OverlayWindowController()

    private var microphone: MicrophoneInputSource?

    @available(macOS 13.0, *)
    private var systemAudio: SystemAudioInputSource?

    private let recognizer = AppleSpeechRecognizer()
    private let sessionID = UUID()

    func start() async {
        guard !isRunning else {
            return
        }

        statusMessage = "Requesting permissions"
        await permissions.requestAll()

        guard permissions.speechAuthorized else {
            statusMessage = "Speech recognition permission denied"
            return
        }

        switch selectedSource {
        case .microphone:
            await startMicrophoneMode()

        case .systemAudio:
            await startSystemAudioMode()

        case .mixed:
            await startMixedMode()
        }
    }

    private func startMicrophoneMode() async {
        guard permissions.microphoneAuthorized else {
            statusMessage = "Microphone permission denied"
            return
        }

        let microphone = MicrophoneInputSource()
        self.microphone = microphone

        do {
            statusMessage = "Starting microphone"
            try await microphone.start()
            isRunning = true
            statusMessage = "Listening to microphone"

            bindTranscriptStream(
                recognizer.transcribe(
                    sessionID: sessionID,
                    source: .microphone,
                    audioStream: microphone.audioStream
                )
            )
        } catch {
            statusMessage = "Failed to start microphone"
            isRunning = false
        }
    }

    private func startSystemAudioMode() async {
        guard #available(macOS 13.0, *) else {
            statusMessage = "System audio requires macOS 13"
            return
        }

        let systemAudio = SystemAudioInputSource()
        self.systemAudio = systemAudio

        do {
            statusMessage = "Starting system audio"
            try await systemAudio.start()
            isRunning = true
            statusMessage = "Listening to system audio"

            bindTranscriptStream(
                recognizer.transcribe(
                    sessionID: sessionID,
                    source: .systemAudio,
                    audioStream: systemAudio.audioStream
                )
            )
        } catch {
            statusMessage = "Failed to start system audio"
            isRunning = false
        }
    }

    private func startMixedMode() async {
        guard permissions.microphoneAuthorized else {
            statusMessage = "Microphone permission denied"
            return
        }

        guard #available(macOS 13.0, *) else {
            statusMessage = "Mixed mode requires macOS 13"
            return
        }

        let microphone = MicrophoneInputSource()
        let systemAudio = SystemAudioInputSource()

        self.microphone = microphone
        self.systemAudio = systemAudio

        do {
            statusMessage = "Starting mixed mode"

            try await microphone.start()
            try await systemAudio.start()

            isRunning = true
            statusMessage = "Listening to microphone and system audio"

            bindTranscriptStream(
                recognizer.transcribe(
                    sessionID: sessionID,
                    source: .microphone,
                    audioStream: microphone.audioStream
                )
            )

            bindTranscriptStream(
                recognizer.transcribe(
                    sessionID: sessionID,
                    source: .systemAudio,
                    audioStream: systemAudio.audioStream
                )
            )
        } catch {
            statusMessage = "Failed to start mixed mode"
            isRunning = false
        }
    }

    func stop() async {
        guard isRunning else {
            return
        }

        await microphone?.stop()
        microphone = nil

        if #available(macOS 13.0, *) {
            await systemAudio?.stop()
            systemAudio = nil
        }

        overlayController.hideOverlay()

        isRunning = false
        statusMessage = "Stopped"
    }

    private func bindTranscriptStream(
        _ stream: AsyncStream<TranscriptSegment>
    ) {
        Task { [weak self] in
            for await segment in stream {
                await self?.append(segment: segment)
            }
        }
    }

    private func append(segment: TranscriptSegment) {
        let speaker: String

        switch segment.source {
        case .microphone:
            speaker = "Microphone"

        case .systemAudio:
            speaker = "System Audio"

        case .mixed:
            speaker = "Mixed"
        }

        let line = CaptionLine(
            original: segment.text,
            translated: segment.translatedText ?? "",
            speaker: speaker
        )

        lines.append(line)
        overlayController.showOverlay(with: line)
    }
}
