import Foundation

public struct CaptionTextFormatter: Sendable {
    public init() {}

    public func readableCaption(
        from text: String,
        maxSentences: Int = 2,
        maxCharacters: Int = 220
    ) -> String {
        let cleaned = normalizeWhitespace(text)

        guard !cleaned.isEmpty else {
            return ""
        }

        let sentences = splitIntoSentences(cleaned)
        let selected = Array(sentences.suffix(maxSentences))
        let joined = selected.joined(separator: " ")

        if joined.count <= maxCharacters {
            return joined
        }

        return String(joined.suffix(maxCharacters))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func splitIntoSentences(_ text: String) -> [String] {
        let cleaned = normalizeWhitespace(text)

        guard !cleaned.isEmpty else {
            return []
        }

        var result: [String] = []
        var current = ""

        for character in cleaned {
            current.append(character)

            if ".!?。！？".contains(character) {
                let sentence = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if !sentence.isEmpty {
                    result.append(sentence)
                }
                current = ""
            }
        }

        let tail = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tail.isEmpty {
            result.append(tail)
        }

        return result
    }

    private func normalizeWhitespace(_ text: String) -> String {
        text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
