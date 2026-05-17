import Foundation

public struct SemanticEmbedding: Codable, Sendable {
    public let values: [Double]

    public init(values: [Double]) {
        self.values = values
    }
}

public protocol EmbeddingProvider: Sendable {
    func embed(_ text: String) async throws -> SemanticEmbedding
}

public struct LocalBagOfWordsEmbeddingProvider: EmbeddingProvider {
    private let vocabulary: [String]

    public init(vocabulary: [String] = LocalBagOfWordsEmbeddingProvider.defaultVocabulary) {
        self.vocabulary = vocabulary
    }

    public func embed(_ text: String) async throws -> SemanticEmbedding {
        let lowercased = text.lowercased()

        let values = vocabulary.map { token in
            lowercased.contains(token.lowercased()) ? 1.0 : 0.0
        }

        return SemanticEmbedding(values: values)
    }

    public static let defaultVocabulary = [
        "meeting",
        "class",
        "lecture",
        "student",
        "history",
        "sociology",
        "research",
        "interview",
        "assignment",
        "discussion",
        "project",
        "summary",
        "action",
        "follow",
        "translation",
        "audio",
        "caption",
        "question",
        "argument",
        "evidence"
    ]
}
