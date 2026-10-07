# App architecture

## Feature-first, three layers
Each folder in `lib/features/` is a backlog feature, with three layers inside:
- **`domain/`:** immutable models that parse the backend JSON (`Camara.desdeJson`).
- **`data/`:** a repository interface, its Dio implementation following `docs/API_CONTRACT.md`, and the Riverpod providers (`camarasRepositorioProvider`, `camarasProvider`).
- **`presentation/`:** screens (`ConsumerWidget` / `ConsumerStatefulWidget`) and reusable widgets.

Screens only know the repository interface, so tests replace it with a fake through `overrideWithValue`.

```
lib/
├── app/          app.dart, router.dart + rutas.dart (guards), navegacion.dart (tabs), push.dart (push routing),
│                 barras_estado.dart (offline bar, active-alert strip), tema/ (Colores = DESIGN.md tokens)
├── core/         configuracion.dart (TT_API_URL), red/ (Dio client, ProblemaApi, session interceptor),
│                 sesion/ (secure token, SesionController), cache/ (drift SQLite + offline interceptor),
│                 notificaciones/ (push, device registration), dispositivo/ (permission, connectivity, dialer),
│                 ui/ (shared widgets: buttons, lists, notices, icons, illustrations, logo)
└── features/     one folder per feature: data/, domain/, presentation/
    └── camaras/  REFERENCE FEATURE
```

## Features
Built in backlog-sprint order; see [WORK_PLAN.md](WORK_PLAN.md) (every task checked) and the open
points in [BLOCKERS.md](BLOCKERS.md).

| Feature | Stories | Status |
|---|---|---|
| `arranque` | — | Done: splash and session restore |
| `sesion` | US-01 to US-03 | Done: register, sign in with lockout, password recovery, sign-out |
| `hogar` | US-04, US-05, US-09 | Done: older adult (single person per account), consent and certificate, privacy, revocation |
| `camaras` | US-06, US-07, US-15, US-22 | Done (reference): status, rename, connection notices, unreliable detection, pause and resume |
| `inicio` | US-16 | Done: home card per state, notifications banner, camera, «Esta semana» |
| `alertas` | US-13, US-14, US-16 to US-21, US-26 | Done: fall and unstable alerts, confirmation, clip, marking, escalation, recovery, recordings download |
| `vivo` | US-23, US-24 | Done: live view over the WebSocket relay, access log |
| `familia` | US-08, US-10 | Done: invite, accept, member options, remove access, alert order and wait |
| `historial` | US-25, US-27 | Done: filtered history with paging, weekly summary with trend |
| `ajustes` | US-08 (read-only), US-16 | Done: settings for owner and invited member, notification preferences |

## Quality
- Widget tests per acceptance criterion with fake repositories; repository tests against a fake Dio adapter.
- `test/calidad/`: an accessibility sweep of the main screens (44 px targets, labels, WCAG contrast,
  text at 200 % without overflow), golden screenshots (`--update-goldens` to regenerate) and a check of
  every endpoint and push type of `docs/API_CONTRACT.md`.

## Communication
- **REST:** `te-tengo-general-api` through `clienteApiProvider`, which sets the base URL, `Api-Version: 1` and `Authorization: Bearer`.
- **Push:** Amazon SNS delivers through FCM (Android) and APNs (iOS); `firebase_messaging` obtains the device token, which is registered with `POST /api/dispositivos`.
- **Live view:** on demand, using the transport in the API contract (`web_socket_channel`, JPEG frames).
- **Local cache:** `drift` (SQLite) keeps the last answers per household and serves them offline; sign-out clears them.
