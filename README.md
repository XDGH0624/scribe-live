# Scribe Live

Scribe Live is a local-first Apple-platform app concept that combines two workflows:

- **Swift Scribe-style recording and notes**: record speech, transcribe locally, organize searchable notes, and generate post-session summaries.
- **OST-style live captions and translation**: capture system audio on macOS, show real-time captions in a floating overlay, translate live, and save the transcript for later review.

The goal is one app with three modes:

1. **Record Mode**: microphone recording -> transcription -> speaker labeling -> notes.
2. **Live Caption Mode**: system audio -> real-time captions -> optional translation -> saved transcript.
3. **Meeting Mode**: microphone + system audio -> live captions -> post-session cleanup -> summary and export.

## Why this exists

Most caption tools are temporary: once the meeting or video ends, the text disappears. Most transcription tools are post-hoc: they do not help while you are listening. Scribe Live aims to connect both workflows:

> Watch, listen, or meet in real time; then keep the transcript, translation, summary, and notes.

## Current status

This repository is in the planning and architecture phase. The first implementation target is a minimal macOS prototype that can:

- represent microphone and system audio sources behind one protocol;
- emit transcript segments from a speech pipeline;
- display live captions through an overlay module;
- persist transcript segments into a session model;
- prepare the codebase for later integration with Swift Scribe and OST code.

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

- [Architecture](docs/architecture.md)
- [Integration plan](docs/integration-plan.md)
- [Roadmap](docs/roadmap.md)

## Development direction

The project should prefer modular interfaces before importing large blocks of upstream code. OST capabilities should enter through `SystemAudioInputSource` and `FloatingSubtitleOverlay`. Swift Scribe capabilities should enter through notes, persistence, post-session transcription, speaker diarization, and summarization.

## License

To be decided. Before copying code from either upstream project, verify license compatibility and preserve attribution.