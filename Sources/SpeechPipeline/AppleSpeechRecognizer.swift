import Foundation
import Speech
import ScribeCore
import AudioInput

public final class AppleSpeechRecognizer: SpeechRecognizer {
    public init() {}

    public func transcribe(
        sessionID: UUID,
        source: AudioSource,
        audioStream: AsyncStream<AudioBuffer>
    ) -> AsyncStream<TranscriptSegment> {

        AsyncStream { continuation in
            Task {
                let recognizer = SFSpeechRecognizer()
                let request = SFSpeechAudioBufferRecognitionRequest()

                guard recognizer != nil else {
                    continuation.finish()
                    return
                }

                for await buffer in audioStream {
                    let pcmBuffer = Self.makePCMBuffer(from: buffer.samples)

                    if let pcmBuffer {
                        request.append(pcmBuffer)
                    }

                    continuation.yield(
                        TranscriptSegment(
                            sessionID: sessionID,
                            source: source,
                            startTime: 0,
                            endTime: 0,
                            text: "Streaming speech recognition placeholder",
                            translatedText: nil,
                            speakerID: nil,
                            confidence: nil
                        )
                    )
                }

                request.endAudio()
                continuation.finish()
            }
        }
    }

    private static func makePCMBuffer(from samples: [Float]) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(
            standardFormatWithSampleRate: 44100,
            channels: 1
        )

        guard let format,
              let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(samples.count)
              ) else {
            return nil
        }

        buffer.frameLength = AVAudioFrameCount(samples.count)

        let audioBuffer = buffer.floatChannelData?[0]

        for index in 0..<samples.count {
            audioBuffer?[index] = samples[index]
        }

        return buffer
    }
}
