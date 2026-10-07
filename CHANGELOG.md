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
### Changed
- Documentation translated to English.

## [0.1.0] - 2026-10-07
### Added
- **App base:** Flutter 3.44.8 with Riverpod 3, go_router, Dio and secure token storage.
- **Theme from the DESIGN.md tokens:** semantic and brand colors, Atkinson Hyperlegible, radii of 22 and 16.
- **Backend client:** `Api-Version` header, session token and RFC 9457 errors (`ProblemaApi`).
- **Reference feature `camaras`:** list with icon-and-text status, and room rename with suggestions, preview and validation (US-06, US-07), with tests.
