# te-tengo-mobile-flutter

[![CI](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/ci.yml)
[![OSV-Scanner](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/osv-scanner.yml/badge.svg)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/osv-scanner.yml)
[![Release Android](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release-android.yml/badge.svg)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release-android.yml)
[![Release iOS](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release-ios.yml/badge.svg)](https://github.com/Te-Tengo-Tech/te-tengo-mobile-flutter/actions/workflows/release-ios.yml)

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
Publishing needs no manual run: merge a release into `main` and approve it, the same way a pull request is approved. Four channels can publish it, each with an on/off switch, an **organization variable** (*Te-Tengo-Tech → Settings → Secrets and variables → Actions → Variables*). A channel is on only when its variable is `true`. [docs/RELEASES.md](docs/RELEASES.md) has the job graph for each combination, every secret, the costs and how to turn each channel on.

| Channel | Switch | Published by |
|---|---|---|
| PWA at `https://app.tetengo.reqsai.tech/` | `ENABLE_PWA` | The landing, after `notificar-landing.yml` |
| APK `te-tengo.apk` (sideload, from the landing) | `ENABLE_APK` | The landing, after `notificar-landing.yml` |
| Google Play, internal testing track | `ENABLE_PLAY_STORE` | [`release-android.yml`](.github/workflows/release-android.yml) |
| TestFlight (iOS) | `ENABLE_IOS` | [`release-ios.yml`](.github/workflows/release-ios.yml) |

1. **Release.** Bump `version:` in `pubspec.yaml` (the `+N` build number must grow: Android refuses to install over a higher one, and Play and TestFlight reject a repeated one), then merge `release/<version>` (or a `hotfix/*`) into `main`.
2. **Build.** On that push, `CI` runs on `main`.
   - [`release-android.yml`](.github/workflows/release-android.yml) builds the release APK as an artifact, plus the AAB when `ENABLE_PLAY_STORE` is `true`.
   - [`release-ios.yml`](.github/workflows/release-ios.yml) builds the IPA on a macOS runner when `ENABLE_IOS` is `true`; otherwise its jobs are skipped.
   - With a switch on and its secrets missing, the run fails and names what is missing.
3. **Notify the landing.** When `CI` succeeds on `main` and `ENABLE_PWA` or `ENABLE_APK` is `true`:
   - [`notificar-landing.yml`](.github/workflows/notificar-landing.yml) sends `repository_dispatch` `publicar-movil` to `Te-Tengo-Tech/te-tengo-landing-astro` with `{ref: <commit SHA>, version: <pubspec version>}`;
   - the landing's `Publicar` run builds the channels that are on, the universal APK and/or the PWA, at that commit.
4. **Approve.** Each run that publishes stops at the **`produccion` environment** until a required reviewer (jhosepmyr, elmer-riva) approves it: open the run, choose *Review deployments*, tick `produccion` and approve.
   - In **te-tengo-landing-astro**, `Publicar publicar-movil <version>`: one approval uploads `te-tengo.apk` to Cloudflare R2 (the landing's download) and deploys the PWA to `https://app.tetengo.reqsai.tech/`.
   - In **this repository**, `Release Android`: the `Upload to Google Play (internal)` job ([docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md)).
   - In **this repository**, `Release iOS`: the `Upload to TestFlight` job.

Nothing reaches users before an approval, a failed build asks for none, and the environment only accepts `main`.

The dispatch needs the secret **`DISPATCH_TOKEN`**: a fine-grained personal access token with resource owner `Te-Tengo-Tech`, access to the single repository `te-tengo-landing-astro` and the repository permission *Contents: Read and write*. Without it the workflow prints a notice and succeeds. After adding it, run *Actions → Notify the landing → Run workflow* on `main` to send the current release. The landing's [docs/DEPLOY.md](https://github.com/Te-Tengo-Tech/te-tengo-landing-astro/blob/develop/docs/DEPLOY.md) describes its side.

## Documentation
| Document | Content |
|---|---|
| [AGENTS.md](AGENTS.md) | Repository rules for people and AI agents |
| [docs/WORK_PLAN.md](docs/WORK_PLAN.md) | Ordered task checklist (stories ↔ screens) and the autonomous loop |
| [docs/API_CONTRACT.md](docs/API_CONTRACT.md) | Backend API shared with `te-tengo-general-api` |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Feature-first structure and patterns |
| [docs/RELEASES.md](docs/RELEASES.md) | Release channels (PWA, APK, Google Play, TestFlight): on/off switches, job graph, secrets and variables, costs and how to turn each channel on; iOS signing |
| [docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md) | Release AAB and universal APK, release key, sideload distribution and updates, Google Play internal testing and store policy forms |
| [docs/FIREBASE.md](docs/FIREBASE.md) | Firebase project, config files, APNs key and how to test push on simulators and emulators |
| [docs/WEB_PWA.md](docs/WEB_PWA.md) | The installable web app: hosting at `https://app.tetengo.reqsai.tech/`, service worker, web push, iPhone limits and how to test |
| [docs/references/](docs/references/) | 103 prototype screens, the prototype HTML, DESIGN.md, PRODUCT.md and the product backlog (Spanish sources) |

## Claude Code in the cloud
`CLAUDE.md` imports `AGENTS.md`, a `SessionStart` hook installs Flutter 3.44.8, and the `/work` command runs the work-plan loop. Open a cloud session on this repository and type `/work`.

---

Thesis project, Software Engineering, Universidad Peruana de Ciencias Aplicadas (UPC). Authors: Jhosepmyr Gutierrez Soto and Elmer Riva Rodriguez. Atkinson Hyperlegible typeface: SIL Open Font License (`assets/fonts/OFL.txt`).
