import Foundation

public struct SessionSummary: Identifiable, Codable, Sendable {
    public let id: UUID
    public let sessionID: UUID
    public let generatedAt: Date
    public let overview: String
    public let topics: [String]
    public let actionItems: [String]

    public init(
        id: UUID = UUID(),
        sessionID: UUID,
        generatedAt: Date = .now,
        overview: String,
        topics: [String],
        actionItems: [String]
    ) {
        self.id = id
        self.sessionID = sessionID
        self.generatedAt = generatedAt
        self.overview = overview
        self.topics = topics
        self.actionItems = actionItems
    }
}
