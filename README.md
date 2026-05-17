# Scribe Live

Scribe Live is a local-first Apple-platform app concept that combines two workflows:

- **Swift Scribe-style recording and notes**: record speech, transcribe locally, organize searchable notes, and generate post-session summaries.
- **OST-style live captions and translation**: capture system audio on macOS, show real-time captions in a floating overlay, translate live, and save the transcript for later review.

The goal is one app with three modes:

1. **Record Mode**: microphone recording -> transcription -> speaker labeling -> notes.
2. **Live Caption Mode**: system audio -> real-time captions -> optional translation -> saved transcript.
3. **Meeting Mode**: microphone + system audio -> live captions -> post-session cleanup -> summary and export.

## Running the macOS app

This repository now supports generating a full macOS `.app` project using XcodeGen.

### Requirements

- macOS 14+
- Xcode 16+
- XcodeGen

Install XcodeGen:

```bash
brew install xcodegen
```

Generate the Xcode project:

```bash
xcodegen generate
```

Open the generated project:

```bash
open ScribeLive.xcodeproj
```

In Xcode:

- Select `ScribeLiveMac`
- Choose `My Mac`
- Press `Cmd + R`

The generated app bundle includes:

- microphone permission descriptions
- speech recognition permission descriptions
- screen capture permission descriptions
- bundle identifier configuration
- app entitlements

## Why this exists

Most caption tools are temporary: once the meeting or video ends, the text disappears. Most transcription tools are post-hoc: they do not help while you are listening. Scribe Live aims to connect both workflows:

> Watch, listen, or meet in real time; then keep the transcript, translation, summary, and notes.

## Current status

This repository is evolving from a Swift Package prototype into a full macOS application.

Implemented foundations include:

- microphone capture
- system audio capture skeleton
- streaming speech recognition
- transcript stabilization
- floating overlay captions
- transcript persistence
- searchable history
- AI summaries
- semantic retrieval foundations

## Proposed architecture

```text
Sources/
  ScribeCore/             Shared models and session state
  AudioInput/             Microphone, system audio, and mixed input abstractions
  SpeechPipeline/         ASR, VAD, speaker diarization, segment merging
  TranslationPipeline/    Live and batch translation interfaces
  LiveCaptionOverlay/     Floating caption window and live caption UI state
  Notes/                  Transcript, notes, summaries, export models
```

## Documentation

- Architecture: docs/architecture.md
- Integration plan: docs/integration-plan.md
- Roadmap: docs/roadmap.md
- System audio notes: docs/system-audio-notes.md
- Mock pipeline: docs/mock-pipeline.md

## Development direction

The project should prefer modular interfaces before importing large blocks of upstream code. OST capabilities should enter through `SystemAudioInputSource` and `FloatingSubtitleOverlay`. Swift Scribe capabilities should enter through notes, persistence, post-session transcription, speaker diarization, summarization, and semantic retrieval.

## License

To be decided. Before copying code from either upstream project, verify license compatibility and preserve attribution.
