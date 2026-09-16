# SpeakLoop implementation report

## Delivered

- Three structured English/Spanish lessons with selectable prompts and pronunciation tips
- Optional microphone capture, playback, permission-denial fallback, and disposable recordings
- Honest three-level self-rating with explicit copy that no automated pronunciation score is produced
- Optional notes and local practice history persisted with SharedPreferences
- Repository, controller, domain model, recording service, and widget concerns kept separate
- Responsive warm paper/coral/teal notebook interface for narrow and desktop widths
- Semantic labels, keyboard-focusable controls, validation copy, and an empty progress state
- Project README, MIT license, and GitHub Actions checks for analysis, tests, and web build
- Persist-before-state saving that preserves the rating and note when browser storage fails
- Recorder lifecycle cleanup when saving or changing prompts, with stop/playback failure handling

## Verification

Run on September 16, 2026 with Flutter 3.47.0 pre-release and Dart 3.14.0:

| Command | Result |
| --- | --- |
| `flutter analyze` | Passed, no issues found |
| `flutter test` | Passed, 12 tests |
| `flutter build web` | Passed, production bundle written to `build/web` |

Tests cover lesson invariants, prompt transitions and note cleanup, required self-rating validation, successful and failed persistence, SharedPreferences replay, malformed persisted data, active and pending recording cancellation, playback failure recovery, and first-viewport activity content. CI is pinned to Flutter 3.44.0, matching the lockfile's minimum Flutter release and Dart 3.13 SDK floor.

## Local preview

```bash
flutter pub get
flutter run -d chrome
```

Flutter selects and prints an available localhost port. No fixed port is required.

## Limitations

- Recording requires browser support, microphone permission, and a secure context such as localhost or HTTPS.
- Audio is deliberately temporary and is not restored after refresh or written into practice history.
- History is local to one browser profile and has no account or cloud sync.
- The lesson catalog is synthetic and intentionally compact; it is not a complete curriculum.
- Visual browser QA is owned by the parent task and is not included in this source-only delivery.
