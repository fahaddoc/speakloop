# SpeakLoop Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development to implement this task.

**Goal:** Build the working SpeakLoop portfolio demo.
**Architecture:** Separate domain rules, persistence/transport and view components. Keep dependencies small and execution local.
**Tech Stack:** Flutter + Dart, shared_preferences, record and audioplayers as needed
**Spec:** docs/design.md

## Global Constraints
- Work only in this repository, on codex/portfolio-build.
- Original independent demo; no private employment, applicant or salary data.
- Source deliverable to GitHub; no hosted Sites service or production deployment.
- Local Node APIs bind to 127.0.0.1, validate requests, use parameterized SQL, enforce body-size limits and do not enable broad CORS.
- Synthetic seed data, graceful errors, no fake AI outputs.

### Task 1: Working SpeakLoop application

**Files:** package.json and lockfile, src/main.tsx, src/App.tsx, src/styles.css, src/domain.ts, src/components/, server/ and tests/ for Node apps; pubspec.yaml, lib/features/, lib/data/, test/ for Flutter instead.
**Interface:** Independently runnable app. Web projects expose npm run dev, npm run build, npm test; backend API under /api proxied by Vite. Flutter exposes flutter run -d chrome, flutter test, flutter analyze and flutter build web.

- [ ] Write and run failing meaningful tests for domain state transitions, invalid/empty input, and persistence or stream replay as relevant.
- [ ] Implement this exact product flow: Local language practice app with at least three structured English/Spanish lessons, prompt selection, optional microphone recording/playback with denial handling and disposable recordings, honest self-rating, persisted practice history and progress. No fake AI pronunciation scores. Use Flutter web-compatible implementation and responsive phone/desktop layout; warm paper/coral/teal language notebook. Feature folders lessons/practice/progress; repository and controller separate from widgets.
- [ ] Add a complete responsive user interface whose first viewport exposes the activity. Keep form drafts after errors. Add useful empty states and keyboard focus.
- [ ] Run tests, type checks/analyzer and production build; fix failures. Do not automate browser outside cua_repl; parent handles UI visual QA.
- [ ] Write README with exact startup commands, architecture and limitations; add MIT license, CI workflow for tests/build, and .env.example only if needed. Do not claim metrics/users or human-only authorship.
- [ ] Commit implementation and write docs/implementation-report.md with changes, commands and results, limitations and local preview command/port. Do not publish or spawn subagents; parent owns review/publication.
