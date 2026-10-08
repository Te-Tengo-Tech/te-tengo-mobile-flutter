# Web app (installable PWA)

The same Flutter app is built for the web so that **iPhone users can use Te Tengo without the App
Store** (the team has no paid Apple Developer account). They open it in Safari and add it to the home
screen; from iOS 16.4 a home-screen web app can receive push notifications. Android and desktop
browsers can install it too.

## Hosting and base href
- Served by **Cloudflare Pages** from the landing repository `te-tengo-landing-astro`, at
  `https://<landing host>/app/`. The CI job `Web (PWA)` builds it and uploads the `te-tengo-web`
  artifact (the contents of `build/web`), which the landing repository copies into its `/app/` folder.
- The base href is a build flag, `/app/` by default: `flutter build web --base-href /app/`. Any other
  sub-path works the same (it was tested under `/te-tengo-descargas/app/` too); in CI set the
  repository variable `TT_WEB_BASE_HREF`. Every URL in `web/` (manifest, icons, service worker) is
  relative, so nothing else changes.
- `--no-web-resources-cdn` serves CanvasKit from `/app/` instead of Google's CDN, so the service
  worker can keep it for offline use.

## Routing and e-mail links
The app uses Flutter's default **hash URLs**: `https://<landing host>/app/#/inicio`.
- Why: the PWA is a sub-folder of the landing's Pages project. Path URLs (`/app/inicio`) need the
  landing repository to rewrite every `/app/*` path to `/app/index.html` (a `_redirects` line
  `/app/* /app/index.html 200` at the landing's output root). Hash URLs need nothing from the landing,
  work on any static host, and a reload never 404s.
- **E-mail links the API must send** (the routes are the same as the app's `tetengo://app/…` links):
  - password reset: `https://<landing host>/app/#/nueva-contrasena?token=<token>&correo=<email>`;
  - invitation: `https://<landing host>/app/#/invitacion/<token>?titular=<name>&adultoMayor=<name>&correo=<email>`.
  Query values are percent-encoded; the optional ones can be left out. Both screens are public, so
  they open without a session (verified in Chrome and iOS Safari).
- To switch to path URLs later: add the `_redirects` line above in the landing repository, call
  `usePathUrlStrategy()` (package `flutter_web_plugins`) before `runApp`, and change the e-mail links.

## Service worker: one worker for caching and push
- Flutter's own `flutter_service_worker.js` is **deprecated** (flutter/flutter#156910); in Flutter
  3.44 the generated file only unregisters itself. If it were registered at `/app/` it would remove
  the FCM worker of the same scope, so `web/flutter_bootstrap.js` loads Flutter **without**
  `serviceWorkerSettings`, and the file in `build/web` is never used.
- `web/firebase-messaging-sw.js` is the only worker, registered from Dart at startup
  (`registrarTrabajadorServicio` in `lib/core/web/navegador_web.dart`) with scope `/app/`. It:
  - caches the app **network first**: online, every file comes fresh; offline, the last copy kept
    (the app shell is cached on install, so the second visit already opens offline). API, Firebase
    and CDN requests are never cached by it;
  - receives **FCM web push** when its URL carries the Firebase web config
    (`firebase-messaging-sw.js?apiKey=…&appId=…&messagingSenderId=…&projectId=…`): the worker is a
    static file, so the page passes the build's `--dart-define` values in the registration URL;
  - opens the right screen when a notification is tapped: it focuses an open window and posts the
    push data to it, or opens `/app/?tt_push=<data>`; Dart turns the data into the route
    (`rutaDePush`), as on Android and iOS.
- `FIREBASE_SDK` in the worker must equal the Firebase JS SDK version of `firebase_core_web`
  (`supportedFirebaseJsSdkVersion`, now 12.19.0). Check it when Dependabot upgrades FlutterFire.
- Cloudflare Pages already answers with `Cache-Control: public, max-age=0, must-revalidate`, and
  browsers always revalidate the worker script, so no `_headers` rule is needed. If the landing adds
  long cache rules, exclude `/app/*`.

## Push on the web
| Step | What happens |
|---|---|
| Startup | Firebase starts with `FirebaseOptions` from the defines (below). Without them, or in a browser without Web Push (an iPhone Safari tab), push is unavailable and the rest of the app works |
| Permission | Never asked on its own: Safari ignores a prompt that does not come from a tap. Inicio shows «Activa las notificaciones» and the **«Activar notificaciones»** button asks (`Notification.requestPermission` is its first call) |
| Token | `getToken(vapidKey, serviceWorkerScriptPath)`: the worker of `/app/`, not the origin root where the Firebase SDK looks by default |
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
flutter build web --release --base-href /app/ --no-web-resources-cdn \
  --dart-define-from-file=$HOME/.config/te-tengo/firebase-web.env \
  --dart-define=TT_API_URL=https://<api host>
```
In CI, add the same names as **repository variables** (*Settings › Secrets and variables › Actions ›
Variables*); the `Web (PWA)` job passes the ones that exist.

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
| Live view | `video_player` (AVPlayer, ExoPlayer) | Safari plays the HLS natively; other browsers through `video_player_web_hls` and hls.js 1.7.3 (pinned on jsDelivr with SRI, loaded deferred; without it clips and native HLS still play). The page and the stream must both be HTTPS (no mixed content) |
| Clips | `video_player` | `<video>` with the pre-signed URL (no CORS needed) |
| Recording download | file in Documents / Downloads | the browser's download (`Content-Disposition: attachment` from `descarga=true`) |
| «Llamar» | dialer | `tel:` link in the same window (the iPhone dialer opens) |
| Notification permission | `permission_handler` | the browser's `Notification.permission` |

## Backend and infrastructure requirements
- **CORS:** the API must allow the PWA origin (`https://<landing host>`, and `http://localhost:<port>`
  for development) with the `Authorization`, `Content-Type` and `Api-Version` headers. Today the
  local backend answers `403` to a preflight from `localhost`. MediaMTX must allow it too for hls.js
  (`hlsAllowOrigin`, `*` by default).
- `plataforma: "WEB"` in `POST /api/dispositivos`, delivered through FCM with a visible notification
  (contract §7). Optionally `webpush.fcm_options.link` = `https://<landing host>/app/`.
- E-mail links in the format above.

## Test it
**Locally in Chrome** (`localhost` is a secure context, so the worker and push work without HTTPS):
```bash
flutter build web --release --base-href /app/ --no-web-resources-cdn \
  --dart-define-from-file=$HOME/.config/te-tengo/firebase-web.env
mkdir -p /tmp/tt-site && ln -sfn "$PWD/build/web" /tmp/tt-site/app
python3 -m http.server 8123 --directory /tmp/tt-site
```
Open `http://localhost:8123/app/`. DevTools › *Application* shows the manifest, the icons and
`firebase-messaging-sw.js` activated with scope `/app/`. After signing in, «Activar notificaciones»
asks for permission and the token is registered (`select token_push from dispositivos where
plataforma = 'WEB'`, or `Token de push: …` in a debug build); send a test message to it from the
Firebase console (*Messaging › Send test message*).

**iOS Simulator** (Safari, no push): `xcrun simctl openurl booted http://localhost:8123/app/`. The
welcome screen shows the install notice; *··· › Compartir › Ver más › Agregar a inicio* installs it,
and the icon opens it without Safari's bars and without the notice.

**Real iPhone** (push needs HTTPS and the installed app): use a Cloudflare Pages preview deployment
of the landing, or a tunnel to the local server (`cloudflared tunnel --url http://localhost:8123`);
open `https://…/app/` in Safari, add it to the home screen, open it from the icon, sign in, tap
«Activar notificaciones» and send a test message to the registered token.
