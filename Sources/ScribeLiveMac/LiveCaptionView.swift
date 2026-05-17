import SwiftUI

#if canImport(Translation)
import Translation
#endif

struct LiveCaptionView: View {
    @StateObject private var runtime = LiveCaptionRuntime()

    var body: some View {
        content
            .padding()
            .withAppleTranslationSession(runtime: runtime)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            sourcePicker
            translationSettings
            captionArea
            controls
        }
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

    private var translationSettings: some View {
        Toggle("Allow network translation fallback", isOn: $runtime.translationService.allowsNetworkFallback)
            .font(.caption)
            .foregroundStyle(.secondary)
            .toggleStyle(.checkbox)
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
                    HStack(spacing: 12) {
                        Text("Original")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Translation")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 12)

                    ForEach(runtime.lines) { line in
                        CaptionRowView(line: line)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 320)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(line.speaker)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 12) {
                Text(line.original)
                    .font(.body)
                    .lineLimit(5)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                Text(line.translated.isEmpty ? "Translation pending" : line.translated)
                    .font(.body)
                    .foregroundStyle(line.translated.isEmpty ? .secondary : .primary)
                    .lineLimit(5)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private extension View {
    @ViewBuilder
    func withAppleTranslationSession(runtime: LiveCaptionRuntime) -> some View {
#if canImport(Translation)
        if #available(macOS 15.0, *) {
            self.translationTask(runtime.translationService.appleConfiguration) { session in
                runtime.translationService.installAppleTranslator(session: session)
            }
        } else {
            self
        }
#else
        self
#endif
    }
}
