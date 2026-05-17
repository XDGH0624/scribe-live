import Foundation
import ScribeCore

public struct LocalSummaryGenerator: Sendable {
    public init() {}

    public func generate(
        from session: TranscriptSession
    ) -> SessionSummary {

        let transcriptText = session.segments
            .map(\.text)
            .joined(separator: " ")

        let overview = makeOverview(from: transcriptText)
        let topics = extractTopics(from: transcriptText)
        let actionItems = extractActionItems(from: transcriptText)

        return SessionSummary(
            sessionID: session.id,
            overview: overview,
            topics: topics,
            actionItems: actionItems
        )
    }

    private func makeOverview(from text: String) -> String {
        let words = text
            .split(separator: " ")
            .prefix(40)
            .joined(separator: " ")

        return String(words)
    }

    private func extractTopics(from text: String) -> [String] {
        let candidates = [
            "meeting",
            "history",
            "research",
            "student",
            "discussion",
            "assignment",
            "project",
            "translation",
            "interview",
            "summary"
        ]

        return candidates.filter {
            text.localizedCaseInsensitiveContains($0)
        }
    }

    private func extractActionItems(from text: String) -> [String] {
        let sentences = text
            .components(separatedBy: ".")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        return sentences.filter {
            $0.localizedCaseInsensitiveContains("need") ||
            $0.localizedCaseInsensitiveContains("todo") ||
            $0.localizedCaseInsensitiveContains("follow up") ||
            $0.localizedCaseInsensitiveContains("action")
        }
    }
}
