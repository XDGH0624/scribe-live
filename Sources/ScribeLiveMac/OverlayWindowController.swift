import SwiftUI
import AppKit

@MainActor
final class OverlayWindowController {
    private var panel: NSPanel?

    func showOverlay(with latestLine: CaptionLine?) {
        if panel == nil {
            createPanel()
        }

        guard let panel else {
            return
        }

        let hostingView = NSHostingView(
            rootView: OverlayCaptionView(latestLine: latestLine)
        )

        panel.contentView = hostingView
        panel.orderFrontRegardless()
    }

    func hideOverlay() {
        panel?.orderOut(nil)
    }

    private func createPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 300, y: 700, width: 520, height: 140),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        self.panel = panel
    }
}
