import SwiftUI
import Notes

struct SessionSummaryView: View {
    let summary: SessionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Session Summary")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("Overview")
                    .font(.headline)

                Text(summary.overview)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Topics")
                    .font(.headline)

                ForEach(summary.topics, id: \.self) { topic in
                    Text("• \(topic)")
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Action Items")
                    .font(.headline)

                if summary.actionItems.isEmpty {
                    Text("No action items detected")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(summary.actionItems, id: \.self) { item in
                        Text("• \(item)")
                    }
                }
            }
        }
        .padding()
    }
}
