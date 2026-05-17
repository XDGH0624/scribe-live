import Foundation
import AVFoundation
import Speech

@MainActor
final class PermissionManager: ObservableObject {
    @Published private(set) var microphoneAuthorized = false
    @Published private(set) var speechAuthorized = false

    func requestAll() async {
        microphoneAuthorized = await requestMicrophonePermission()
        speechAuthorized = await requestSpeechPermission()
    }

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
