# Firebase and push notifications

The app receives alerts through Firebase Cloud Messaging (FCM) on Android, on iOS (FCM relays to
APNs) and in the web app (FCM Web Push, see [WEB_PWA.md](WEB_PWA.md)). The code is ready; what each
developer needs is the Firebase project's two config files, and for the web build the web app config
and VAPID key as `--dart-define`s.

## How the app uses it
- **Startup:** `NotificacionesFirebase` calls `Firebase.initializeApp()`, which reads the native config
  files. Without them it logs `Push no disponible` and behaves like `NotificacionesPushInactivas`:
  no permission prompt, no token, no device registration. Everything else works.
- **Permission:** the first time the session has a household, the app asks for the notification
  permission (`FirebaseMessaging.requestPermission`, which also covers Android 13+). If it is denied,
  Inicio shows «Activa las notificaciones» (CA-16.3).
- **Token and registration** (`GestorPush.registrar`, contract §7): the FCM token is sent with
  `POST /api/dispositivos {tokenPush, plataforma}` on every start, every return to the foreground,
  when FCM refreshes the token (never on the web, where `onTokenRefresh` does not fire), when the
  session changes household and when notifications are turned on from Inicio, so the backend records
  when the phone was last seen. Other session changes (a renewed access token) register at most once
  every 30 s. Only one registration runs at a time (two at once used to get two FCM tokens); calls
  made meanwhile wait for one more that runs right after it. The backend's device id is kept on the
  phone, and before registering the app asks `GET /api/dispositivos/{id}` whether the backend still
  sends to it: when it answers `activo: false` (the push service dropped the token), the app deletes
  its FCM token (`deleteToken()`), gets a new one, registers that and deletes the old one from the
  backend, as it does with any token the phone no longer uses. Sign-out sends
  `DELETE /api/dispositivos/{tokenPush}`.
- **What the app shows:** «Notificaciones activadas» only once the backend has this phone. If the
  registration fails or the token cannot be replaced, Inicio and Notificaciones say «Este celular no
  recibe las alertas»; if `GET /api/hogar` says no phone of the family is active
  (`dispositivosActivos: 0`), «Nadie de la familia recibe las alertas». Inicio also asks for the
  active alert every 20 s while it is on screen, so an alert whose push was lost still opens.
- **Android channel:** `MainActivity` creates the channel `alertas_caida` («Alertas», high importance)
  at start; the backend sends alert pushes to it and `AndroidManifest.xml` makes it the default
  channel (`com.google.firebase.messaging.default_notification_channel_id`).
- **iOS with the app open:** `setForegroundNotificationPresentationOptions(alert, badge, sound)`, so a
  fall also shows the system banner and plays its sound while the alert screen opens. Urgent pushes
  are `time-sensitive`; iOS honours that only with the Time Sensitive Notifications capability, which
  is not enabled yet (docs/BLOCKERS.md).
- **iOS timing:** FCM can only issue a token after APNs has given the app its own. The app waits for
  `getAPNSToken()` (up to about 10 s) before `getToken()`; if APNs is still not ready it tries again on
  the next resume.
- **Payload:** the app reads the data block `{tipo, alertaId?, camaraId?, habitacion?, ocurridaEn}`
  (contract §7). With the app closed the operating system shows the `notification` block, which the
  backend must fill (see docs/BLOCKERS.md).
- **Backend note:** on both platforms the registered `tokenPush` is an **FCM registration token**, not
  a raw APNs device token. The backend must deliver iOS pushes through FCM too (an SNS FCM platform
  application, or the FCM HTTP v1 API), not through an SNS APNs platform application.

## Config files are not committed
`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` are listed in
`.gitignore` (with `lib/firebase_options.dart` and `firebase.json`, which `flutterfire configure`
also writes and the app does not use). They are not secrets, so if the team prefers to commit them
in this private repository, remove those lines from `.gitignore`. Builds work with or without them:
- **Android:** `android/app/build.gradle.kts` applies `com.google.gms.google-services` only when
  `google-services.json` exists.
- **iOS:** the Runner build phase «Copy GoogleService-Info.plist» copies the file into the app only
  when it exists. `Runner.entitlements` enables Push Notifications (`aps-environment`) and
  `Info.plist` declares the background modes `remote-notification` and `fetch`.

## Set up the Firebase project (once, by the team)
The team's project already exists: **`te-tengo-9ad70`**, with both apps registered. These steps
document how it was set up, and what remains (the APNs key).

1. In the [Firebase console](https://console.firebase.google.com/), create a project (for example
   «Te Tengo»). Google Analytics is not needed.
2. **Android app:** *Add app › Android*, package name `tech.tetengo.te_tengo`. Download
   `google-services.json`. Skip the console's Gradle steps: they are already in the repository.
3. **iOS app:** *Add app › Apple*, bundle ID `tech.tetengo.teTengo`. Download
   `GoogleService-Info.plist`. Skip the SDK and initialization steps: FlutterFire already includes them.
