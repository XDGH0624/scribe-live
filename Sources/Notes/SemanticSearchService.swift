import Foundation
import ScribeCore

public struct SemanticSearchMatch: Identifiable, Sendable {
    public let id: UUID
    public let sessionID: UUID
    public let text: String
    public let similarity: Double

    public init(
        id: UUID = UUID(),
        sessionID: UUID,
        text: String,
        similarity: Double
    ) {
        self.id = id
        self.sessionID = sessionID
        self.text = text
        self.similarity = similarity
    }
}

public actor SemanticSearchService {
    private let provider: any EmbeddingProvider

    public init(provider: any EmbeddingProvider = LocalBagOfWordsEmbeddingProvider()) {
        self.provider = provider
    }

    public func search(
        query: String,
        sessions: [TranscriptSession],
        limit: Int = 10
    ) async throws -> [SemanticSearchMatch] {

        let queryEmbedding = try await provider.embed(query)

        var matches: [SemanticSearchMatch] = []

        for session in sessions {
            for segment in session.segments {
                let embedding = try await provider.embed(segment.text)

                let similarity = cosineSimilarity(
                    lhs: queryEmbedding.values,
                    rhs: embedding.values
                )

                guard similarity > 0 else {
                    continue
                }

                matches.append(
                    SemanticSearchMatch(
                        sessionID: session.id,
                        text: segment.text,
                        similarity: similarity
                    )
                )
            }
        }

        return matches
            .sorted { $0.similarity > $1.similarity }
            .prefix(limit)
            .map { $0 }
    }

    private func cosineSimilarity(
        lhs: [Double],
        rhs: [Double]
    ) -> Double {
        guard lhs.count == rhs.count else {
            return 0
        }

        let dot = zip(lhs, rhs)
            .map(*)
            .reduce(0, +)

        let lhsNorm = sqrt(lhs.map { $0 * $0 }.reduce(0, +))
        let rhsNorm = sqrt(rhs.map { $0 * $0 }.reduce(0, +))

        guard lhsNorm > 0, rhsNorm > 0 else {
            return 0
        }

        return dot / (lhsNorm * rhsNorm)
    }
}
