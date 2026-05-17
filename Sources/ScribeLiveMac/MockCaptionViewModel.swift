import Foundation
import SwiftUI

struct CaptionLine: Hashable {
    let original: String
    let translated: String
}

@MainActor
final class MockCaptionViewModel: ObservableObject {
    @Published var lines: [CaptionLine] = []

    func generateMockCaption() {
        let samples: [CaptionLine] = [
            CaptionLine(
                original: "Welcome to Scribe Live.",
                translated: "欢迎使用 Scribe Live。"
            ),
            CaptionLine(
                original: "This is a simulated real-time caption stream.",
                translated: "这是一个模拟的实时字幕流。"
            ),
            CaptionLine(
                original: "Future versions will use live audio capture.",
                translated: "未来版本将使用真实音频捕获。"
            )
        ]

        if let random = samples.randomElement() {
            lines.append(random)
        }
    }
}
