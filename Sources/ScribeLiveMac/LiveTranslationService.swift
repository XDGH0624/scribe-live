import Foundation
import SwiftUI

#if canImport(Translation)
import Translation
#endif

#if canImport(Translation)
@available(macOS 15.0, *)
@MainActor
private final class AppleTranslationBridge {
    var configuration: TranslationSession.Configuration?
    private var session: TranslationSession?

    init(sourceLanguageIdentifier: String, targetLanguageIdentifier: String) {
        configuration = TranslationSession.Configuration(
            source: Locale.Language(identifier: sourceLanguageIdentifier),
            target: Locale.Language(identifier: targetLanguageIdentifier)
        )
    }

    func handleSession(_ session: TranslationSession) {
        self.session = session
    }

    func translate(_ text: String) async throws -> String? {
        guard let session else {
            return nil
        }

        let response = try await session.translate(text)
        return response.targetText
    }
}
#endif

@MainActor
final class LiveTranslationService: ObservableObject {
    @Published var allowsNetworkFallback = false

    private var sourceLanguageIdentifier = "en"
    private var targetLanguageIdentifier = "zh-Hans"

#if canImport(Translation)
    private var appleBridge: AnyObject?
#endif

    func configure(
        sourceLanguageIdentifier: String = "en",
        targetLanguageIdentifier: String = "zh-Hans"
    ) {
        self.sourceLanguageIdentifier = sourceLanguageIdentifier
        self.targetLanguageIdentifier = targetLanguageIdentifier

#if canImport(Translation)
        if #available(macOS 15.0, *) {
            appleBridge = AppleTranslationBridge(
                sourceLanguageIdentifier: sourceLanguageIdentifier,
                targetLanguageIdentifier: targetLanguageIdentifier
            )
        } else {
            appleBridge = nil
        }
#endif
    }

#if canImport(Translation)
    @available(macOS 15.0, *)
    var appleConfiguration: TranslationSession.Configuration? {
        (appleBridge as? AppleTranslationBridge)?.configuration
    }

    @available(macOS 15.0, *)
    func handleSession(_ session: TranslationSession) {
        (appleBridge as? AppleTranslationBridge)?.handleSession(session)
    }
#endif

    func translate(_ text: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ""
        }

#if canImport(Translation)
        if #available(macOS 15.0, *),
           let translated = try await (appleBridge as? AppleTranslationBridge)?.translate(trimmed),
           !translated.isEmpty {
            return translated
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
