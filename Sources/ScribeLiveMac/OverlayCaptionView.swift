import SwiftUI

struct OverlayCaptionView: View {
    let latestLine: CaptionLine?

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            if let latestLine {
                Text(latestLine.speaker)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(latestLine.original)
                    .font(.title3)
                    .multilineTextAlignment(.center)

                if !latestLine.translated.isEmpty {
                    Text(latestLine.translated)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text("Scribe Live")
                    .font(.headline)

                Text("Waiting for captions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(minWidth: 420, minHeight: 96)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 12)
    }
}
