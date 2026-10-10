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
Gitflow with release candidates and the tag at the end ([docs/RELEASES.md](docs/RELEASES.md) has the diagrams, job graphs, switches, secrets, costs and how to turn each channel on). `develop` deploys nothing.

| Channel | Staging (from `release/*`, `hotfix/*`) | Produccion (from `main`) | Switch |
|---|---|---|---|
| PWA (Cloudflare Pages `te-tengo-app`) | `https://staging.te-tengo-app.pages.dev` | `https://app.tetengo.reqsai.tech` | `ENABLE_PWA` |
| APK `te-tengo.apk` (R2 `te-tengo-descargas`, linked from the landing) | `staging/te-tengo.apk` | `te-tengo.apk` | `ENABLE_APK` |
| Google Play, internal testing track | — | the candidate's AAB | `ENABLE_PLAY_STORE` |
| TestFlight (iOS) | — | the candidate's IPA | `ENABLE_IOS` |

The switches are **organization variables**, on only when exactly `true`; `ENABLE_STAGING` switches the whole staging stage.

1. **Release branch.** Branch `release/<x.y.z>` from `develop` (or `hotfix/<x.y.z>` from `main`), set `version:` in `pubspec.yaml` to `x.y.z+N` and push it. Leave `+N` alone: the pipeline computes the build number of each candidate (higher than every earlier one) and passes it with `--build-number`; `+N` is only a floor.
2. **Candidate.** [`release.yml`](.github/workflows/release.yml) runs CI on the commit (each commit is tested once), checks the configuration of every channel that is on, builds the signed APK, the PWA and, when switched on, the AAB and the IPA **once**, and stores them as the GitHub pre-release **`vx.y.z-rc.N`** with their SHA-256 sums, an SBOM, provenance attestations, commit and git tree. The signing secrets live in the environment **`firma`**, which pull requests never reach.
3. **Staging.** After an approval on the **`staging` environment**, the candidate's PWA and APK are deployed and smoke-checked. A bug found in QA is fixed on the release branch; the next push builds `rc.N+1`.
4. **Pull request to `main`.** When staging passes, the release bot opens `release: x.y.z` (or updates it to the new candidate). The required check `release-gate` turns green only when merging puts into `main` the tree of a candidate that passed staging. Merge it after review, with a merge commit.
5. **Produccion.** On `main`, [`produccion.yml`](.github/workflows/produccion.yml) finds the approved candidate whose git tree equals `main`'s (or fails) and, after an approval on the **`produccion` environment**, publishes **the same files** to the PWA, R2, Google Play and TestFlight, without rebuilding. Required reviewers: jhosepmyr, elmer-riva.
6. **Tag.** Only if at least one channel was published and none failed: the GitHub Release **`vx.y.z`** with the same assets and the `CHANGELOG.md` section, then the back-merge pull request `main` → `develop` (release bot, auto-merge). A failed channel leaves no tag; *Re-run failed jobs* publishes the same candidate again. With every channel switched off there is no tag.

[`rollback.yml`](.github/workflows/rollback.yml) republishes the files of an earlier `vx.y.z` after an approval. Cloudflare needs the secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` of the environments `staging` and `produccion` (token permissions *Account → Cloudflare Pages: Edit* and *Workers R2 Storage: Edit*).

## Documentation
| Document | Content |
|---|---|
| [AGENTS.md](AGENTS.md) | Repository rules for people and AI agents |
| [docs/WORK_PLAN.md](docs/WORK_PLAN.md) | Ordered task checklist (stories ↔ screens) and the autonomous loop |
| [docs/API_CONTRACT.md](docs/API_CONTRACT.md) | Backend API shared with `te-tengo-general-api` |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Feature-first structure and patterns |
| [docs/RELEASES.md](docs/RELEASES.md) | Release pipeline: release candidates, staging from the release branch, produccion from `main`, tag at the end and rollback; channels (PWA, APK, Google Play, TestFlight) × switches, job graphs, build number, secrets and variables, costs and how to turn each channel on; iOS signing |
| [docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md) | Release AAB and universal APK, release key, sideload distribution and updates, Google Play internal testing and store policy forms |
| [docs/FIREBASE.md](docs/FIREBASE.md) | Firebase project, config files, APNs key and how to test push on simulators and emulators |
| [docs/WEB_PWA.md](docs/WEB_PWA.md) | The installable web app: hosting at `https://app.tetengo.reqsai.tech/`, service worker, web push, iPhone limits and how to test |
| [docs/references/](docs/references/) | 103 prototype screens, the prototype HTML, DESIGN.md, PRODUCT.md and the product backlog (Spanish sources) |

## Claude Code in the cloud
`CLAUDE.md` imports `AGENTS.md`, a `SessionStart` hook installs Flutter 3.44.8, and the `/work` command runs the work-plan loop. Open a cloud session on this repository and type `/work`.

---

Thesis project, Software Engineering, Universidad Peruana de Ciencias Aplicadas (UPC). Authors: Jhosepmyr Gutierrez Soto and Elmer Riva Rodriguez. Atkinson Hyperlegible typeface: SIL Open Font License (`assets/fonts/OFL.txt`).
