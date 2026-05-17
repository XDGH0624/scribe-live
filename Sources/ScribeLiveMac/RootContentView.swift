import SwiftUI

struct RootContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scribe Live")
                .font(.largeTitle)
                .bold()

            Text("Local-first live captions, translation, and notes.")
                .font(.headline)

            LiveCaptionView()
        }
        .padding()
        .frame(minWidth: 720, minHeight: 480)
    }
}
