import Foundation

public protocol Translator: Sendable {
    func convert(
        text: String,
        sourceLanguage: String?,
        targetLanguage: String
    ) async throws -> String
}

public struct MockTranslator: Translator {
    public init() {}

    public func convert(
        text: String,
        sourceLanguage: String?,
        targetLanguage: String
    ) async throws -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ""
        }

        // Placeholder translation until a real local/API translator is connected.
        // The prefix makes it clear that the translation pipeline is active.
        return "译文占位: " + text
    }
}
