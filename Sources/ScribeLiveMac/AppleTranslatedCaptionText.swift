import SwiftUI

#if canImport(Translation)
import Translation

@available(macOS 15.0, *)
struct AppleTranslatedCaptionText: View {
    let text: String
    var targetLanguageIdentifier: String = "zh-Hans"

    @State private var translatedText = ""
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        Text(translatedText.isEmpty ? "Translating..." : translatedText)
            .task(id: text) {
                translatedText = ""
                configuration = TranslationSession.Configuration(
                    source: nil,
                    target: Locale.Language(identifier: targetLanguageIdentifier)
                )
            }
            .translationTask(configuration) { session in
                do {
                    let response = try await session.translate(text)
                    translatedText = response.targetText
                } catch {
                    translatedText = "Translation unavailable"
                }
            }
    }
}

#endif

struct CaptionTranslationText: View {
    let text: String

    var body: some View {
        if #available(macOS 15.0, *) {
#if canImport(Translation)
            AppleTranslatedCaptionText(text: text)
#else
            Text("Apple Translation unavailable")
#endif
        } else {
            Text("Apple Translation requires macOS 15+")
        }
    }
}
