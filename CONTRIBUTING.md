# Contributing

## Branches (git flow)

| Branch | From | Merges into | Use |
|---|---|---|---|
| `feature/<feature>-<topic>` | `develop` | `develop` | New work, e.g. `feature/alertas-detalle` |
| `bugfix/<feature>-<topic>` | `develop` | `develop` | Fixes found during development |
| `hotfix/<topic>` | `main` | `main` **and** `develop` | Urgent fixes to a release |
| `release/<version>` | `develop` | `main` and `develop` | Release preparation (no releases are cut yet) |

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
| [CI](.github/workflows/ci.yml) | Push to `main`/`develop`, every PR | `Format and analyze` (`dart format`, `flutter analyze`); `Tests and coverage` (`flutter test --coverage`, lcov artifact, coverage per feature on the run page, golden diffs uploaded on failure); `Web (PWA)` (`flutter build web --base-href /` with the Firebase web config from repository variables, `te-tengo-web` artifact; [docs/WEB_PWA.md](docs/WEB_PWA.md)) |
| [OSV-Scanner](.github/workflows/osv-scanner.yml) | Weekly, manual, PRs that change `pubspec.*` | Scans `pubspec.lock`; scheduled runs fail on high or critical |
| [Release Android](.github/workflows/release-android.yml) | Push to `main` (a release), manual, PRs that change `android/` or `pubspec.*` | Builds the release AAB and, through the reusable [Build APK](.github/workflows/build-apk.yml) (also called by the landing's publish workflow), the universal APK `te-tengo.apk` for sideloading. Both are kept as artifacts, debug-signed with a notice when the key secrets are missing. On `main`, when the signing and Play secrets exist, the `Upload to Google Play (internal)` job waits for an approval on the `produccion` environment and then uploads the AAB; otherwise it is skipped with a notice ([docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md)) |
| [Notify the landing](.github/workflows/notificar-landing.yml) | `CI` succeeded on a push to `main`; manual from `main` | Sends `repository_dispatch` `publicar-movil` with `{ref: <commit SHA>, version: <pubspec version>}` to `te-tengo-landing-astro`, whose `publicar.yml` builds the APK and the PWA and publishes them after approval. Needs the `DISPATCH_TOKEN` secret; without it, a notice ([README](README.md#release-flow)) |

A new push cancels the superseded CI run of the same branch. Dependabot opens weekly update PRs to `develop`.

## Community

- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Security policy](.github/SECURITY.md)
