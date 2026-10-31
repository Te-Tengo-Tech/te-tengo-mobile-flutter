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
- [x] **T29 US-26 Recordings:** screens 89–91. Playback, download, removed by retention.
- [x] **T30 US-27 Weekly summary:** screens 92 and 93. Counts by type and the trend against the previous week (amber for increases in falls or unstable movement, green for decreases).
- [x] **T31 Settings:** screens 94 and 96. Notification preferences, privacy entry point.
- [x] **T32 Local cache:**
  - `drift` (SQLite) for the latest alerts, the viewed history, camera status and preferences (architecture: «Base de datos local del cliente»).
  - Show cached data when offline.
- [x] **T33 Hardening.**
  - A golden or screenshot test per main screen.
  - An accessibility pass: semantics labels, tap targets, text scaling to 200 %.
  - A final check of every endpoint against `docs/API_CONTRACT.md`.

## PCs, cámaras y datos de movimiento (change request, pending approval)
Screens of the mobile prototype in the docs repository (`05-prototipos/app-movil`, `pantallas.html` 22, 25, 29, 76, 77 and 120 to 302); stories US-28 to US-40 of the backlog; contract §9 to §11.
- [x] **T34 US-28 Link a PC:** screens 22, 120 to 141. Scanner with the camera permission states, 8-box code, approval with the PC's data, «No reconozco esta PC», invited member, the `/vincular?codigo=` link (PWA and Android App Link).
- [x] **T35 US-29 Choose the cameras:** screens 25, 142, 143, 168, 170 and 250 to 283. Webcams of the PC, rooms (one per room, no bathrooms), preview, «Dejar de usar», «Buscar de nuevo», offline PC, invited member.
- [x] **T36 US-30, US-31 Cámaras y PCs:** screens 144 to 167 and 284 to 302 (cameras by room, PC detail, remove a PC, `PC_DESVINCULADA`, the live view's room picker).
- [x] **T37 US-35, US-37 Movement data consent and cloud retention:** screens 171 to 192 (`MOVIMIENTOS_ELIMINADOS`).
- [x] **T38 US-40 «¿Hubo una caída y no avisó?»:** screens 221 to 230.
- [x] **T39 US-33 Activity and family member detail:** screens 76, 77, 215 to 220 and 231 to 236.
- [x] **T40 US-36, US-39 Body points and replay:** screens 193 to 214 and 303 to 312, the camera as a player (docs `9497de2`). Drawing the skeleton waited for a movement decoder (see T41).
- [x] **T41 US-36, US-39 Drawing the movements:** the light replay format TTMOV v1 (contract §11, backend ADR 0011) decoded in pure Dart on Android, iOS and the web (`movimientos/data/decodificador_ttmov.dart`, gzip through `package:archive`), mapped to the 17 drawn keypoints; the player downloads each file's `ligero` (checked against its `sha256`), the still frame of the last event comes from its clip's `puntos.ligero` (not logged, CA-39.3), and «Puntos del cuerpo» draws them over the clip. Tested against golden fixtures written by Te Tengo Captura's encoder (`test/fixtures/movimientos`).

## Varias cámaras a la vez, favoritas, widget y contraste (change request, pending approval)
Screens 313 to 354 of the mobile prototype (docs `05-prototipos/app-movil`, commits up to `5100fc7`); stories US-41 and US-44 of the backlog (docs `1ca1c8c`); contract §4 («Several cameras at once»).
- [x] **T42 «Aumentar el contraste»:** screens 349 to 354. Ajustes › «Preferencias» (theme and contrast, on this device), the high-contrast palette in light and dark, and the phone's own setting.
- [x] **T43 «?» help icons:** the privacy and help lines that were always visible become a «?» icon with a popover (11 places in the app; the 12th is future work).
- [x] **T44 US-41 (CA-41.4) Favourites and «Ordenar»:** screens 313, 328 to 332, 338, 339 and 342; the order of this phone in «Cámaras», Inicio and the room picker.
- [x] **T45 US-41 «Ver todas»:** screens 314 to 327, 333 to 337, 340, 341 and 343; one access log entry per opening (contract §4).
- [x] **T46 US-44 Home-screen widget:** screens 344 to 348; Android 4×2 and 2×2, iOS WidgetKit, not on the web.

## Shorter onboarding and the welcome photo (owner request, 2026-10-31)
- [x] **T47 Onboarding in two steps** ([ONBOARDING.md](ONBOARDING.md)): «Persona cuidada» (Paso 1 de 2) and «Consentimiento» (Paso 2 de 2), then «Todo listo» with the consent certificate, the notification permission (explained first) and what was left for later. The PC, the family and the notifications are no longer steps; the pairing screens lost their setup mode (`config=1`).
- [x] **T48 Welcome photo:** screen 01's photo (Pexels, `assets/imagenes/CREDITOS.md`) as a 4:3 WebP with rounded corners and «Una hija abraza a su madre» for screen readers.
