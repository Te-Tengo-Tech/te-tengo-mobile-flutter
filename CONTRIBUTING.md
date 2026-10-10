# Contributing

## Branches (git flow)

| Branch | From | Merges into | Use |
|---|---|---|---|
| `feature/<feature>-<topic>` | `develop` | `develop` | New work, e.g. `feature/alertas-detalle` |
| `bugfix/<feature>-<topic>` | `develop` | `develop` | Fixes found during development |
| `hotfix/<version>` | `main` | `main`, then `develop` through the back-merge pull request | Urgent fixes to a release, e.g. `hotfix/0.2.1`; same pipeline as a release |
| `release/<version>` | `develop` | `main`, then `develop` through the back-merge pull request | A release, e.g. `release/0.3.0`; each push builds a release candidate `v0.3.0-rc.N` and deploys it to staging ([docs/RELEASES.md](docs/RELEASES.md)) |

`main` only receives releases and hotfixes, and every push to it must match a tested candidate: produccion fails otherwise. A bug found in QA is fixed on the release branch (directly or with a `bugfix/*` branch from it), which builds the next candidate; a bug found in production is a `hotfix/x.y.(z+1)` from `main`. Do not bump the `+N` build number for each candidate: the pipeline computes it. Branch prefixes follow git flow; commit messages keep their Conventional Commit types (`feat:`, `fix:`, `ci:`, `docs:` …).

## Workflow

1. **Branch from `develop`** with one of the prefixes above.
2. **Before pushing:** `dart format lib test`, `flutter analyze` (no issues) and `flutter test`. Golden tests are generated on Linux, so they may fail on macOS; CI is the reference for them.
3. **Commits:** [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) in English, **no co-author line**. Example: `feat(sesion): sign-in with lockout message (US-02)`.
4. **Pull request to `develop`** using the template: it lists the definition of done from [AGENTS.md](AGENTS.md).
5. **CI must be green before merging.** The rulesets `proteger-develop` and `proteger-main` require a pull request with one approval and the `ci-ok` and `pr-title` checks (`release-gate` too on `main`), and block force-pushes and deletions. The pull request title is a Conventional Commit: a squash merge makes it the commit on `develop`.

## Continuous integration

| Workflow | Trigger | Jobs |
|---|---|---|
| [CI](.github/workflows/ci.yml) | Push to `develop`, every PR (only `ci-ok` on PRs into `main`); called by Release on each candidate commit | `Format and analyze` (`dart format`, `flutter analyze`); `Tests and coverage` (`flutter test --coverage`, lcov artifact, coverage per feature on the run page, golden diffs uploaded on failure); `Web (PWA)` (the reusable [Build PWA](.github/workflows/build-web.yml): `flutter build web --base-href /` with the Firebase web config from repository variables, `te-tengo-web` artifact; [docs/WEB_PWA.md](docs/WEB_PWA.md)); `ci-ok`, the single required CI check |
| [PR title](.github/workflows/pr-title.yml) | Every PR | `pr-title`: the title is a Conventional Commit |
| [Release gate](.github/workflows/release-gate.yml) | PRs into `main` | `release-gate`: merging puts into `main` the tree of a candidate that passed staging ([docs/RELEASES.md](docs/RELEASES.md#release-gate)) |
| [OSV-Scanner](.github/workflows/osv-scanner.yml) | Weekly, manual, PRs that change `pubspec.*` | Scans `pubspec.lock`; scheduled runs fail on high or critical |
| [Release](.github/workflows/release.yml) | Push to `release/*` or `hotfix/*`; PRs (not into `main`) that change `android/`, `pubspec.*`, `release.yml` or `build-apk.yml` (debug-signed APK build check, no secrets) | CI on the commit, then build once with a computed build number (APK signed in the environment `firma` through the reusable [Build APK](.github/workflows/build-apk.yml), PWA through [Build PWA](.github/workflows/build-web.yml), AAB with `ENABLE_PLAY_STORE`, IPA with `ENABLE_IOS`); store them, with an SBOM and attestations, as the pre-release `vx.y.z-rc.N`; `Staging · PWA`/`APK` after an approval on `staging` (`ENABLE_STAGING`), with a smoke check; then the release bot opens or updates the pull request `release: x.y.z` to `main` ([docs/RELEASES.md](docs/RELEASES.md)) |
| [Produccion](.github/workflows/produccion.yml) | Push to `main` | Find the approved candidate whose git tree equals `main`'s (fail otherwise); `Produccion · PWA`/`APK`/`Google Play`/`TestFlight` with its files after an approval on `produccion`, each with its switch and a smoke check; only if at least one channel was published and none failed, the GitHub Release `vx.y.z` with the same assets, then the back-merge pull request `main` → `develop` (release bot) |
| [Rollback](.github/workflows/rollback.yml) | Manual (`version`), from `main` | Republish the PWA (and optionally the APK) of an earlier final release after an approval on `produccion`; no build |

A new push cancels the superseded CI run of the same branch. Dependabot opens weekly update PRs to `develop` (pub, Gradle, GitHub Actions); every action is pinned by commit SHA.

## Community

- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Security policy](.github/SECURITY.md)
