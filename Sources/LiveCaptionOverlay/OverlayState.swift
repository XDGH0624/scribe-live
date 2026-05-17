import Foundation
import ScribeCore

public struct OverlayCaptionState: Sendable {
    public var latestSegment: TranscriptSegment?
    public var isVisible: Bool
    public var showTranslation: Bool

    public init(
        latestSegment: TranscriptSegment? = nil,
        isVisible: Bool = true,
        showTranslation: Bool = true
    ) {
        self.latestSegment = latestSegment
        self.isVisible = isVisible
        self.showTranslation = showTranslation
    }
}

public actor OverlayCaptionStore {
    private(set) var state = OverlayCaptionState()

    public init() {}

    public func update(segment: TranscriptSegment) {
        state.latestSegment = segment
    }

    public func toggleVisibility() {
        state.isVisible.toggle()
    }
}
