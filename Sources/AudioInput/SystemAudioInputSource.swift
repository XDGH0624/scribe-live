import Foundation
import AVFoundation
import ScreenCaptureKit
import ScribeCore

@available(macOS 13.0, *)
public final class SystemAudioInputSource: NSObject, AudioInputSource, SCStreamOutput, SCStreamDelegate, @unchecked Sendable {
    public let sourceType: AudioSource = .systemAudio

    private var stream: SCStream?
    private let audioStreamValue: AsyncStream<AudioBuffer>
    private let continuation: AsyncStream<AudioBuffer>.Continuation

    public var audioStream: AsyncStream<AudioBuffer> {
        audioStreamValue
    }

    public override init() {
        var localContinuation: AsyncStream<AudioBuffer>.Continuation!
        self.audioStreamValue = AsyncStream<AudioBuffer> { continuation in
            localContinuation = continuation
        }
        self.continuation = localContinuation
        super.init()
    }

    public func start() async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )

        guard let display = content.displays.first else {
            throw SystemAudioInputError.noDisplayAvailable
        }

        let filter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = true
        configuration.excludesCurrentProcessAudio = true
        configuration.sampleRate = 44100
        configuration.channelCount = 1
        configuration.width = 2
        configuration.height = 2
        configuration.minimumFrameInterval = CMTime(value: 1, timescale: 1)

        let stream = SCStream(
            filter: filter,
            configuration: configuration,
            delegate: self
        )

        try stream.addStreamOutput(
            self,
            type: .audio,
            sampleHandlerQueue: DispatchQueue(label: "ScribeLive.SystemAudio")
        )

        self.stream = stream
        try await stream.startCapture()
    }

    public func stop() async {
        do {
            try await stream?.stopCapture()
        } catch {
            // Stop failures are non-fatal for the caller.
        }

        stream = nil
        continuation.finish()
    }

    public func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of type: SCStreamOutputType
    ) {
        guard type == .audio else {
            return
        }

        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return
        }

        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?

        let status = CMBlockBufferGetDataPointer(
            blockBuffer,
            atOffset: 0,
            lengthAtOffsetOut: nil,
            totalLengthOut: &length,
            dataPointerOut: &dataPointer
        )

        guard status == kCMBlockBufferNoErr,
              let dataPointer else {
            return
        }

        let floatCount = length / MemoryLayout<Float>.size
        let floatPointer = UnsafeRawPointer(dataPointer).bindMemory(
            to: Float.self,
            capacity: floatCount
        )

        let samples = Array(
            UnsafeBufferPointer(start: floatPointer, count: floatCount)
        )

        continuation.yield(
            AudioBuffer(timestamp: Date(), samples: samples)
        )
    }
}

public enum SystemAudioInputError: Error {
    case noDisplayAvailable
}
