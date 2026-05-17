import SwiftUI

#if os(macOS)
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
        panel.setContentSize(NSSize(width: 680, height: 220))
        panel.orderFrontRegardless()
    }

    func hideOverlay() {
        panel?.orderOut(nil)
    }

    private func createPanel() {
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
        let width: CGFloat = 680
        let height: CGFloat = 220
        let x = visibleFrame.midX - width / 2
        let y = visibleFrame.maxY - height - 24

        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: width, height: height),
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

#else

@MainActor
final class OverlayWindowController {
    func showOverlay(with latestLine: CaptionLine?) {}
    func hideOverlay() {}
}

#endif
