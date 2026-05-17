# System Audio Integration Notes

The project now includes a first-pass `SystemAudioInputSource` skeleton based on ScreenCaptureKit.

## Goals

- Capture macOS system audio
- Reuse the same transcript pipeline used by microphone input
- Support YouTube, Zoom, Teams, podcasts, and browser audio
- Preserve transcript stabilization and session persistence

---

# Current architecture

```text
ScreenCaptureKit
    ↓
SystemAudioInputSource
    ↓
AudioBuffer
    ↓
AppleSpeechRecognizer
    ↓
TranscriptStabilizer
    ↓
SwiftUI LiveCaptionView
```

---

# Important macOS requirements

System audio capture requires:

- macOS 13+
- Screen Recording permission
- ScreenCaptureKit availability

The app must request screen recording permissions through the standard macOS system flow.

---

# Known implementation gaps

The current implementation is an architectural skeleton.

Further work required:

- Validate audio sample format conversion
- Improve channel handling
- Support multi-channel audio
- Handle stream interruptions
- Add runtime source switching
- Add app audio exclusion controls
- Improve performance and buffering

---

# Future directions

## Mixed meeting mode

The long-term architecture supports:

```text
MicrophoneInputSource
    +
SystemAudioInputSource
```

This enables:

- local speaker tracking
- remote speaker captions
- meeting transcript reconstruction
- bilingual live meetings

---

# Long-term OST integration strategy

OST functionality should map into:

- SystemAudioInputSource
- Floating subtitle overlay
- Translation pipeline
- Live runtime coordination

while Swift Scribe functionality maps into:

- transcript persistence
- notes
- summaries
- search
- post-session processing
