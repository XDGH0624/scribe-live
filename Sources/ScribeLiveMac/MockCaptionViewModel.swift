import Foundation
import SwiftUI
import ScribeCore

struct CaptionLine: Identifiable, Hashable {
    let id: UUID
    var original: String
    var translated: String
    var speaker: String

    init(
        id: UUID = UUID(),
        original: String,
        translated: String,
        speaker: String
    ) {
        self.id = id
        self.original = original
        self.translated = translated
        self.speaker = speaker
    }
}

@MainActor
final class MockCaptionViewModel: ObservableObject {
    @Published var lines: [CaptionLine] = []

    private let sessionID = UUID()

    func startStreaming() {
        let runner = MockTranscriptRunner(sessionID: sessionID)

        Task {
            for await segment in runner.stream() {
                let line = CaptionLine(
                    original: segment.text,
                    translated: segment.translatedText ?? "",
                    speaker: segment.speakerID ?? "Unknown"
                )

                lines.append(line)
            }
        }
    }
}