4. **APNs key** (needed for any iPhone, real or simulator with a real push; requires the paid Apple
   Developer Program):
   1. In [Certificates, IDs & Profiles › Keys](https://developer.apple.com/account/resources/authkeys/list),
      create a key with **Apple Push Notifications service (APNs)**. Download the `.p8` file (it can be
      downloaded only once) and note its **Key ID** and the **Team ID**.
   2. In Firebase, *Project settings › Cloud Messaging › Apple app configuration › APNs Authentication
      Key*, upload the `.p8` with the Key ID and Team ID.
   3. In Xcode, open `ios/Runner.xcworkspace`, select the Runner target › *Signing & Capabilities*,
      choose the team and check that *Push Notifications* and *Background Modes › Remote
      notifications* appear (they come from `Runner.entitlements` and `Info.plist`). Automatic signing
      registers the capability on the App ID `tech.tetengo.teTengo`.
   - A free (personal) Apple team cannot sign the Push Notifications capability, so building for a
     real iPhone fails with it. Simulator builds are not affected.
5. Share the two config files with the team through a private channel (not the repository, unless
   the team decided to commit them).
6. For the release builds, save them base64-encoded as the repository secrets `GOOGLE_SERVICES_JSON`
   (Android) and `GOOGLE_SERVICE_INFO_PLIST` (iOS); see [RELEASES.md](RELEASES.md).

## Web app (PWA)
The web build does not use config files: `Firebase.initializeApp` gets `FirebaseOptions` from
`--dart-define`s, and the service worker `web/firebase-messaging-sw.js` gets the same values in its
registration URL. Details, define names and limits on iOS: [WEB_PWA.md](WEB_PWA.md).

Set up once in the Firebase console (project `te-tengo-9ad70`):
1. *Project settings › General › Your apps › Add app › Web*: «Te Tengo Web» (done). Firebase
   Hosting is not needed.
2. *Project settings › Cloud Messaging › Web configuration › Web Push certificates › Generate key
   pair* (done): the public key is `TT_FCM_VAPID_KEY`.
3. If the browser API key is restricted (*Google Cloud console › APIs & Services › Credentials*),
   allow the referrers `https://app.tetengo.reqsai.tech/*` and `http://localhost:*/*`, and keep the
   *Firebase Installations API* and *FCM Registration API* in its API list.
4. The backend sends to `WEB` tokens through the *Firebase Cloud Messaging API (V1)*, already
   enabled for the Android and iOS tokens.

## Set up a developer machine
Copy the files to these exact paths:

| File | Path |
|---|---|
| `google-services.json` | `android/app/google-services.json` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

Or generate them with the FlutterFire CLI (`dart pub global activate flutterfire_cli`, then
`flutterfire configure --project=te-tengo-9ad70 --platforms=android,ios --android-package-name=tech.tetengo.te_tengo
--ios-bundle-id=tech.tetengo.teTengo`). If the CLI edits `android/settings.gradle.kts`,
`android/app/build.gradle.kts` or the Xcode project, discard those edits (`git checkout -- android ios/Runner.xcodeproj`):
the repository already applies the plugin and copies the plist when present.

Then `flutter clean && flutter run`. On the first launch with a household the app asks for the
notification permission; in debug builds the log shows `Token de push: …` once the device is
registered with the backend (`select token_push, plataforma from dispositivos` in the API database
also shows it).

## Test on the iOS simulator
**Local payload with `xcrun simctl push`** (no Firebase or APNs key needed to see the app react,
but the app still needs `GoogleService-Info.plist` so that `firebase_messaging` starts). The payload
must include `gcm.message_id`, otherwise `firebase_messaging` ignores it as a non-FCM message. Save
as `alerta.apns`, using the id of an active alert of the household:

```json
{
  "Simulator Target Bundle": "tech.tetengo.teTengo",
  "aps": {
    "alert": { "title": "Posible caída de Rosa en la Sala", "body": "10:42 · Toca para ver qué hacer y llamarla." },
    "sound": "default"
  },
  "gcm.message_id": "simulador-1",
  "tipo": "ALERTA_CAIDA",
  "alertaId": "<id of an ACTIVA alert>",
  "camaraId": "<camera id>",
  "habitacion": "Sala",
  "ocurridaEn": "2026-10-07T15:42:00Z"
}
```

```bash
xcrun simctl push booted alerta.apns
```
- App in the foreground: the alert screen opens (`onMessage`).
- App in the background: the notification appears; tapping it opens the alert (`onMessageOpenedApp`).
- App closed: tapping it launches the app on the alert (`getInitialMessage`).

**Real FCM push:** Apple silicon simulators on iOS 16 or later get a real APNs token, so with the APNs
key uploaded (step 4) the simulator also receives pushes sent through FCM, as below.

## Test on an Android emulator
1. Create the emulator with a **Google Play** (or Google APIs) system image: FCM needs Google Play
   services. Sign in to a Google account on the emulator if Play services asks for it.
2. Run the app, sign in to an account with a household and allow notifications (Android 13+ asks).
3. Send a message to the token from the log or the `dispositivos` table:
   - **Firebase console:** *Messaging › New campaign › Notifications*, *Send test message*, paste the
     token. Add the data fields (`tipo`, `alertaId`, `habitacion`, `ocurridaEn`) under *Additional
     options › Custom data* so the app opens the right screen.
   - **FCM HTTP v1 API** (needs a token with the `firebase.messaging` scope, for example from a
     service account and `gcloud auth print-access-token`):
     ```bash
     curl -X POST "https://fcm.googleapis.com/v1/projects/te-tengo-9ad70/messages:send" \
       -H "Authorization: Bearer $(gcloud auth print-access-token)" \
       -H "Content-Type: application/json" \
       -d '{"message":{"token":"<tokenPush>",
            "notification":{"title":"Posible caída de Rosa en la Sala","body":"10:42 · Toca para ver qué hacer y llamarla."},
            "data":{"tipo":"ALERTA_CAIDA","alertaId":"<id>","habitacion":"Sala","ocurridaEn":"2026-10-07T15:42:00Z"}}}'
     ```
   The same request reaches an iPhone or iOS simulator token once the APNs key is uploaded.
4. End to end with the backend: once its push adapter delivers through FCM, a `caida` event from the
   household agent (`POST /api/agente/eventos`) pushes `ALERTA_CAIDA` to every member device.
