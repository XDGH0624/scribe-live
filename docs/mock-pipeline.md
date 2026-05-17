# Mock Pipeline

The repository now contains a minimal end-to-end mock architecture.

## Current flow

```text
MockMicrophoneInputSource
    -> MockSpeechRecognizer
        -> TranscriptSegment
            -> OverlayCaptionStore
                -> TranscriptSessionStore
```

## What this enables

- Real-time style transcript streaming
- Overlay state updates
- Transcript persistence
- Translation abstraction
- Future OST integration point
- Future Swift Scribe integration point

## Next implementation target

Replace mocked audio and ASR with:

- real microphone input
- macOS system audio capture
- streaming speech recognition

## Planned UI layer

Future macOS app structure:

```text
App
 ├── Sidebar
 ├── NotesView
 ├── LiveCaptionView
 └── OverlayWindow
```

## Immediate next steps

1. Add SwiftUI macOS app target
2. Render live captions on screen
3. Connect transcript stream to overlay updates
4. Persist sessions locally
5. Add export support
