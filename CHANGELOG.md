# Changelog

Format based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]
### Added
- Shared API contract with the backend (`docs/API_CONTRACT.md`), the work plan with its autonomous loop (`docs/WORK_PLAN.md`) and the `/work` command.
- The 103 prototype screens and the prototype HTML as visual references.
- **T01 App shell:** splash screen 00 with the logo animation (still final frame when animations are disabled), welcome screen 01, bottom bar with Inicio, Historial, Familia and Ajustes, and router guards (no session → welcome; no household → onboarding). Shared UI kit with the prototype icons, illustrations, notices, lists, fields and buttons.
- **T02 Session state:** `SesionController` with the contract `Sesion` in secure storage, token refresh on `401 SESION_EXPIRADA` through a Dio interceptor, household switching (`GET /api/hogares`, `POST /api/sesiones/hogar`) and the shared `MensajeProblema` widget for RFC 9457 errors.
- **T03 Register (US-01):** screens 02–05. `POST /api/cuentas` followed by `POST /api/sesiones`, field highlighting from client checks and from `400 VALIDACION.campos`, and the `409 CORREO_EN_USO` notice with sign-in and recovery links.
- **T04 Sign in and sign out (US-02):** screens 06–08 and 13. `POST /api/sesiones`, wrong-credentials message with the remaining attempts, `423 CUENTA_BLOQUEADA` with the unlock time and disabled fields, and sign-out confirmation with `DELETE /api/sesiones/actual`, splash and the sign-in screen. Household data layer (`GET /api/hogar`).
- **T05 Password recovery (US-03):** screens 09–12. `POST /api/recuperaciones` with the same generic message for any email, resend countdown, reset deep link (`tetengo://app/nueva-contrasena?token=…`) with `POST /api/recuperaciones/confirmacion`, and the expired-link screen on `410 ENLACE_VENCIDO`.
- **T06 Older adult profile (US-04):** screens 14, 15 and 95. Setup step 1 with `POST /api/hogar` (stores the returned `Sesion`), the contract `convivencia` options, `409 HOGAR_YA_REGISTRADO` and the one-person-per-account notice, and the profile in Ajustes with `PUT /api/hogar/adulto-mayor` (read-only for invited members). Family data layer (`GET /api/familiares`).
- **T07 Consent (US-05):** screens 16–18, 22 and 102. Consent summary with the live-view clause, both checkboxes required, `POST /api/hogar/consentimiento`, the certificate with date, time and Law No. 29733, the camera setup step without consent, and the «Detección detenida» home card. `Camara` now carries `pausadaHasta` and `deteccionConfiable` with the visible states of DESIGN.md.
- **T08 Camera and room name (US-06):** screens 19–21 and 32. Camera ready step and camera detail with the full `Camara`, room rename with suggestions, preview and `PATCH /api/camaras/{id}` (`422` name errors, `403 SOLO_TITULAR`), owner-only with the read-only «Solo ver» treatment for invited members. The old camera list was replaced by the single-camera detail of the pilot.
- **T09 Invite during onboarding (US-08):** screens 23 and 24. Setup step 4 with `POST /api/invitaciones` (own-email and `409 YA_ES_FAMILIAR` checks) and the «Todo listo» summary of camera, consent and family.
- **T10 Home:** screens 25–27. Older adult status card with the color band of each state, camera row with icon and text and the «Ver en vivo» row, the disabled-notifications notice with `permission_handler` (CA-16.3) and the no-internet bar on every tab with `connectivity_plus`.
- **T11 Connection status (US-07):** screens 28–31. Camera detail with icon-and-text status, «Qué revisar en la casa» (cable, PC on and internet) when disconnected, the in-app disconnection notice that opens the camera and the reconnection toast. Toasts and in-app notices now float at the top, as in the prototype.
- **T12 Push foundation (US-16 CA-16.2):** `NotificacionesPush` interface with a `firebase_messaging` implementation (inactive until a Firebase project exists) and a test fake, device registration with `POST` and `DELETE /api/dispositivos` (on sign-in, token refresh and sign-out), routing of every contract push `tipo` to its screen, and in-app handling of camera pushes.
- **T13 Fall alert (US-16):** screens 44–48. Full-screen red alert with severity tag, headline, room, time and elapsed time, «Llamar» and «Ver en vivo», «Qué hacer ahora» and the alert record; the active alert (`GET /api/alertas?estado=ACTIVA`) opens by itself, shows the failed-notification notice when `notificadaEn` is null (CA-16.4), and appears as a strip, a home card state and a badge on Historial.
- **T14 Confirmation chip (US-13):** screen 46. «Comprobando si sigue en el suelo» turns into «Sigue en el suelo · confirmada» with the confirmed headline, notice and record line, from the `CAIDA_CONFIRMADA` push or the 10 s refresh of an open alert; elsewhere in the app the confirmation arrives as an in-app notice.
- **T15 Unstable movement (US-17):** screens 49–52. Amber medium-severity alert with its own icon, label and steps (never shared with a fall), amber strip and home state, and the in-place update to a fall with «Empezó como movimiento inestable» on `ALERTA_ACTUALIZADA_A_CAIDA`.
- **T16 Clip (US-18):** screens 47 and 53. `GET /api/alertas/{id}/clip` played with `video_player` behind a controller interface (room and pose poster while loading, play/pause, event mark, 0:00 / 0:12), and «Clip no disponible» when the alert says `NO_DISPONIBLE` or the clip returns `404`.
- **T17 Revoke consent (US-09):** screens 97–101. Privacy screen with the certificate and how data is cared for, confirmation dialog that keeps everything active when declined (CA-09.2), `DELETE /api/hogar/consentimiento`, and the deleting → deleted progress completed by the `DATOS_ELIMINADOS` push (CA-09.3); invited members see the read-only notice.
### Changed
- Documentation translated to English.

## [0.1.0] - 2026-10-07
### Added
- **App base:** Flutter 3.44.8 with Riverpod 3, go_router, Dio and secure token storage.
- **Theme from the DESIGN.md tokens:** semantic and brand colors, Atkinson Hyperlegible, radii of 22 and 16.
- **Backend client:** `Api-Version` header, session token and RFC 9457 errors (`ProblemaApi`).
- **Reference feature `camaras`:** list with icon-and-text status, and room rename with suggestions, preview and validation (US-06, US-07), with tests.
