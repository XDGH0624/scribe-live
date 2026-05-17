import Foundation
import ScribeCore

public struct TranscriptSearchResult: Identifiable, Sendable {
    public let id: UUID
    public let sessionID: UUID
    public let segment: TranscriptSegment
    public let snippet: String

    public init(
        id: UUID = UUID(),
        sessionID: UUID,
        segment: TranscriptSegment,
        snippet: String
    ) {
        self.id = id
        self.sessionID = sessionID
        self.segment = segment
        self.snippet = snippet
    }
}

public struct TranscriptSearchIndex: Sendable {
    public init() {}

    public func search(
        query: String,
        sessions: [TranscriptSession]
    ) -> [TranscriptSearchResult] {
        let cleanedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedQuery.isEmpty else {
            return []
        }

        return sessions.flatMap { session in
            session.segments.compactMap { segment in
                let haystack = [
                    segment.text,
                    segment.translatedText ?? "",
                    segment.speakerID ?? "",
                    segment.source.rawValue
                ].joined(separator: " ")

                guard haystack.localizedCaseInsensitiveContains(cleanedQuery) else {
                    return nil
                }

                return TranscriptSearchResult(
                    sessionID: session.id,
                    segment: segment,
                    snippet: segment.text
                )
            }
        }
    }
}
