# te-tengo-mobile-flutter

[![CI](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/ci.yml)
[![OSV-Scanner](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/osv-scanner.yml/badge.svg)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/osv-scanner.yml)
[![Release](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release.yml/badge.svg)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release.yml)

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

## Release flow
Build once, deploy the same files to **staging** and then to **produccion**, both from the release branch; `main` and the tag come last. Everything runs from this repository: [`release.yml`](.github/workflows/release.yml) on a push to `release/x.y.z` or `hotfix/x.y.z`, and [`etiquetar.yml`](.github/workflows/etiquetar.yml) on `main`. [docs/RELEASES.md](docs/RELEASES.md) has the channels × stages × switches table, every secret and variable, the costs and how to turn each channel on.

| Channel | Staging | Produccion | Switch |
|---|---|---|---|
| PWA (Cloudflare Pages `te-tengo-app`) | `https://staging.te-tengo-app.pages.dev` | `https://app.tetengo.reqsai.tech` | `ENABLE_PWA` |
| APK `te-tengo.apk` (R2 `te-tengo-descargas`, linked from the landing) | `staging/te-tengo.apk` | `te-tengo.apk` | `ENABLE_APK` |
| Google Play, internal testing track | — | AAB upload | `ENABLE_PLAY_STORE` |
| TestFlight (iOS) | — | IPA upload | `ENABLE_IOS` |

The switches are **organization variables**, on only when exactly `true`; `ENABLE_STAGING` switches the whole staging stage.

1. **Release branch.** Branch `release/<x.y.z>` from `develop` (or `hotfix/<x.y.z>` from `main`) and bump `version:` in `pubspec.yaml` to `x.y.z+N`. The build number `N` must grow: Android refuses to install over a higher one, and Play and TestFlight reject a repeated one. Push it.
2. **Build.** `release.yml` checks the configuration of every channel that is on (a missing secret is an error that names it), then builds the signed APK, the PWA and, when switched on, the AAB and the IPA. The run summary shows the plan: what each stage will do, or which switch skips it.
3. **Staging.** The `Staging · …` jobs wait for an approval on the **`staging` environment**, deploy the same artifacts and smoke-check them.
4. **Produccion.** The `Produccion · …` jobs then wait for an approval on the **`produccion` environment**, publish and smoke-check. To approve: open the run, *Review deployments*, tick the environment and approve (required reviewers: jhosepmyr, elmer-riva). One approval covers every job of a stage.
5. **Pull request to `main`.** The last job opens `release: x.y.z` (`release/x.y.z` → `main`) listing what was deployed where. Merge it after review.
6. **Tag.** On `main`, `etiquetar.yml` tags `vx.y.z`, creates the GitHub Release from the `CHANGELOG.md` section and opens the back-merge pull request `main` → `develop`. Nothing is deployed from `main`.

Nothing reaches users before an approval, and a failed build or staging check stops the run before produccion. Cloudflare needs the secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` (token permissions *Account → Cloudflare Pages: Edit* and *Workers R2 Storage: Edit*).

## Documentation
| Document | Content |
|---|---|
| [AGENTS.md](AGENTS.md) | Repository rules for people and AI agents |
| [docs/WORK_PLAN.md](docs/WORK_PLAN.md) | Ordered task checklist (stories ↔ screens) and the autonomous loop |
| [docs/API_CONTRACT.md](docs/API_CONTRACT.md) | Backend API shared with `te-tengo-general-api` |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Feature-first structure and patterns |
| [docs/RELEASES.md](docs/RELEASES.md) | Release pipeline: channels (PWA, APK, Google Play, TestFlight) × stages (staging, produccion) × switches, job graph, secrets and variables, costs and how to turn each channel on; iOS signing |
| [docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md) | Release AAB and universal APK, release key, sideload distribution and updates, Google Play internal testing and store policy forms |
| [docs/FIREBASE.md](docs/FIREBASE.md) | Firebase project, config files, APNs key and how to test push on simulators and emulators |
| [docs/WEB_PWA.md](docs/WEB_PWA.md) | The installable web app: hosting at `https://app.tetengo.reqsai.tech/`, service worker, web push, iPhone limits and how to test |
| [docs/references/](docs/references/) | 103 prototype screens, the prototype HTML, DESIGN.md, PRODUCT.md and the product backlog (Spanish sources) |

## Claude Code in the cloud
`CLAUDE.md` imports `AGENTS.md`, a `SessionStart` hook installs Flutter 3.44.8, and the `/work` command runs the work-plan loop. Open a cloud session on this repository and type `/work`.

---

Thesis project, Software Engineering, Universidad Peruana de Ciencias Aplicadas (UPC). Authors: Jhosepmyr Gutierrez Soto and Elmer Riva Rodriguez. Atkinson Hyperlegible typeface: SIL Open Font License (`assets/fonts/OFL.txt`).
