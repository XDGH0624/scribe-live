import Foundation

public enum AudioSource: String, Codable, Sendable {
    case microphone
    case systemAudio
    case mixed
}

public struct TranscriptSegment: Identifiable, Codable, Sendable {
    public let id: UUID
    public let sessionID: UUID
    public let source: AudioSource
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let text: String
    public let translatedText: String?
    public let speakerID: String?
    public let confidence: Double?

    public init(
        id: UUID = UUID(),
        sessionID: UUID,
        source: AudioSource,
        startTime: TimeInterval,
        endTime: TimeInterval,
        text: String,
        translatedText: String? = nil,
        speakerID: String? = nil,
        confidence: Double? = nil
    ) {
        self.id = id
        self.sessionID = sessionID
        self.source = source
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
        self.translatedText = translatedText
        self.speakerID = speakerID
        self.confidence = confidence
    }
}

public struct TranscriptSession: Identifiable, Codable, Sendable {
    public let id: UUID
    public let createdAt: Date
    public var title: String
    public var segments: [TranscriptSegment]

    public init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        title: String,
        segments: [TranscriptSegment] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.segments = segments
    }
}
