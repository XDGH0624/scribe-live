import Foundation
import ScribeCore

public actor TranscriptSessionStore {
    private(set) var sessions: [TranscriptSession] = []

    public init() {}

    public func createSession(title: String) -> TranscriptSession {
        let session = TranscriptSession(title: title)
        sessions.append(session)
        return session
    }

    public func append(
        segment: TranscriptSegment,
        to sessionID: UUID
    ) {
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else {
            return
        }

        sessions[index].segments.append(segment)
    }

    public func allSessions() -> [TranscriptSession] {
        sessions
    }
}
