## What and why

<!-- What does this pull request change, and why? -->

**Feature:** <!-- sesion | hogar | camaras | alertas | vivo | historial | familia | ajustes | inicio | arranque | core | app | build | ci | docs -->

**Story / task:** <!-- e.g. US-07, WORK_PLAN T12. Closes #… -->

**Screens:** <!-- e.g. 23-alerta-caida.png -->

## Type of change

- [ ] `feat` — new feature
- [ ] `fix` — bug fix
- [ ] `refactor` — no behavior change
- [ ] `test` — tests only
- [ ] `docs` — documentation only
- [ ] `build` / `ci` / `chore` — dependencies, build, CI or maintenance

## Definition of done

- [ ] The pull request targets `develop` (not `main`), from a `feature/*` or `bugfix/*` branch (`hotfix/*` targets `main`)
- [ ] The screens match their PNG references in `docs/references/screens/` (layout, order, states and Spanish copy)
- [ ] API calls match [`docs/API_CONTRACT.md`](../docs/API_CONTRACT.md) exactly; contract changes are mirrored in the backend
- [ ] Every acceptance criterion is covered by a widget or unit test (fake repositories, no real network)
- [ ] `dart format lib test`, `flutter analyze` (no issues) and `flutter test` pass locally
- [ ] Accessibility: text ≥ 16, targets ≥ 44 px, status never shown by color alone, `disableAnimations` honored
- [ ] Conventional Commits in English, with no co-author line
- [ ] The task is checked off in [`docs/WORK_PLAN.md`](../docs/WORK_PLAN.md) and `CHANGELOG.md` is updated
- [ ] No secrets, tokens or personal data are committed
- [ ] CI is green (branch protection is not enforced on our plan: reviewers check it before merging)

## Screenshots

<!-- Before / after on a phone-sized screen, if the UI changed. -->

## How to test

<!-- Steps a reviewer can follow, e.g. flutter run --dart-define=TT_API_URL=... -->
