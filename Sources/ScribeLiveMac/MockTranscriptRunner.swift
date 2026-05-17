import Foundation
import ScribeCore

struct MockTranscriptRunner {
    let sessionID: UUID

    func stream() -> AsyncStream<TranscriptSegment> {
        AsyncStream { continuation in
            Task {
                let samples = [
                    TranscriptSegment(
                        sessionID: sessionID,
                        source: .microphone,
                        startTime: 0,
                        endTime: 1,
                        text: "Welcome to Scribe Live.",
                        translatedText: "欢迎使用 Scribe Live。",
                        speakerID: "Speaker 1",
                        confidence: 0.98
                    ),
                    TranscriptSegment(
                        sessionID: sessionID,
                        source: .systemAudio,
                        startTime: 1,
                        endTime: 2,
                        text: "This is an automatic caption stream.",
                        translatedText: "这是一个自动字幕流。",
                        speakerID: "System Audio",
                        confidence: 0.96
                    ),
                    TranscriptSegment(
                        sessionID: sessionID,
                        source: .microphone,
                        startTime: 2,
                        endTime: 3,
                        text: "Future builds will connect real audio input.",
                        translatedText: "未来版本将接入真实音频输入。",
                        speakerID: "Speaker 1",
                        confidence: 0.94
                    )
                ]

                for sample in samples {
                    continuation.yield(sample)
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }

                continuation.finish()
            }
        }
    }
}
