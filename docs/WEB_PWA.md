# Web app (installable PWA)

The same Flutter app is built for the web so that **iPhone users can use Te Tengo without the App
Store** (the team has no paid Apple Developer account). They open it in Safari and add it to the home
screen; from iOS 16.4 a home-screen web app can receive push notifications. Android and desktop
browsers can install it too.

## Hosting and base href
- Served at the **root of its own origin, `https://app.tetengo.reqsai.tech/`**: the Cloudflare Pages
  project `te-tengo-app`, separate from the landing (`https://tetengo.reqsai.tech`, project
  `te-tengo-landing`). This repository builds and deploys it: the reusable
  [`build-web.yml`](../.github/workflows/build-web.yml) runs `flutter build web --base-href /` and adds
  the Pages files of [`deploy/pwa/`](../deploy/pwa/) (`_headers`, `robots.txt`).
  [`release.yml`](../.github/workflows/release.yml) stores that build as `te-tengo-pwa.tar.gz` in the
  release candidate and deploys it to the alias `https://staging.te-tengo-app.pages.dev`;
  [`produccion.yml`](../.github/workflows/produccion.yml) deploys the same archive to production from
  `main`. Each deploy follows an approval and a smoke check ([RELEASES.md](RELEASES.md)). The old address `https://tetengo.reqsai.tech/app/…` redirects
  there with a `301`, keeping the `#fragment`.
- The CI job `Web (PWA)` runs the same build on every pull request and uploads the `te-tengo-web`
  artifact; it is a check, not what gets deployed.
- The base href is a build flag, `/` for the app origin: `flutter build web --base-href /`. A
  sub-path works the same (it was tested under `/app/` and `/te-tengo-descargas/app/`); in CI set the
  repository variable `TT_WEB_BASE_HREF`. Every URL in `web/` (manifest, icons, service worker) is
  relative, so nothing else changes.
- `--no-web-resources-cdn` serves CanvasKit from the app origin instead of Google's CDN, so the
  service worker can keep it for offline use.

## Routing and e-mail links
The app uses Flutter's default **hash URLs**: `https://app.tetengo.reqsai.tech/#/inicio`.
- Why: hash URLs need no rewrite rule on the host, work on any static host, and a reload never 404s.
  They also survive the `301` from the old `/app/` address of the landing, since the browser keeps the
  fragment across a redirect.
