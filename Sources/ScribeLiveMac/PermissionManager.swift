import Foundation
import AVFoundation
import Speech

@MainActor
final class PermissionManager: ObservableObject {
    @Published private(set) var microphoneAuthorized = false
    @Published private(set) var speechAuthorized = false

    func requestAll() async {
        async let microphone = Self.requestMicrophonePermission()
        async let speech = Self.requestSpeechPermission()

        microphoneAuthorized = await microphone
        speechAuthorized = await speech
    }

    private nonisolated static func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private nonisolated static func requestSpeechPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
