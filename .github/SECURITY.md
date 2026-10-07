# Security Policy — te-tengo-mobile-flutter

Te Tengo handles sensitive data: clips of older adults at home, alerts and family contact details. Please report problems privately and quickly.

## Supported branches

| Branch | Supported |
|---|---|
| `develop` | Yes — fixes land here first |
| `main` | Yes — receives fixes through `hotfix/*` branches |
| Older tags and feature branches | No |

## Reporting a vulnerability

**Do not open an issue or pull request** for a vulnerability or an exposed secret (API tokens, Firebase or signing keys, keystores, passwords).

The repository is private, so GitHub's *private vulnerability reporting* is not available. Instead, e-mail the maintainer, **Jhosepmyr Orlando Gutiérrez Soto** — `jhosepmyrgutierrezsoto@gmail.com`, with:

- a description of the issue and its impact;
- steps to reproduce, or the file and commit where a secret is exposed;
- relevant logs or responses, with tokens and personal data removed.

We acknowledge reports within **72 hours** and aim to fix confirmed issues within **7 days**. An exposed secret is **rotated immediately**; removing it from history comes after the rotation.

## Security practices in this repository

- **No secrets in git.** The backend URL comes from `--dart-define`; signing keystores and `key.properties` are git-ignored (`android/.gitignore`), and Firebase configuration files must stay out of the repository when push is added.
- **Session tokens** live only in `flutter_secure_storage` (Keychain / Keystore), never in plain preferences or logs.
- **The app never sends a household id**: the backend takes it from the token (except when switching households).
- **No real network calls in tests:** repositories are tested against a mocked Dio and screens against fake repositories.

## Automated scanning

| Check | Where | When |
|---|---|---|
| Dependabot version updates (pub, GitHub Actions) | [`dependabot.yml`](dependabot.yml) | Weekly, PRs to `develop` |
| OSV-Scanner on `pubspec.lock` (fails on high or critical) | [`workflows/osv-scanner.yml`](workflows/osv-scanner.yml) | Weekly, on demand, and report-only on PRs that change dependencies |
| Format, analyze, tests and coverage | [`workflows/ci.yml`](workflows/ci.yml) | Every push to `main`/`develop` and every PR |

Reports are uploaded as workflow artifacts and summarised on the run page.

## Limitations of the current plan

The `Te-Tengo-Tech` organization uses the GitHub **Free** plan with private repositories. On that plan:

- **No CodeQL / code scanning.** Code scanning and SARIF uploads require GitHub Advanced Security (GitHub Code Security), which is not available for private repositories on Free. That is why there is no `codeql.yml`; OSV-Scanner runs without it and publishes its report as an artifact instead.
- **No secret scanning or push protection** for private repositories (GitHub Secret Protection). The `.gitignore` and code review are the only guards; never commit keystores, `key.properties` or Firebase configuration files.
- **No branch protection or rulesets.** Merging into `develop` or `main` is not blocked by failing checks, so reviewers must confirm that CI is green before merging.
- **Dependabot alerts** can still be enabled under *Settings → Code security* (they use the dependency graph and are free); version updates already run from `dependabot.yml`.
