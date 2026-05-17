import Foundation
import ScribeCore

public struct TranscriptStabilizer: Sendable {
    private var lastText: String = ""
    private var lastCommittedText: String = ""

    public init() {}

    public mutating func process(
        text: String,
        sessionID: UUID,
        source: AudioSource,
        isFinal: Bool
    ) -> TranscriptSegment? {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else {
            return nil
        }

        guard cleaned != lastText else {
            return nil
        }

        lastText = cleaned

        if isFinal {
            guard cleaned != lastCommittedText else {
                return nil
            }

            lastCommittedText = cleaned
        }

        return TranscriptSegment(
            sessionID: sessionID,
            source: source,
            startTime: 0,
            endTime: 0,
            text: cleaned,
            translatedText: nil,
            speakerID: nil,
            confidence: nil
        )
    }
}
