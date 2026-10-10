# AGENTS.md

## Purpose
Mobile app **Te Tengo** for family members and caregivers. This repository is the "Aplicación del familiar/cuidador" container of the C4 model. The app lets them:
- receive fall and unstable-movement alerts;
- watch the event clip and the live view;
- manage the camera, consent, family and history.

It talks to `te-tengo-general-api` over HTTPS/REST with `Api-Version: 1`.

## Where to look
| Question | Source |
|---|---|
| What to build, and in which order | [docs/WORK_PLAN.md](docs/WORK_PLAN.md) — a checklist that maps every task to stories **and screens**; follow its autonomous loop |
| Exact backend API (paths, JSON, error codes, push types) | [docs/API_CONTRACT.md](docs/API_CONTRACT.md) — **shared with the backend; consume it exactly** |
| How each screen must look | `docs/references/screens/NN-name.png` (115 prototype screens, 00–114). **Open the images: they are the visual reference.** |
| Exact UI copy and structure | `docs/references/prototype/prototipo.html` (search for the screen title) |
| Tokens, typography, components, accessibility | `docs/references/DESIGN.md` |
| Product rules (owner vs invited member, read-only) | `docs/references/PRODUCT.md` |
| Acceptance criteria (Given/When/Then) | `docs/references/PRODUCT_BACKLOG.md` |
| Folder layout and patterns | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and the reference feature `lib/features/camaras` |

The files under `docs/references/` are Spanish source documents from the thesis.

## Stack
- **Flutter 3.44.8, Dart 3.12.** Targets: Android, iOS and the web (an installable PWA for iPhones without the App Store build; [docs/WEB_PWA.md](docs/WEB_PWA.md)).
- **Riverpod 3** (state and DI), **go_router** (navigation), **Dio** (HTTP) and **flutter_secure_storage** (token).
- **Added by the tasks that need them:**
  - `firebase_messaging` for push (needs a Firebase project; see BLOCKERS);
  - `drift` for the local SQLite cache;
  - `video_player` for clips and the live view's LL-HLS fallback;
  - `flutter_webrtc` for the live view over WebRTC (WHEP), on Android, iOS and the web.

## Rules
- **UI language:** all user-facing text is **Spanish (Peru)**, copied from the prototype or DESIGN.md. Never show story IDs or prototype labels. Code identifiers follow the domain language (Spanish, matching the API); comments, docs and commits are **English**.
- **Design:**
  - Colors come from `context.colores` (`Paleta`, light and dark) or `Colores` (fixed: severity floods, brand), never hard-coded. The app follows the phone's light or dark theme unless this device chose «Claro» or «Oscuro» in Ajustes › «Apariencia».
  - Red (`caida`) and amber (`inestable`, `aviso`) are reserved for real events.
  - **Status is never shown by color alone:** always icon + text (`EstadoCamara`).
- **Accessibility:**
  - body text ≥ 16, touch targets ≥ 44 px;
  - AA contrast (AAA on alert data);
  - honor `MediaQuery.disableAnimations`.
- **Typography:** Atkinson Hyperlegible Next everywhere; Atkinson Hyperlegible Mono (`fuenteMono`) for times and data.
- **Multi-tenancy:** the session token carries `hogar_id`, and the backend filters by it. **The app never sends a household id**, except in `POST /api/sesiones/hogar` when switching households.
- **Errors:** backend errors arrive as `ProblemaApi` with a stable `codigo` (RFC 9457). Show `detalle`; branch on `codigo`.
- **Roles:**
  - `INVITADO` sees the same alerts, clips, live view, history and summary as `TITULAR`;
  - it can mark alerts and pause the camera;
  - **it cannot edit** the profile, consent, camera name, family or alert order. Show the read-only treatment from DESIGN.md: lock icon, «Solo ver».
- **Tests:**
  - every screen gets widget tests with a fake repository (`overrideWithValue`), one per acceptance criterion;
  - repositories get unit tests against a mocked Dio;
  - no real network calls in tests.

## Commands
| Command | Purpose |
|---|---|
| `flutter pub get` | Dependencies |
| `dart format lib test` | Format |
| `flutter analyze` | Lint (must report no issues) |
| `flutter test` | Unit and widget tests |
| `flutter run --dart-define=TT_API_URL=http://10.0.2.2:8080` | Run against the local backend (Android emulator) |

## Definition of done (every task)
1. **The screens match their PNG references**: layout, order, states and Spanish copy.
2. **The API calls match `docs/API_CONTRACT.md`** exactly.
3. **Every acceptance criterion is covered by a test.**
4. **`dart format`, `flutter analyze` (no issues) and `flutter test` pass.**
5. **One Conventional Commit per task,** in English and with no co-author line (e.g. `feat(sesion): sign-in with lockout message (US-02)`), and the task is checked off in `docs/WORK_PLAN.md`.
