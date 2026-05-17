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
        return "Converted: " + text
    }
}
