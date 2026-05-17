import SwiftUI
import Notes

struct SemanticSearchView: View {
    @State private var query = ""
    @State private var results: [SemanticSearchMatch] = []

    let searchAction: (String) async -> [SemanticSearchMatch]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Semantic Search")
                .font(.title2)
                .bold()

            HStack {
                TextField("Ask about previous meetings or notes", text: $query)
                    .textFieldStyle(.roundedBorder)

                Button("Search") {
                    Task {
                        results = await searchAction(query)
                    }
                }
            }

            if results.isEmpty {
                Text("No semantic matches")
                    .foregroundStyle(.secondary)
            } else {
                List(results) { result in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(result.text)
                            .font(.body)

                        Text(String(format: "Similarity: %.2f", result.similarity))
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
