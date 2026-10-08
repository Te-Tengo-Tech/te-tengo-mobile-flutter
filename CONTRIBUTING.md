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
5. **CI must be green before merging.** The organization is on the GitHub Free plan, where branch protection is not enforced for private repositories: nothing blocks a merge with failing checks, so **reviewers must open the checks tab and confirm every job passed** before merging.

## Continuous integration

| Workflow | Trigger | Jobs |
|---|---|---|
| [CI](.github/workflows/ci.yml) | Push to `main`/`develop`, every PR | `Format and analyze` (`dart format`, `flutter analyze`); `Tests and coverage` (`flutter test --coverage`, lcov artifact, coverage per feature on the run page, golden diffs uploaded on failure) |
| [OSV-Scanner](.github/workflows/osv-scanner.yml) | Weekly, manual, PRs that change `pubspec.*` | Scans `pubspec.lock`; scheduled runs fail on high or critical |
| [Release Android](.github/workflows/release-android.yml) | Manual, tags `mobile-v*`, PRs that change `android/` or `pubspec.*` | Builds the release AAB (artifact); on manual runs and tags uploads it to Google Play's internal track when the signing and Play secrets exist, otherwise skips with a notice ([docs/RELEASE_ANDROID.md](docs/RELEASE_ANDROID.md)) |

A new push cancels the superseded CI run of the same branch. Dependabot opens weekly update PRs to `develop`.

## Community

- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Security policy](.github/SECURITY.md)
