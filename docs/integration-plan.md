# Integration Plan

## Objective

Combine:

- OST-style live captions and translation;
- Swift Scribe-style local transcription and note organization.

The integration should produce one coherent application instead of two loosely connected apps.

---

# Phase 1 — Foundation

## Goals

- Create shared data models
- Unify audio input abstraction
- Persist transcript segments
- Keep the codebase modular

## Deliverables

- `TranscriptSegment`
- `AudioInputSource`
- Session persistence layer
- Overlay prototype
- Minimal transcript viewer

## Success criteria

System audio or microphone input can create transcript segments that persist into a session.

---

# Phase 2 — Live Caption Mode

## Goals

Bring OST-like functionality into the new architecture.

## Deliverables

- `SystemAudioInputSource`
- Real-time streaming ASR
- Floating subtitle overlay
- Translation toggle
- Live caption session persistence

## Success criteria

A user can watch a video or meeting and see real-time subtitles while saving the transcript.

---

# Phase 3 — Notes Integration

## Goals

Convert transient captions into structured notes.

## Deliverables

- Transcript editor
- Session browser
- Search indexing
- Markdown export
- Transcript cleanup

## Success criteria

Users can reopen a prior session and search, edit, or export it.

---

# Phase 4 — Post-session Intelligence

## Goals

Improve transcript quality after recording ends.

## Deliverables

- Speaker diarization
- Batch retranscription
- Summary generation
- Keyword extraction
- Chapter segmentation

## Success criteria

Meeting or lecture transcripts become structured study notes.

---

# Phase 5 — Education and Research Workflows

## Goals

Support classroom, lecture, interview, and research scenarios.

## Deliverables

- Classroom discussion template
- Interview transcript template
- Citation export
- Timeline mode
- Dual-language transcript mode

## Success criteria

Researchers and teachers can use transcripts directly in academic workflows.

---

# Technical decisions

## Real-time ASR vs batch ASR

Real-time ASR prioritizes latency.
Batch ASR prioritizes accuracy.

The architecture should support both simultaneously.

---

## Audio source separation

Microphone and system audio should remain separate sources internally.

This enables:

- local vs remote speaker separation;
- meeting participant distinction;
- cleaner diarization.

---

## Translation policy

Translation should be optional and modular.

Core transcript storage should preserve:

- original text;
- translated text;
- timestamps;
- language metadata.

---

# Initial implementation order

1. Shared transcript model
2. Audio abstraction layer
3. Overlay prototype
4. Streaming transcript pipeline
5. Session persistence
6. Notes browser
7. Translation layer
8. Speaker diarization
9. Summary generation
