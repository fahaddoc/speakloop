# SpeakLoop

SpeakLoop is a small, local-first Spanish speaking practice app. Choose a structured lesson, rehearse a phrase, optionally record and play back your voice, then save an honest self-rating. It does not generate pronunciation scores or claim to analyse speech.

This is an independent portfolio demonstration. It is not affiliated with Everis or presented as an Everis product.

## Run locally

Install [Flutter](https://docs.flutter.dev/get-started/install) with web support, then run:

```bash
flutter pub get
flutter run -d chrome
```

Flutter prints the local preview URL and port. To make a production bundle:

```bash
flutter build web
```

## Verify

```bash
flutter analyze
flutter test
flutter build web
```

## What is included

- Three bilingual English/Spanish lessons with three prompts each
- Optional web-compatible microphone recording, playback, and discard controls
- A complete practice flow when microphone access is denied or unsupported
- Three explicit self-rating choices and an optional private note
- Practice history persisted in browser storage with `shared_preferences`
- Responsive layouts for narrow phones and wide desktop screens
- Keyboard-focusable controls and semantic labels for lesson, prompt, and rating choices

## Architecture

`lib/features/lessons` contains the immutable lesson catalog. `lib/features/practice` owns practice state, recording state, and the responsive screen. `lib/features/progress` owns saved-entry data and its presentation. `lib/data` defines the persistence boundary and its SharedPreferences implementation. Widgets depend on the controller; the controller depends on the repository interface.

## Privacy and limitations

Audio is temporary and is never written to practice history. The browser may keep a recording blob in memory until it is discarded, replaced, or the page closes. Practice history remains in that browser profile and is not synced. Clearing site data removes it. Microphone behavior depends on browser support, a secure context, and user permission. The included content is a compact demonstration rather than a full language curriculum.

The implementation was developed with AI assistance and reviewed through automated tests, static analysis, and a production web build.

## License

MIT. See [LICENSE](LICENSE).
