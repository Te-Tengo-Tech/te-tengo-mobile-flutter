# te-tengo-mobile-flutter

[![CI](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/ci.yml)
[![OSV-Scanner](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/osv-scanner.yml/badge.svg)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/osv-scanner.yml)
[![Release Android](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release-android.yml/badge.svg)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release-android.yml)

**Te Tengo** mobile app for family members and caregivers: fall and unstable-movement alerts, the event clip, live view, camera, consent, family and history.

| Stack | Version |
|---|---|
| Flutter | 3.44.8 (Dart 3.12) |
| State and navigation | Riverpod 3 · go_router 18 |
| HTTP | Dio 5 |

## Getting started
```bash
flutter pub get
flutter run --dart-define=TT_API_URL=http://10.0.2.2:8080   # local backend from the Android emulator
```

## Quality
```bash
dart format lib test
flutter analyze
flutter test --coverage   # coverage/lcov.info
```

## Documentation
| Document | Content |
|---|---|
| [AGENTS.md](AGENTS.md) | Repository rules for people and AI agents |
| [docs/WORK_PLAN.md](docs/WORK_PLAN.md) | Ordered task checklist (stories ↔ screens) and the autonomous loop |
| [docs/API_CONTRACT.md](docs/API_CONTRACT.md) | Backend API shared with `te-tengo-general-api` |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Feature-first structure and patterns |
| [docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md) | Release AAB and universal APK, release key, sideload distribution and updates, Google Play internal testing, store policy forms and the iOS plan |
| [docs/FIREBASE.md](docs/FIREBASE.md) | Firebase project, config files, APNs key and how to test push on simulators and emulators |
| [docs/references/](docs/references/) | 103 prototype screens, the prototype HTML, DESIGN.md, PRODUCT.md and the product backlog (Spanish sources) |

## Claude Code in the cloud
`CLAUDE.md` imports `AGENTS.md`, a `SessionStart` hook installs Flutter 3.44.8, and the `/work` command runs the work-plan loop. Open a cloud session on this repository and type `/work`.

---

Thesis project, Software Engineering, Universidad Peruana de Ciencias Aplicadas (UPC). Authors: Jhosepmyr Gutierrez Soto and Elmer Riva Rodriguez. Atkinson Hyperlegible typeface: SIL Open Font License (`assets/fonts/OFL.txt`).
