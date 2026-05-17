import Foundation
import SwiftUI
import ScribeCore

struct CaptionLine: Hashable {
    let original: String
    let translated: String
    let speaker: String
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
