import SwiftUI
import ScribeCore

struct SessionHistoryView: View {
    let sessions: [TranscriptSession]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session History")
                .font(.title2)
                .bold()

            if sessions.isEmpty {
                Text("No saved sessions yet")
                    .foregroundStyle(.secondary)
            } else {
                List(sessions) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.title)
                            .font(.headline)

                        Text(session.createdAt.formatted())
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Segments: \(session.segments.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
    }
}
