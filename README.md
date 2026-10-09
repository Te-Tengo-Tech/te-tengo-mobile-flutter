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

## Release flow
Publishing needs no manual run: merge a release into `main` and approve it, the same way a pull request is approved.

1. **Release.** Bump `version:` in `pubspec.yaml` (the `+N` build number must grow: Android refuses to install over a higher one, and Play rejects a repeated one), then merge `release/<version>` (or a `hotfix/*`) into `main`.
2. **Build.** On that push, `CI` runs on `main`, and [`release-android.yml`](.github/workflows/release-android.yml) builds the release AAB and APK.
3. **Notify the landing.** When `CI` succeeds on `main`, [`notificar-landing.yml`](.github/workflows/notificar-landing.yml) sends `repository_dispatch` `publicar-movil` to `Te-Tengo-Tech/te-tengo-landing-astro` with `{ref: <commit SHA>, version: <pubspec version>}`. The landing's `Publicar` run builds the universal APK and the PWA at that commit.
4. **Approve.** Each run that publishes stops at the **`produccion` environment** until one of its required reviewers (jhosepmyr, elmer-riva) opens the run, chooses *Review deployments*, ticks `produccion` and approves:
   - in **te-tengo-landing-astro**, `Publicar publicar-movil <version>`: one approval uploads `te-tengo.apk` to Cloudflare R2 (the landing's download) and deploys the PWA to `https://app.tetengo.reqsai.tech/`;
   - in **this repository**, `Release Android`: the `Upload to Google Play (internal)` job, only once the Play secrets exist ([docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md)).

Nothing reaches users before an approval, a failed build asks for none, and the environment only accepts `main`. The dispatch needs the secret **`DISPATCH_TOKEN`**: a fine-grained personal access token with resource owner `Te-Tengo-Tech`, access to the single repository `te-tengo-landing-astro` and the repository permission *Contents: Read and write*. Without it the workflow prints a notice and succeeds; after adding it, run *Actions → Notify the landing → Run workflow* on `main` to send the current release. The landing's [docs/DEPLOY.md](https://github.com/Te-Tengo-Tech/te-tengo-landing-astro/blob/develop/docs/DEPLOY.md) describes its side.

## Documentation
| Document | Content |
|---|---|
| [AGENTS.md](AGENTS.md) | Repository rules for people and AI agents |
| [docs/WORK_PLAN.md](docs/WORK_PLAN.md) | Ordered task checklist (stories ↔ screens) and the autonomous loop |
| [docs/API_CONTRACT.md](docs/API_CONTRACT.md) | Backend API shared with `te-tengo-general-api` |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Feature-first structure and patterns |
| [docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md) | Release AAB and universal APK, release key, sideload distribution and updates, Google Play internal testing, store policy forms and the iOS plan |
| [docs/FIREBASE.md](docs/FIREBASE.md) | Firebase project, config files, APNs key and how to test push on simulators and emulators |
| [docs/WEB_PWA.md](docs/WEB_PWA.md) | The installable web app: hosting at `https://app.tetengo.reqsai.tech/`, service worker, web push, iPhone limits and how to test |
| [docs/references/](docs/references/) | 103 prototype screens, the prototype HTML, DESIGN.md, PRODUCT.md and the product backlog (Spanish sources) |

## Claude Code in the cloud
`CLAUDE.md` imports `AGENTS.md`, a `SessionStart` hook installs Flutter 3.44.8, and the `/work` command runs the work-plan loop. Open a cloud session on this repository and type `/work`.

---

Thesis project, Software Engineering, Universidad Peruana de Ciencias Aplicadas (UPC). Authors: Jhosepmyr Gutierrez Soto and Elmer Riva Rodriguez. Atkinson Hyperlegible typeface: SIL Open Font License (`assets/fonts/OFL.txt`).
