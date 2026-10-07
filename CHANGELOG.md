# Changelog

Format based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]
### Added
- Shared API contract with the backend (`docs/API_CONTRACT.md`), the work plan with its autonomous loop (`docs/WORK_PLAN.md`) and the `/work` command.
- The 103 prototype screens and the prototype HTML as visual references.
- **T01 App shell:** splash screen 00 with the logo animation (still final frame when animations are disabled), welcome screen 01, bottom bar with Inicio, Historial, Familia and Ajustes, and router guards (no session → welcome; no household → onboarding). Shared UI kit with the prototype icons, illustrations, notices, lists, fields and buttons.
### Changed
- Documentation translated to English.

## [0.1.0] - 2026-10-07
### Added
- **App base:** Flutter 3.44.8 with Riverpod 3, go_router, Dio and secure token storage.
- **Theme from the DESIGN.md tokens:** semantic and brand colors, Atkinson Hyperlegible, radii of 22 and 16.
- **Backend client:** `Api-Version` header, session token and RFC 9457 errors (`ProblemaApi`).
- **Reference feature `camaras`:** list with icon-and-text status, and room rename with suggestions, preview and validation (US-06, US-07), with tests.
