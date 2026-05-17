import Foundation
import SwiftUI
import ScribeCore
import AudioInput
import SpeechPipeline
import TranslationPipeline
import Notes

@MainActor
final class LiveCaptionRuntime: ObservableObject {
    @Published private(set) var lines: [CaptionLine] = []
    @Published private(set) var isRunning = false
    @Published private(set) var statusMessage = "Ready"
    @Published private(set) var activeSession: TranscriptSession?
    @Published private(set) var activeSummary: SessionSummary?
    @Published var selectedSource: RuntimeAudioSource = .microphone

    private let permissions = PermissionManager()
    private let overlayController = OverlayWindowController()
    private let sessionStore = TranscriptSessionStore()
    private let summaryGenerator = LocalSummaryGenerator()
    private let captionFormatter = CaptionTextFormatter()
    private let translator = MockTranslator()

    private var microphone: MicrophoneInputSource?

    @available(macOS 13.0, *)
    private var systemAudio: SystemAudioInputSource?

    private let recognizer = AppleSpeechRecognizer()
    private var sessionID = UUID()
    private var currentLineIDs: [AudioSource: UUID] = [:]
    private var lastRenderedTextBySource: [AudioSource: String] = [:]

    func start() async {
        guard !isRunning else { return }

        activeSummary = nil
        lines.removeAll()
        currentLineIDs.removeAll()
        lastRenderedTextBySource.removeAll()

        let session = await sessionStore.createSession(title: "Live Caption Session")
        activeSession = session
        sessionID = session.id

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
            bindTranscriptStream(recognizer.transcribe(sessionID: sessionID, source: .microphone, audioStream: microphone.audioStream))
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
            bindTranscriptStream(recognizer.transcribe(sessionID: sessionID, source: .systemAudio, audioStream: systemAudio.audioStream))
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
            bindTranscriptStream(recognizer.transcribe(sessionID: sessionID, source: .microphone, audioStream: microphone.audioStream))
            bindTranscriptStream(recognizer.transcribe(sessionID: sessionID, source: .systemAudio, audioStream: systemAudio.audioStream))
        } catch {
            statusMessage = "Failed to start mixed mode"
            isRunning = false
        }
    }

    func stop() async {
        guard isRunning else { return }

        await microphone?.stop()
        microphone = nil

        if #available(macOS 13.0, *) {
            await systemAudio?.stop()
            systemAudio = nil
        }

        overlayController.hideOverlay()

        if let session = await sessionStore.allSessions().first(where: { $0.id == sessionID }) {
            activeSession = session
            activeSummary = summaryGenerator.generate(from: session)
        }

        isRunning = false
        statusMessage = "Stopped"
    }

    func sessions() async -> [TranscriptSession] {
        await sessionStore.allSessions()
    }

    private func bindTranscriptStream(_ stream: AsyncStream<TranscriptSegment>) {
        Task { [weak self] in
            for await segment in stream {
                await self?.append(segment: segment)
            }
        }
    }

    private func append(segment: TranscriptSegment) async {
        await sessionStore.append(segment: segment, to: sessionID)
        activeSession = await sessionStore.allSessions().first { $0.id == sessionID }

        let speaker = speakerLabel(for: segment.source)
        let readableText = captionFormatter.readableCaption(from: segment.text)
        guard !readableText.isEmpty else { return }
        guard lastRenderedTextBySource[segment.source] != readableText else { return }
        lastRenderedTextBySource[segment.source] = readableText

        let translatedText: String
        do {
            translatedText = try await translator.convert(text: readableText, sourceLanguage: nil, targetLanguage: "zh-Hans")
        } catch {
            translatedText = ""
        }

        let lineID = currentLineIDs[segment.source] ?? UUID()
        currentLineIDs[segment.source] = lineID

        let line = CaptionLine(id: lineID, original: readableText, translated: translatedText, speaker: speaker)

        if let index = lines.firstIndex(where: { $0.id == lineID }) {
            lines[index] = line
        } else {
            lines.append(line)
        }

        overlayController.showOverlay(with: line)
    }

    private func speakerLabel(for source: AudioSource) -> String {
        switch source {
        case .microphone: return "Microphone"
        case .systemAudio: return "System Audio"
        case .mixed: return "Mixed"
        }
    }
}
