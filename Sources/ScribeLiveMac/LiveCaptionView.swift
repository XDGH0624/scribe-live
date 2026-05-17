import SwiftUI

struct LiveCaptionView: View {
    @StateObject private var model = MockCaptionViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Captions")
                .font(.title2)
                .bold()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(model.lines, id: \.self) { line in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(line.original)
                                .font(.body)

                            Text(line.translated)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                    }
                }
            }

            Button("Generate Mock Caption") {
                model.generateMockCaption()
            }
        }
    }
}
