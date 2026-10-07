# Work plan

The app is built task by task from this checklist, in backlog-sprint order. An agent working autonomously follows **the loop** below until every task is checked or only blocked tasks remain.

## The loop
1. **Sync:** `git pull --rebase` if a remote branch exists. Read `AGENTS.md`, this file and `docs/BLOCKERS.md`.
2. **Pick** the first unchecked task (`- [ ]`).
3. **Read:**
   - its stories and criteria in `docs/references/PRODUCT_BACKLOG.md`;
   - its endpoints in `docs/API_CONTRACT.md`;
   - **open every PNG listed** in `docs/references/screens/`, and find the same screens in `docs/references/prototype/prototipo.html` for the exact Spanish copy.
4. **Implement** the feature (`data/`, `domain/`, `presentation/`, routes), copying the structure of `lib/features/camaras`. Repositories call the backend exactly as the contract says.
5. **Test:**
   - widget tests per acceptance criterion with a fake repository;
   - unit tests for JSON parsing and repository error mapping, with a mocked Dio adapter.
6. **Verify:** `dart format lib test`, `flutter analyze` (no issues) and `flutter test` must pass. Never skip or weaken a test.
7. **Record:** check the task as `- [x]` here and add a line under `[Unreleased]` in `CHANGELOG.md`.
8. **Commit:** one Conventional Commit in English, no co-author line, e.g. `feat(sesion): sign-in with lockout message (US-02)`. Then **push**.
9. **Next:** go back to step 2 **without waiting for confirmation**.

**When something is missing,** such as a Firebase project or a contract change:
- write it in `docs/BLOCKERS.md`;
- implement behind an interface with a fake;
- mark the task `- [~]` with a note, and continue.

**Stop only** when no `- [ ]` remains. Then:
- run everything once more;
- update the status table in `docs/ARCHITECTURE.md`;
- open or update a pull request with a summary and the blockers.

> The screen ↔ story mapping was inferred from the screen file names; confirm it by opening the images.

## Tasks

### Foundation
- [x] **T01 App shell.**
  - Bottom navigation with 4 tabs (Inicio, Historial, Familia, Ajustes; DESIGN.md "Components").
  - Splash screen 00 with the logo animation, a static final frame when `disableAnimations` is on.
  - Router guards: no session → welcome or sign-in; session without household → onboarding.
- [x] **T02 Session state.**
  - A `SesionController` (Riverpod) holding the `Sesion` from the contract.
  - Token refresh on `401 SESION_EXPIRADA` through a Dio interceptor.
  - Household switching (`GET /api/hogares`, `POST /api/sesiones/hogar`).
  - A shared widget for `ProblemaApi` messages.

### Sprint 3
- [x] **T03 US-01 Register:** screens 01–05. `POST /api/cuentas`; field highlighting from `400 VALIDACION.campos`; `409 CORREO_EN_USO`.
- [x] **T04 US-02 Sign in and sign out:** screens 06–08 and 13. `POST /api/sesiones`; `423 CUENTA_BLOQUEADA` shows the unlock time; `DELETE /api/sesiones/actual`.
- [x] **T05 US-03 Password recovery:** screens 09–12. Generic message (`202`); `410 ENLACE_VENCIDO`; deep link for the reset token.
- [x] **T06 US-04 Older adult profile:** screens 14, 15 and 95. `POST /api/hogar` (stores the returned `Sesion`); `convivencia` options from the contract; `409 HOGAR_YA_REGISTRADO`.
- [x] **T07 US-05 Consent:** screens 16–18, 22 and 102. Both checkboxes are required; certificate with date and time and Law No. 29733; banner «sin consentimiento» on home.
- [x] **T08 US-06 Camera and room name:** screens 19–21 and 32. Extend `features/camaras` to the full screens; renaming is owner-only (`403 SOLO_TITULAR` and read-only UI).
- [x] **T09 US-08 Invite during onboarding:** screens 23 and 24. `POST /api/invitaciones`.
- [x] **T10 Home:** screens 25–27.
  - Older adult status card with the color band.
  - Camera row and «Ver en vivo» row.
  - Banners for disabled notifications (CA-16.3) and no internet.
