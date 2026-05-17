import Foundation
import ScribeCore
import AudioInput

public protocol SpeechRecognizer: Sendable {
    func transcribe(
        sessionID: UUID,
        source: AudioSource,
        audioStream: AsyncStream<AudioBuffer>
    ) -> AsyncStream<TranscriptSegment>
}

public struct MockSpeechRecognizer: SpeechRecognizer {
    public init() {}

    public func transcribe(
        sessionID: UUID,
        source: AudioSource,
        audioStream: AsyncStream<AudioBuffer>
    ) -> AsyncStream<TranscriptSegment> {

        AsyncStream { continuation in
            Task {
                for await _ in audioStream {
                    continuation.yield(
                        TranscriptSegment(
                            sessionID: sessionID,
                            source: source,
                            startTime: 0,
                            endTime: 1,
                            text: "Mock live transcript segment",
                            translatedText: "模拟实时字幕"
                        )
                    )
                }

                continuation.finish()
            }
        }
    }
}
