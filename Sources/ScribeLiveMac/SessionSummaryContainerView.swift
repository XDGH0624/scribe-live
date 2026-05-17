import SwiftUI
import Notes

struct SessionSummaryContainerView: View {
    let summary: SessionSummary?

    var body: some View {
        Group {
            if let summary {
                SessionSummaryView(summary: summary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Notes")
                        .font(.title2)
                        .bold()

                    Text("No summary generated yet")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}