- **E-mail links the API must send** (the routes are the same as the app's `tetengo://app/…` links):
  - password reset: `https://app.tetengo.reqsai.tech/#/nueva-contrasena?token=<token>&correo=<email>`;
  - invitation: `https://app.tetengo.reqsai.tech/#/invitacion/<token>?titular=<name>&adultoMayor=<name>&correo=<email>`.
  Query values are percent-encoded; the optional ones can be left out. Both screens are public, so
  they open without a session (verified in Chrome and iOS Safari).
- To switch to path URLs later: add a `_redirects` line `/* /index.html 200` to the app's Pages files
  (`deploy/pwa/`), call `usePathUrlStrategy()` (package
  `flutter_web_plugins`) before `runApp`, and change the e-mail links.

## Service worker: one worker for caching and push
- Flutter's own `flutter_service_worker.js` is **deprecated** (flutter/flutter#156910); in Flutter
  3.44 the generated file only unregisters itself. If it were registered at `/` it would remove the
  FCM worker of the same scope, so `web/flutter_bootstrap.js` loads Flutter **without**
  `serviceWorkerSettings`, and the file in `build/web` is never used.
- `web/firebase-messaging-sw.js` is the only worker, registered from Dart at startup
  (`registrarTrabajadorServicio` in `lib/core/web/navegador_web.dart`) with the base href as its
  scope, `/` on `https://app.tetengo.reqsai.tech/`. It:
  - caches the app **network first**: online, every file comes fresh; offline, the last copy kept
    (the app shell is cached on install, so the second visit already opens offline). API, Firebase
    and CDN requests are never cached by it;
  - receives **FCM web push** when its URL carries the Firebase web config
    (`firebase-messaging-sw.js?apiKey=…&appId=…&messagingSenderId=…&projectId=…`): the worker is a
    static file, so the page passes the build's `--dart-define` values in the registration URL;
  - opens the right screen when a notification is tapped: it focuses an open window and posts the
    push data to it, or opens `/?tt_push=<data>` (relative to the scope); Dart turns the data into the route
    (`rutaDePush`), as on Android and iOS.
- `FIREBASE_SDK` in the worker must equal the Firebase JS SDK version of `firebase_core_web`
  (`supportedFirebaseJsSdkVersion`, now 12.19.0). Check it when Dependabot upgrades FlutterFire.
- The app's Pages files (`deploy/pwa/_headers`) send
  `Cache-Control: no-cache` for everything, and browsers always revalidate the worker script, so a new
  deployment is picked up on the next visit. Do not add long cache rules there.

## Push on the web
| Step | What happens |
|---|---|
| Startup | Firebase starts with `FirebaseOptions` from the defines (below). Without them, or in a browser without Web Push (an iPhone Safari tab), push is unavailable and the rest of the app works |
| Permission | Never asked on its own: Safari ignores a prompt that does not come from a tap. Inicio shows «Activa las notificaciones» and the **«Activar notificaciones»** button asks (`Notification.requestPermission` is its first call) |
| Token | `getToken(vapidKey, serviceWorkerScriptPath)`: the worker registered at the base href (here the origin root, `/`); passed explicitly so a sub-path build keeps working |
| Registration | `POST /api/dispositivos {tokenPush, plataforma: "WEB"}` (contract §7), again on each household change and sign-in; `DELETE` on sign-out |
| Foreground push | `onMessage`, the same in-app notices as on the phones |
| Tapped push | through the worker (above); firebase_messaging has no `onMessageOpenedApp` on the web |

### Firebase web config and VAPID key
The values are public (they ship in the page) but are **not committed**. The owner keeps them in
`~/.config/te-tengo/firebase-web.env`; the define names are its keys:

| Define | Firebase console |
|---|---|
| `TT_FIREBASE_WEB_API_KEY`, `TT_FIREBASE_WEB_APP_ID`, `TT_FIREBASE_WEB_MESSAGING_SENDER_ID`, `TT_FIREBASE_WEB_PROJECT_ID` (required) | *Project settings › General › Your apps › Te Tengo Web › SDK setup and configuration › Config* |
| `TT_FIREBASE_WEB_AUTH_DOMAIN`, `TT_FIREBASE_WEB_STORAGE_BUCKET`, `TT_FIREBASE_WEB_MEASUREMENT_ID` (optional) | same place |
| `TT_FCM_VAPID_KEY` (required) | *Project settings › Cloud Messaging › Web configuration › Web Push certificates › Key pair* (the public key) |
| `TT_API_URL` | the backend (HTTPS in production) |

Flutter reads `.env` files directly:
```bash
flutter build web --release --base-href / --no-web-resources-cdn \
  --dart-define-from-file=$HOME/.config/te-tengo/firebase-web.env \
  --dart-define=TT_API_URL=https://<api host>
```
In CI, the same names are **repository variables** (*Settings › Secrets and variables › Actions ›
Variables*); `build-web.yml` passes the ones that exist, both in the `Web (PWA)` check and in the build
that `release.yml` deploys. With `ENABLE_PWA` on, a release fails at once if a required one is missing.

## What the iPhone allows (iOS 16.4+)
- **Push only for the home-screen app.** In a Safari tab there is no `Notification` API: the app
  shows «Agrega Te Tengo a tu pantalla de inicio» on the welcome screen, Inicio and Notificaciones,
  with a guide (`/instalar`). In iOS 26 «Agregar a inicio» is inside *Compartir › Ver más*.
- **Separate storage.** The home-screen app does not share Safari's cookies or storage: the user
  signs in again there. Removing the icon deletes its data.
- **Every push must show a notification** (no silent pushes); the backend must fill the notification
  title and body (docs/BLOCKERS.md). A data-only push still shows «Te Tengo» as a fallback.
- **Permission per install**, asked from a tap; if denied, it can only be changed in *Ajustes del
  iPhone › Notificaciones › Te Tengo*.
- No background fetch, badges are limited, and delivery while the phone is idle is up to iOS. The
  App Store build stays the reliable option for iPhones once there is a paid account.

## Other differences on the web
| Area | Android / iOS | Web |
|---|---|---|
| Session token | Keychain / Keystore | `flutter_secure_storage` web: AES-GCM (WebCrypto) in `localStorage`, key stored next to it. Needs HTTPS or `localhost`. Weaker than the OS store: any script of the origin could read it |
| Offline cache | drift SQLite file | `localStorage` (`tt_cache|…` keys; a full storage only loses the cache) |
| Live view | `video_player` (AVPlayer, ExoPlayer) | Safari plays the HLS natively; Chrome, Edge, Firefox and Android through `video_player_web_hls` and hls.js 1.7.3 (pinned on jsDelivr with SRI, loaded deferred; without it clips and native HLS still play). Chromium 142+ also reports native HLS, but its new built-in player fails on MediaMTX's LL-HLS (`MediaError` 4, `DEMUXER_ERROR_COULD_NOT_PARSE`) and the plugin's hls.js fallback then stays paused on the first frame, so `web/index.html` reports no native HLS in Chromium browsers once hls.js is loaded. The page and the stream must both be HTTPS (no mixed content) |
| Clips | `video_player` | `<video>` with the pre-signed URL (no CORS needed) |
| Recording download | file in Documents / Downloads | the browser's download (`Content-Disposition: attachment` from `descarga=true`) |
| «Llamar» | dialer | `tel:` link in the same window (the iPhone dialer opens) |
| Notification permission | `permission_handler` | the browser's `Notification.permission` |

**Live view start (every platform).** Until the camera publishes, MediaMTX answers `404` for the
playlist. The app asks for it every 2 s and only creates the player once it is served; each start
attempt is limited to 6 s, within the 20 s the screen waits for the first frame
(`ReproductorHls.iniciar`, `PantallaVivo._conectar`). This avoids two bugs of
`video_player_web_hls` 1.3.0, the latest release: it swallows hls.js's fatal error for a `404`
playlist (dynamic access on a JS object throws `NoSuchMethodError`, caught and only printed as
«Error parsing hlsError»), so `initialize()` never completes; and its `dispose()` does not destroy
hls.js, which keeps loading until MediaMTX answers `401` after the session ends. If the request
itself fails (no connection, or an origin missing from `hlsAllowOrigins`), the player is tried anyway.

## Backend and infrastructure requirements
The API side is in te-tengo-general-api#12 (contract §§ Conventions, 4 and 7); each environment
configures it:
- **CORS:** `TT_CORS_ORIGENES` with the PWA origin, `https://app.tetengo.reqsai.tech`
  (`http://localhost:*` locally). Without it a browser preflight gets `403` and the PWA cannot sign in.
- **E-mail links:** `TT_ENLACE_BASE=https://app.tetengo.reqsai.tech/#`, which gives the hash links
  above.
- **Web push:** the push service's web configuration; `plataforma: "WEB"` tokens get an FCM web push
  with the same title, body and data, and are skipped without it.
- **Live view:** MediaMTX `hlsAllowOrigins` with the PWA origins (`https://app.tetengo.reqsai.tech`
  and the staging alias), for hls.js and for the app's first request to the playlist.

## Test it
**Locally in Chrome** (`localhost` is a secure context, so the worker and push work without HTTPS):
```bash
flutter build web --release --base-href / --no-web-resources-cdn \
  --dart-define-from-file=$HOME/.config/te-tengo/firebase-web.env
python3 -m http.server 8123 --directory build/web
```
Open `http://localhost:8123/`. DevTools › *Application* shows the manifest, the icons and
`firebase-messaging-sw.js` activated with scope `/`. After signing in, «Activar notificaciones»
asks for permission and the token is registered (`select token_push from dispositivos where
plataforma = 'WEB'`, or `Token de push: …` in a debug build); send a test message to it from the
Firebase console (*Messaging › Send test message*).

**iOS Simulator** (Safari, no push): `xcrun simctl openurl booted http://localhost:8123/`. The
welcome screen shows the install notice; *··· › Compartir › Ver más › Agregar a inicio* installs it,
and the icon opens it without Safari's bars and without the notice.

**Real iPhone** (push needs HTTPS and the installed app): use `https://app.tetengo.reqsai.tech/`, or a
tunnel to the local server (`cloudflared tunnel --url http://localhost:8123`); open it in Safari, add it to the home screen, open it from the icon, sign in, tap
«Activar notificaciones» and send a test message to the registered token.
