import SwiftUI

struct LiveCaptionView: View {
    @StateObject private var runtime = LiveCaptionRuntime()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            sourcePicker
            captionArea
            controls
        }
        .padding()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Live Captions")
                    .font(.title2)
                    .bold()

                Text(runtime.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var sourcePicker: some View {
        Picker("Audio Source", selection: $runtime.selectedSource) {
            ForEach(RuntimeAudioSource.allCases) { source in
                Text(source.rawValue)
                    .tag(source)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 560)
        .disabled(runtime.isRunning)
    }

    private var captionArea: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                if runtime.lines.isEmpty {
                    Text("Press Start and speak to see live captions.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    ForEach(runtime.lines) { line in
                        CaptionRowView(line: line)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 260)
    }

    private var controls: some View {
        HStack {
            Button("Start") {
                Task {
                    await runtime.start()
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(runtime.isRunning)

            Button("Stop") {
                Task {
                    await runtime.stop()
                }
            }
            .disabled(!runtime.isRunning)

            Spacer()
        }
    }
}

private struct CaptionRowView: View {
    let line: CaptionLine

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(line.speaker)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(line.original)
                .font(.body)
                .lineLimit(4)
                .textSelection(.enabled)

            if !line.translated.isEmpty {
                Text(line.translated)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