- [x] **T11 US-07 Connection status:** screens 28–31. Status with icon and text; «what to check» (cable, PC on, internet); reconnected notice.
- [x] **T12 Push foundation (US-16 CA-16.2):**
  - A `NotificacionesPush` interface with a fake implementation.
  - Device registration (`POST` and `DELETE /api/dispositivos`).
  - Routing from push `tipo` (contract §7) to screens.
  - The `firebase_messaging` implementation goes behind the interface. Real setup is blocked until a Firebase project exists; see BLOCKERS.
- [x] **T13 US-16 Fall alert:** screens 44–48.
  - Full-screen red alert: room, time, elapsed time, call button, «Qué hacer ahora».
  - An active alert is visible on open even if the push failed (CA-16.4).
- [x] **T14 US-13 Confirmation chip:** screen 46. «Comprobando si sigue en el suelo» → «Sigue en el suelo · confirmada».
- [x] **T15 US-17 Unstable movement:** screens 49–52. Amber, medium severity; never shares color, icon or label with a fall; update when it becomes a fall (CA-17.3).
- [x] **T16 US-18 Clip:** screens 47 and 53. `GET /api/alertas/{id}/clip` with `video_player`; «video no disponible» on `404`.

### Sprint 4
- [x] **T17 US-09 Revoke consent:** screens 97–101. Confirmation step (CA-09.2); deletion in progress and done.
- [x] **T18 US-19 Mark alert:** screens 55, 56, 60 and 61. Bottom sheet with «Atendida» or «Falsa alarma»; shows who attended and when.
- [x] **T19 US-25 History:** screens 83–88. `GET /api/alertas` with filters; empty state «Sin eventos registrados»; loading state.
- [x] **T20 US-10 Alert order and wait time:** screens 62–65 and 72. 3, 5 (default) or 10 min; single-member case.
- [x] **T21 US-20 Escalation views:** screens 58 and 59.
- [x] **T22 US-22 Pause camera:** screens 33–35. Options 30 min, 1 h, 2 h, «Hasta mañana» (contract `duracion`); paused state with the end time; resume.
- [x] **T23 US-15 Unreliable detection notice:** screens 36 and 37. «Revisa la luz y el encuadre».
- [x] **T24 US-23 Live view:** screens 38–40, 54 and 74.
  - Dark background, «EN VIVO · mm:ss», access-recorded reminder.
  - Unavailable when disconnected or paused.
  - Transport per the contract (see BLOCKERS).
- [x] **T25 US-24 Access log:** screens 41–43. «Acceso registrado» toast; list newest first; empty state.
- [x] **T26 US-08 Family management:** screens 66–71. Invitation sent, accept invitation, member options, remove access.
- [x] **T27 Invited member (read-only):** screens 73 and 75–82. Lock icon and «Solo ver» per PRODUCT.md and DESIGN.md.
- [x] **T28 US-21 Recovery notice:** screen 57. «Se levantó a las HH:MM».
- [ ] **T29 US-26 Recordings:** screens 89–91. Playback, download, removed by retention.
- [ ] **T30 US-27 Weekly summary:** screens 92 and 93. Counts by type and the trend against the previous week (amber for increases in falls or unstable movement, green for decreases).
- [ ] **T31 Settings:** screens 94 and 96. Notification preferences, privacy entry point.
- [ ] **T32 Local cache:**
  - `drift` (SQLite) for the latest alerts, the viewed history, camera status and preferences (architecture: «Base de datos local del cliente»).
  - Show cached data when offline.
- [ ] **T33 Hardening.**
  - A golden or screenshot test per main screen.
  - An accessibility pass: semantics labels, tap targets, text scaling to 200 %.
  - A final check of every endpoint against `docs/API_CONTRACT.md`.
