# Contributing

## Branches (git flow)

| Branch | From | Merges into | Use |
|---|---|---|---|
| `feature/<feature>-<topic>` | `develop` | `develop` | New work, e.g. `feature/alertas-detalle` |
| `bugfix/<feature>-<topic>` | `develop` | `develop` | Fixes found during development |
| `hotfix/<version>` | `main` | `main`, then `develop` through the back-merge pull request | Urgent fixes to a release, e.g. `hotfix/0.2.1` |
| `release/<version>` | `develop` | `main`, then `develop` through the back-merge pull request | A release, e.g. `release/0.3.0`; its pushes run the release pipeline ([docs/RELEASES.md](docs/RELEASES.md)) |

`main` only receives releases and hotfixes. Branch prefixes follow git flow; commit messages keep their Conventional Commit types (`feat:`, `fix:`, `ci:`, `docs:` …).

## Workflow

1. **Branch from `develop`** with one of the prefixes above.
2. **Before pushing:** `dart format lib test`, `flutter analyze` (no issues) and `flutter test`. Golden tests are generated on Linux, so they may fail on macOS; CI is the reference for them.
3. **Commits:** [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) in English, **no co-author line**. Example: `feat(sesion): sign-in with lockout message (US-02)`.
4. **Pull request to `develop`** using the template: it lists the definition of done from [AGENTS.md](AGENTS.md).
5. **CI must be green before merging.** The rulesets `proteger-develop` and `proteger-main` require a pull request with one approval and the `Format and analyze` and `Tests and coverage` checks, and block force-pushes and deletions.

## Continuous integration

| Workflow | Trigger | Jobs |
|---|---|---|
| [CI](.github/workflows/ci.yml) | Push to `main`/`develop`/`release/*`/`hotfix/*`, every PR | `Format and analyze` (`dart format`, `flutter analyze`); `Tests and coverage` (`flutter test --coverage`, lcov artifact, coverage per feature on the run page, golden diffs uploaded on failure); `Web (PWA)` (the reusable [Build PWA](.github/workflows/build-web.yml): `flutter build web --base-href /` with the Firebase web config from repository variables, `te-tengo-web` artifact; [docs/WEB_PWA.md](docs/WEB_PWA.md)) |
| [OSV-Scanner](.github/workflows/osv-scanner.yml) | Weekly, manual, PRs that change `pubspec.*` | Scans `pubspec.lock`; scheduled runs fail on high or critical |
| [Release](.github/workflows/release.yml) | Push to `release/*` or `hotfix/*`; PRs that change `android/`, `pubspec.*`, `release.yml` or `build-apk.yml` (APK/AAB build check only) | Build once (signed APK through the reusable [Build APK](.github/workflows/build-apk.yml), PWA through [Build PWA](.github/workflows/build-web.yml), AAB with `ENABLE_PLAY_STORE`, IPA with `ENABLE_IOS`); then `Staging · PWA`/`APK` after an approval on `staging` (`ENABLE_STAGING`); then `Produccion · PWA`/`APK`/`Google Play`/`TestFlight` after an approval on `produccion`, each with its switch and a smoke check; finally opens the pull request `release: x.y.z` to `main` ([docs/RELEASES.md](docs/RELEASES.md)) |
| [Tag the release](.github/workflows/etiquetar.yml) | Push to `main` | Tag `vx.y.z` and GitHub Release from `CHANGELOG.md` (skipped if the tag exists); back-merge pull request `main` → `develop`. No deploys |

A new push cancels the superseded CI run of the same branch. Dependabot opens weekly update PRs to `develop`.

## Community

- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Security policy](.github/SECURITY.md)
