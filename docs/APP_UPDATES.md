# App updates (US-43)

How the app learns about a new version of itself and of Te Tengo Captura, and how each platform
updates. Code: `lib/features/actualizaciones/`; API: `GET /api/versiones` (contract §12).

## Checking
- **What:** `GET /api/versiones`, public and cache-friendly. It is called **without the session token**
  (`clienteVersionesProvider`: the API's base URL and `Api-Version` only), because the resource server
  answers `401` to an expired token even on a public path. On Android and iOS the client sends
  `If-None-Match` with the last `ETag` and reuses the last answer on `304`; the browser revalidates by
  itself (and `If-None-Match` is not a header the API's CORS allows).
- **When** (`PlanBusqueda`, **[implementation choice]**): when the app opens, once a day while it stays
  open, on «Buscar actualizaciones» in Ajustes › «Acerca de Te Tengo», and when it comes back from the
  background if the last answer is older than the API's `max-age` (5 minutes).
- **Which channel** (`infoAppProvider`, `canalPara`): the web app reads `pwa`; Android reads `play` when
  Google Play installed it (`package_info_plus`'s `installerStore` is `com.android.vending`) and `apk`
  otherwise; the iPhone reads `ios` and says «TestFlight» when the receipt is TestFlight's
  (`com.apple.testflight`) and «App Store» otherwise.
- **Comparing:** numerically by `MAJOR.MINOR.PATCH`, ignoring `+build` (`NumeroVersion`). Below `version`
  the bar offers the update; below `versionMinima` the minimum-version screen blocks the app (CA-43.8).
- **No information:** an older backend (`404`), a network error, a channel that is `null` or an app
  whose version cannot be read show nothing, and never an error, except «No pudimos buscar.» after
  «Buscar actualizaciones» without a connection.
- **The running version** comes from `package_info_plus`. On the web it is the build's `version.json`,
  read once when the app starts: the page and `version.json` are revalidated on every load
  (`deploy/pwa/_headers`, `Cache-Control: no-cache`), so it is the build that page loaded. A deploy that
  lands in the second between loading `main.dart.js` and reading `version.json` would only hide the
  notice until the next start.

## Never during an alert or a live view (CA-43.9)
`GuardiaActualizaciones` (in `MaterialApp.builder`, above the router) follows the screen on top. While
an alert is active, or an alert (`/alerta/…`, `/alertas/…`) or a live view (`/vivo`, and anything under
it such as «Ver todas») is open:
- the bar is hidden (it only lives above the four tabs anyway);
- «Acerca de» disables the action with «Al cerrar la alerta.»;
- a verified APK waits (`FaseActualizacion.esperando`) and the Android installer opens once they close;
- the minimum-version screen never covers them.

## The bar and «Acerca de»
One component (`BarraActualizacion`) above the content of the four tabs, never on an alert or a live
view: «Hay una versión nueva · Actualizar» (PWA, Google Play), «Hay una versión nueva (0.6.0)» with «Qué
cambió» (APK), «Hay una versión nueva · TestFlight/App Store» with «Abrir» (iPhone); the same bar shows
the download, its check and the errors. «Acerca de Te Tengo» shows the version and platform, the same
states as cards, «Buscar actualizaciones», and «PCs de la casa» with each PC's Te Tengo Captura. After an
update, the next start says «Te Tengo se actualizó · Versión 0.6.0.» (the version that chose
«Actualizar» is kept under the device key `dispositivo|actualizacion-desde`).

## Per platform
### Web app (PWA, CA-43.4)
«Actualizar» shows «Actualizando…», asks the browser for the service worker again
(`registration.update()`; `web/firebase-messaging-sw.js` skips waiting and serves the app network first)
and reloads the page, which revalidates every file and loads the new build.

### Android, sideloaded APK (CA-43.5)
1. Download `url` with its own Dio client (no token): «Descargando 0.6.0 · 42 %» with «Cancelar», to the
   app's cache folder `actualizaciones/`.
2. «Comprobando la descarga…»: the file's SHA-256 must equal `sha256`. If it differs, or `sha256` is
   missing, the file is deleted and nothing is installed («No se pudo verificar la descarga · La
   borramos. Sigues con la 0.5.0.»).
3. If Android's «Instalar apps desconocidas» is off for the app (`canRequestPackageInstalls()`), the
   screen «Permite instalar la actualización» explains it in three steps and «Abrir ajustes» opens
   `ACTION_MANAGE_UNKNOWN_APP_SOURCES` for this package; back with the permission, the installer opens.
   «Ahora no» leaves «Falta el permiso de Android · Sin él no se instala.».
4. The Android installer opens with the file through the app's FileProvider
   (`${applicationId}.actualizaciones`, `res/xml/actualizaciones.xml`) and a temporary read grant
   (`ACTION_INSTALL_PACKAGE` with `EXTRA_RETURN_RESULT`, `MainActivity`, channel
   `tech.tetengo.te_tengo/actualizaciones`). If the family cancels it, «No se instaló · Cancelaste la
   instalación.»; «Actualizar» opens the installer again with the same verified file, without
   downloading it again.
5. Errors keep the installed version: «Sin internet · No se pudo descargar.», «No se pudo descargar ·
   Sigues con la 0.5.0.» Leftover downloads are deleted at the next start.

**The same signing certificate.** Android only installs the new APK over the app when both are signed
with the same release key (and the new one has a higher versionCode); otherwise the installer refuses it
and the app shows «No se instaló». Nothing in the app can work around it ([RELEASE_ANDROID.md](RELEASE_ANDROID.md#how-updates-work)).

**`REQUEST_INSTALL_PACKAGES` stays out of Google Play builds.** Google Play restricts that permission
and updates its own installs, so it is declared in `android/app/src/sideload/AndroidManifest.xml`, which
`android/app/build.gradle.kts` merges into the release and profile builds only when Gradle is **not**
building an app bundle (`flutter build appbundle` runs a `bundle*` task). Debug builds declare it in
`src/debug/AndroidManifest.xml`. The Gradle property `tt.googlePlay` overrides the guess:
`flutter build appbundle --android-project-arg=tt.googlePlay=true` (or `false`). The FileProvider itself is
in every build; without the permission the Play build never uses it. To check a build:
`aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk` lists it, and
`unzip -p app-release.aab base/manifest/AndroidManifest.xml | grep -a REQUEST_INSTALL_PACKAGES` finds
nothing.

### Android from Google Play (CA-43.5)
Only when Google Play installed the app. «Actualizar» runs Play's in-app **flexible** update
(`in_app_update`: Play's sheet, the download in the background, then the restart); below `versionMinima`
the minimum-version screen's «Abrir la tienda» runs the **immediate** update. The app is not on Play yet,
so every call is guarded: on any error (or when Play does not offer the version yet) nothing happens,
except that «Abrir la tienda» falls back to the store page (`url`).

### iPhone (CA-43.6)
«Abrir» (or «Abrir TestFlight» / «Abrir App Store» in «Acerca de», «Abrir la tienda» on the
minimum-version screen) opens `url` outside the app. The app never downloads anything.

## Minimum version (CA-43.8)
Below `versionMinima` the app is covered by «Actualiza Te Tengo para seguir recibiendo alertas» / «Tienes
la 0.5.0. Toma un minuto.» with the platform's path («Abrir la tienda» and «Se abre Google Play.» / «Se
abre App Store.» / «Se abre TestFlight.»; «Actualizar» for the APK, with its download and errors on the
screen, and for the PWA) and «Llamar a Rosa». The app stays built underneath, so an active alert still
opens by itself and pushes still open their alert; alert and live view screens, the start and the
permission screen are never covered, and the active alert strip is shown on the screen.

## The PCs (CA-43.7)
Each PC's `versionAgente` is compared with `windows` or `mac` by its `sistemaOperativo`. An older one
reads «Versión anterior (0.4.3)» in «PCs de la casa» (Cámaras), «Te Tengo Captura 0.4.3 · versión
anterior» in the PC's header, and its detail says «Se actualizará sola.» (`actualizacionAutomatica:
true`) or «Pide a quien está en la casa que la actualice.» (`false`). A PC that never said (`null`, an
older Te Tengo Captura) shows the title only **[implementation choice]**. Activity shows `PC_ACTUALIZADA`
«Sala-Rosa se actualizó a 0.5.0» (who: Te Tengo Captura; before → after) and
`ACTUALIZACION_AUTOMATICA_ACTIVADA/_DESACTIVADA` «Desde la PC Sala-Rosa: se activó / se desactivó la
actualización automática».

## Tests
`test/features/actualizaciones/`: version comparison and channels, the check schedule, the controller
(APK download, SHA-256 match and mismatch, download errors, cancel, the permission, the cancelled
installer, waiting for a live view, Play guarded, PWA, iPhone, the «se actualizó» notice), and the
screens (bar per channel, waiting during an alert, minimum version, «Acerca de», the permission screen,
PC notices, activity). Real install on a phone, Play's in-app update and the store URLs are not verified
(docs/BLOCKERS.md).
