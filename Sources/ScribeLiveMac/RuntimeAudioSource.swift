import Foundation
import ScribeCore

enum RuntimeAudioSource: String, CaseIterable, Identifiable {
    case microphone = "Microphone"
    case systemAudio = "System Audio"

    var id: String { rawValue }

    var audioSource: AudioSource {
        switch self {
        case .microphone:
            return .microphone
        case .systemAudio:
            return .systemAudio
        }
    }
}
