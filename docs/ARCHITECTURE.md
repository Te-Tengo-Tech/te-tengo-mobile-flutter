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
│                 barras_estado.dart (offline bar, active-alert strip), tema/ (Colores = DESIGN.md tokens; Paleta = the tokens that change
│                 in dark mode, read with context.colores)
├── core/         configuracion.dart (TT_API_URL), red/ (Dio client, ProblemaApi, session interceptor),
│                 sesion/ (secure token, SesionController), cache/ (drift SQLite + offline interceptor),
│                 notificaciones/ (push, device registration, firebase_web.dart), dispositivo/ (permission,
│                 connectivity, dialer), web/ (browser bridges and EntornoNavegador, conditional imports),
│                 ui/ (shared widgets: buttons, lists, notices, icons, illustrations, logo,
│                 FilaPlegable and VerMas for folded secondary detail)
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
| `vivo` | US-23, US-24 | Done: live view over WebRTC (WHEP) with LL-HLS fallback, the stream mode, access log, `preparar` |
| `familia` | US-08, US-10 | Done: invite, accept, member options, remove access, alert order and wait |
| `historial` | US-25, US-27 | Done: filtered history with paging, weekly summary with trend |
| `ajustes` | US-08 (read-only), US-16 | Done: settings for owner and invited member, notification preferences |
| `instalar` | — | Web only: «Agrega Te Tengo a tu pantalla de inicio» notice and guide on iPhone browser tabs |
| `legal` | US-01, US-05, US-09 | Términos de uso, Política de privacidad and the full consent document; the consent text shared with the summary |

## Design system
- **Colors:** use `context.colores` (the `Paleta` of the current theme) for anything that changes
  in dark mode; `Colores` keeps the fixed ones (severity floods, brand, the live view's night).
  The app follows the phone's theme by default; Ajustes › «Apariencia» (`aparienciaProvider`,
  `features/ajustes/data/apariencia.dart`) can keep this device light or dark. It is a device
  setting, not an account one: stored under the `dispositivo|apariencia` key of the local cache,
  which `vaciar()` keeps on sign-out, and read in `main()` before the first frame (with the session,
  on the same database the app then uses), so `MaterialApp.themeMode` starts with it and there is no
  flash of the other theme. The alert flood keeps the light theme.
- **Progressive disclosure:** a screen shows first what decides the action; secondary detail goes
  in a `FilaPlegable` (a row in a list) or a `VerMas` (inside a card). Nothing is removed.
- **Large text:** every screen must work with the system text at 200 % (`test/calidad/`).

## Quality
- Widget tests per acceptance criterion with fake repositories; repository tests against a fake Dio adapter.
- `test/calidad/`: an accessibility sweep of the main screens (44 px targets, labels, WCAG contrast,
  text at 200 % without overflow, dark mode with contrast), golden screenshots (`--update-goldens` to regenerate) and a check of
  every endpoint and push type of `docs/API_CONTRACT.md`.

## Communication
- **REST:** `te-tengo-general-api` through `clienteApiProvider`, which sets the base URL, `Api-Version: 1` and `Authorization: Bearer`.
- **Push:** Amazon SNS delivers through FCM (Android) and APNs (iOS); `firebase_messaging` obtains the device token, which is registered with `POST /api/dispositivos`. The web app registers an FCM Web Push token as `WEB`.

## Web build (PWA)
The same code runs in the browser for iPhones without the App Store build ([WEB_PWA.md](WEB_PWA.md)).
Platform code is behind conditional imports (`if (dart.library.js_interop)`): `core/web/navegador.dart`
(service worker, browser permission, tapped pushes, downloads) and `core/cache/cache_dispositivo.dart`
(drift's SQLite file on the phones, `localStorage` in the browser), so the phone builds never compile
web code and the web build never imports `dart:ffi`. `entornoNavegadorProvider` tells screens whether
they run in a browser and whether an iPhone tab must be installed first; tests override it.
- **Live view:** on demand, behind the `ReproductorVivo` interface. When the session has `urlWebrtc`, `ReproductorWebrtc` (`flutter_webrtc`, WHEP signalling in `ClienteWhep`) plays it first; `PantallaVivo` switches the same session to LL-HLS (`ReproductorHls`, `video_player`) when WebRTC fails, still answers `404` after `esperaPublicacionWebrtc` (8 s), shows no first frame within `esperaWebrtc` (4 s) of MediaMTX's answer, or stops getting frames for `esperaSinImagenWebrtc` (3 s); after a break mid-stream LL-HLS has `esperaRescateHls` (10 s) to show a frame. The camera detail and an open alert send `preparar` once when they open (`PrepararVivo`, `prepararVivo`). The session ends when the screen closes or the app goes to the background.
- **Local cache:** `drift` (SQLite) keeps the last answers per household and serves them offline; sign-out clears them. Keys starting with `dispositivo|` belong to the phone (notification preferences, appearance) and survive sign-out.
