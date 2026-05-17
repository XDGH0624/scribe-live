import SwiftUI

struct OverlayCaptionView: View {
    let latestLine: CaptionLine?

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let latestLine {
                Text(latestLine.speaker)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(latestLine.original)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.82)
                    .fixedSize(horizontal: false, vertical: true)

                if !latestLine.translated.isEmpty {
                    Text(latestLine.translated)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Scribe Live")
                    .font(.headline)

                Text("Waiting for captions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(width: 680, alignment: .center)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 12)
    }
}
