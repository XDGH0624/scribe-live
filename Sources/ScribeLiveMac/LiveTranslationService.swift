import Foundation
import SwiftUI

#if canImport(Translation)
import Translation
#endif

@MainActor
final class LiveTranslationService: ObservableObject {
    @Published var allowsNetworkFallback = false
    @Published private(set) var latestOriginalText = ""
    @Published private(set) var latestAppleTranslatedText = ""

    private var sourceLanguageIdentifier = "en"
    private var targetLanguageIdentifier = "zh-Hans"

#if canImport(Translation)
    private var configurationStorage: Any?
#endif

    func configure(
        sourceLanguageIdentifier: String = "en",
        targetLanguageIdentifier: String = "zh-Hans"
    ) {
        self.sourceLanguageIdentifier = sourceLanguageIdentifier
        self.targetLanguageIdentifier = targetLanguageIdentifier
        latestOriginalText = ""
        latestAppleTranslatedText = ""

#if canImport(Translation)
        if #available(macOS 15.0, *) {
            configurationStorage = TranslationSession.Configuration(
                source: Locale.Language(identifier: sourceLanguageIdentifier),
                target: Locale.Language(identifier: targetLanguageIdentifier)
            )
        } else {
            configurationStorage = nil
        }
#endif
    }

#if canImport(Translation)
    @available(macOS 15.0, *)
    var appleConfiguration: TranslationSession.Configuration? {
        configurationStorage as? TranslationSession.Configuration
    }

    @available(macOS 15.0, *)
    func publishAppleTranslation(original: String, translated: String) {
        latestOriginalText = original
        latestAppleTranslatedText = translated
    }
#endif

    func translate(_ text: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ""
        }

#if canImport(Translation)
        if #available(macOS 15.0, *),
           trimmed == latestOriginalText,
           !latestAppleTranslatedText.isEmpty {
            return latestAppleTranslatedText
        }
#endif

        guard allowsNetworkFallback else {
            return ""
        }

        return try await fallbackTranslation(trimmed)
    }

    private func fallbackTranslation(_ text: String) async throws -> String {
        let source = sourceLanguageIdentifier
        let target = googleLanguageCode(from: targetLanguageIdentifier)
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(source)&tl=\(target)&dt=t&q=\(encoded)"

        guard let url = URL(string: urlString) else {
            return ""
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            return ""
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [Any],
              let sentences = json.first as? [Any] else {
            return ""
        }

        var result = ""
        for sentence in sentences {
            if let parts = sentence as? [Any],
               let translated = parts.first as? String {
                result += translated
            }
        }

        return result
    }

    private func googleLanguageCode(from identifier: String) -> String {
        switch identifier {
        case "zh-Hans", "zh-CN":
            return "zh-CN"
        case "zh-Hant", "zh-TW":
            return "zh-TW"
        default:
            return identifier
        }
    }
}
