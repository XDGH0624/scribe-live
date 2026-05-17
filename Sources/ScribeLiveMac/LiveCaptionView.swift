import SwiftUI

struct LiveCaptionView: View {
    @StateObject private var runtime = LiveCaptionRuntime()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Live Captions")
                    .font(.title2)
                    .bold()

                Spacer()

                Text(runtime.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(runtime.lines, id: \.self) { line in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(line.speaker)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(line.original)
                                .font(.body)

                            if !line.translated.isEmpty {
                                Text(line.translated)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                    }
                }
            }

            HStack {
                Button("Start") {
                    Task {
                        await runtime.start()
                    }
                }
                .disabled(runtime.isRunning)

                Button("Stop") {
                    Task {
                        await runtime.stop()
                    }
                }
                .disabled(!runtime.isRunning)
            }
        }
    }
}
