import Foundation
import Speech
import AVFoundation
import ScribeCore
import AudioInput

public final class AppleSpeechRecognizer: SpeechRecognizer {
    private var recognitionTask: SFSpeechRecognitionTask?
    private var stabilizer = TranscriptStabilizer()

    public init() {}

    public func transcribe(
        sessionID: UUID,
        source: AudioSource,
        audioStream: AsyncStream<AudioBuffer>
    ) -> AsyncStream<TranscriptSegment> {

        AsyncStream { continuation in
            Task {
                guard let recognizer = SFSpeechRecognizer() else {
                    continuation.finish()
                    return
                }

                let request = SFSpeechAudioBufferRecognitionRequest()
                request.shouldReportPartialResults = true

                self.recognitionTask = recognizer.recognitionTask(with: request) {
                    result, error in

                    if let result {
                        let text = result.bestTranscription.formattedString

                        if let segment = self.stabilizer.process(
                            text: text,
                            sessionID: sessionID,
                            source: source,
                            isFinal: result.isFinal
                        ) {
                            continuation.yield(segment)
                        }
                    }

                    if error != nil {
                        continuation.finish()
                    }
                }

                for await buffer in audioStream {
                    if let pcmBuffer = Self.makePCMBuffer(from: buffer.samples) {
                        request.append(pcmBuffer)
                    }
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
