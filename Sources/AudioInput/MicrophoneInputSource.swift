import Foundation
import AVFoundation
import ScribeCore

public final class MicrophoneInputSource: AudioInputSource, @unchecked Sendable {
    public let sourceType: AudioSource = .microphone

    private let engine = AVAudioEngine()
    private let stream: AsyncStream<AudioBuffer>
    private let continuation: AsyncStream<AudioBuffer>.Continuation

    public var audioStream: AsyncStream<AudioBuffer> {
        stream
    }

    public init() {
        var localContinuation: AsyncStream<AudioBuffer>.Continuation!
        self.stream = AsyncStream<AudioBuffer> { continuation in
            localContinuation = continuation
        }
        self.continuation = localContinuation
    }

    public func start() async throws {
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [continuation] buffer, _ in
            let frameLength = Int(buffer.frameLength)
            guard let channelData = buffer.floatChannelData?.pointee else {
                return
            }

            var samples: [Float] = []
            samples.reserveCapacity(frameLength)

            for index in 0..<frameLength {
                samples.append(channelData[index])
            }

            continuation.yield(
                AudioBuffer(timestamp: Date(), samples: samples)
            )
        }

        engine.prepare()
        try engine.start()
    }

    public func stop() async {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        continuation.finish()
    }
}
