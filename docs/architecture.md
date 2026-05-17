# Architecture

## Product goals

Scribe Live combines:

1. local-first speech transcription;
2. real-time captions and translation;
3. post-session notes and summaries;
4. searchable transcript storage.

The architecture is intentionally modular so that upstream projects can be integrated incrementally.

---

# High-level pipeline

```text
AudioInput
  -> SpeechPipeline
    -> TranslationPipeline
      -> Presentation
        -> Persistence
```

---

# Module layout

## ScribeCore

Shared data models and session state.

### Responsibilities

- Session lifecycle
- Transcript models
- Persistence contracts
- Shared app state

### Initial models

```swift
struct TranscriptSegment: Identifiable, Codable {
    let id: UUID
    let sessionID: UUID
    let source: AudioSource
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
    let translatedText: String?
    let speakerID: String?
    let confidence: Double?
}
```

---

## AudioInput

Abstracts microphone and system audio.

### Protocol

```swift
protocol AudioInputSource {
    var sourceType: AudioSource { get }
    func start() async throws
    func stop() async
    var audioStream: AsyncStream<AudioBuffer> { get }
}
```

### Planned implementations

- `MicrophoneInputSource`
- `SystemAudioInputSource`
- `MixedAudioInputSource`

---

## SpeechPipeline

Transforms audio buffers into transcript segments.

### Responsibilities

- Voice activity detection
- Streaming ASR
- Speaker diarization
- Segment merging
- Confidence scoring

### Design principle

Real-time mode prioritizes low latency.
Post-session mode prioritizes accuracy.

---

## TranslationPipeline

Provides optional translation.

### Protocol

```swift
protocol Translator {
    func translate(
        _ text: String,
        from sourceLanguage: String?,
        to targetLanguage: String
    ) async throws -> String
}
```

### Modes

- Streaming translation
- Batch translation
- Bilingual transcript generation

---

## LiveCaptionOverlay

macOS floating caption window.

### Responsibilities

- Always-on-top subtitle rendering
- Overlay positioning
- Compact caption state
- Bilingual rendering
- Accessibility support

---

## Notes

Persistent transcript and summary views.

### Responsibilities

- Transcript editing
- Search indexing
- Markdown export
- PDF export
- Session summaries
- Keyword extraction

---

# Integration strategy

## OST integration

Import only:

- system audio capture
- floating subtitle overlay
- low-latency streaming caption logic

Avoid tight coupling to UI or app lifecycle.

## Swift Scribe integration

Import only:

- transcript persistence
- speaker diarization pipeline
- session organization
- summarization pipeline

Avoid hard dependency on beta-only APIs in core abstractions.

---

# Long-term direction

The long-term architecture should support:

- macOS app
- iOS companion app
- offline-first workflows
- export pipelines
- multilingual transcript alignment
- classroom and interview templates
- meeting replay and search
