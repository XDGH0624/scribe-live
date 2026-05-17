import SwiftUI
import Notes

struct TranscriptSearchView: View {
    @State private var query = ""

    let results: [TranscriptSearchResult]
    let onSearch: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Transcripts")
                .font(.title2)
                .bold()

            HStack {
                TextField("Search transcript text", text: $query)
                    .textFieldStyle(.roundedBorder)

                Button("Search") {
                    onSearch(query)
                }
            }

            if results.isEmpty {
                Text("No search results")
                    .foregroundStyle(.secondary)
            } else {
                List(results) { result in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.snippet)
                            .font(.body)

                        Text(result.segment.source.rawValue)
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
