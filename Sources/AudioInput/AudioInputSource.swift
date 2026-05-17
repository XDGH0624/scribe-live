import Foundation
import ScribeCore

public struct AudioBuffer: Sendable {
    public let timestamp: Date
    public let samples: [Float]

    public init(timestamp: Date = .now, samples: [Float]) {
        self.timestamp = timestamp
        self.samples = samples
    }
}

public protocol AudioInputSource: Sendable {
    var sourceType: AudioSource { get }
    var audioStream: AsyncStream<AudioBuffer> { get }

    func start() async throws
    func stop() async
}

public final class MockMicrophoneInputSource: AudioInputSource, @unchecked Sendable {
    public let sourceType: AudioSource = .microphone

    private let stream: AsyncStream<AudioBuffer>
    private let continuation: AsyncStream<AudioBuffer>.Continuation

    public var audioStream: AsyncStream<AudioBuffer> {
        stream
    }

    public init() {
        var localContinuation: AsyncStream<AudioBuffer>.Continuation!

        self.stream = AsyncStream<AudioBuffer> {
            localContinuation = $0
        }

        self.continuation = localContinuation
    }

    public func start() async throws {
        continuation.yield(
            AudioBuffer(samples: [0.1, 0.2, 0.3])
        )
    }

    public func stop() async {
        continuation.finish()
    }
}
