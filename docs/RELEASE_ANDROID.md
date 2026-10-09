# Releasing the Android app (direct APK and Google Play)

This document covers the two ways the app reaches testers' phones:
- **Direct APK (sideload), the path for the pilot.** A signed universal APK, `te-tengo.apk`, downloaded from the landing page and installed without the Play Store. See *[Sideload distribution](#sideload-distribution-no-play-store)*.
- **Google Play's internal testing track,** optional, once the team has a Play Console account. It is switched on by the organization variable `ENABLE_PLAY_STORE` ([RELEASES.md](RELEASES.md) lists every channel and switch).

The workflow [`release-android.yml`](../.github/workflows/release-android.yml) builds both from the same commit and signs both with the same release key: the Android App Bundle (AAB) for Play and, through the reusable [`build-apk.yml`](../.github/workflows/build-apk.yml), the universal APK. The steps under *One-time setup* are done by hand, once, by the account owner.

## How the pipeline works
| Trigger | What happens |
|---|---|
| Pull request touching `android/`, `pubspec.*` or the workflow | Builds the release AAB and APK (debug-signed) to keep the release path green; nothing is uploaded |
| Push to `main` (a merged `release/*` or `hotfix/*` pull request) | Builds the APK and keeps it as the `te-tengo-apk` run artifact (`te-tengo.apk` and `te-tengo.apk.sha256`). With `ENABLE_PLAY_STORE` set to `true` it also builds the AAB (`…-aab` artifact), and the `Upload to Google Play (internal)` job then **waits for an approval on the `produccion` environment** and uploads it to the **internal** track. Otherwise both are skipped and no approval is asked |
| Manual run (*Actions → Release Android → Run workflow*) | Builds the AAB and the APK. From `main`, with `ENABLE_PLAY_STORE` set to `true`, the Play upload waits for approval; from any other branch it only builds, because the environment only accepts `main`. Optional inputs: `build_number` (versionCode override) and `release_status` (`completed` or `draft`) |

- **Version.** It comes from `pubspec.yaml`, as `version: <versionName>+<versionCode>`. Google Play rejects a versionCode it has already seen, and Android refuses to install an APK over a newer one, so **bump the `+N` before every release**, or pass `build_number` in a manual run.
- **The switch decides, not the secrets.** With `ENABLE_PLAY_STORE` off (`false` or unset) nothing is uploaded. With it set to `true`, a missing `PLAY_SERVICE_ACCOUNT_JSON`, release key, `GOOGLE_SERVICES_JSON` or `TT_API_URL` **fails the run** before the build, with an error that names it. Without the release key, a pull request or manual build signs the AAB and the APK with the runner's throwaway debug key: fine for checking the build, rejected by Play, and an APK that no later build can update.
- **The run summary** of the APK job shows the signing mode, the SHA-256 of the APK and the SHA-256 of its signing certificate (from `apksigner verify --print-certs`). Every release must show the same certificate fingerprint.

### Secrets and variables (*Settings → Secrets and variables → Actions*)
| Name | Kind | Content |
|---|---|---|
| `GOOGLE_SERVICES_JSON` | secret | `base64 -i android/app/google-services.json` (Firebase, [FIREBASE.md](FIREBASE.md)) |
| `ANDROID_KEYSTORE_BASE64` | secret | `base64 -i upload-keystore.jks` (the release key: Play upload key and APK signing key) |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_PASSWORD` | secret | Passwords of the keystore and of the key |
| `ANDROID_KEY_ALIAS` | secret | Key alias, e.g. `upload` |
| `PLAY_SERVICE_ACCOUNT_JSON` | secret | JSON key of the service account with access to the app in Play Console (plain JSON, not base64) |
| `TT_API_URL` | **variable** (a secret of the same name also works) | HTTPS URL of the production API, compiled into the app (`--dart-define`) |
| `ENABLE_PLAY_STORE` | **organization variable** (*Te-Tengo-Tech → Settings → Secrets and variables → Actions → Variables*) | `true` turns the Google Play upload on; anything else, or no variable, keeps it off |

With the GitHub CLI: `base64 -i upload-keystore.jks | gh secret set ANDROID_KEYSTORE_BASE64`, `gh secret set PLAY_SERVICE_ACCOUNT_JSON < play-service-account.json` and `gh variable set TT_API_URL --body https://api.example.com`.

## Local release build
1. **Create the upload key** once, and keep the `.jks` file and its passwords in the team's password manager. If it is lost, Play support can reset it, but that takes days:
   ```bash
   keytool -genkeypair -v -keystore android/app/upload-keystore.jks -storetype JKS \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. **Configure the build.** Copy [`android/key.properties.example`](../android/key.properties.example) to `android/key.properties` and fill it in. Both files are gitignored (`key.properties`, `*.jks`).
3. **Build:**
   ```bash
   flutter build appbundle --release --dart-define=TT_API_URL=https://<api>
   # → build/app/outputs/bundle/release/app-release.aab
   flutter build apk --release --dart-define=TT_API_URL=https://<api>
   # → build/app/outputs/flutter-apk/app-release.apk (universal: every ABI in one file)
   ```
   Without `key.properties`, the build logs that it uses the debug key.

## Sideload distribution (no Play Store)
For the pilot, the app is distributed as a single **universal APK** from the landing page. No Play Console account, fee or review is involved.

### Where the APK is published
- **Who publishes it.** The landing's publish workflow (repository `te-tengo-landing-astro`) builds the APK and **uploads `te-tengo.apk` and `te-tengo.apk.sha256` to Cloudflare R2**. The landing page links to that stable URL, which always serves the latest published APK.
- **Why not from here.** Run artifacts expire and are only downloadable by signed-in GitHub users; the landing needs a stable public URL.
- **When.** A release that reaches `main` publishes it: once `CI` passes there, [`notificar-landing.yml`](../.github/workflows/notificar-landing.yml) sends `repository_dispatch` `publicar-movil` with the commit SHA and the `pubspec.yaml` version, and the landing's run waits for an approval on its `produccion` environment before uploading (README, *Release flow*).
- **How the APK is built:** the reusable workflow [`build-apk.yml`](../.github/workflows/build-apk.yml) (`workflow_call`).
  - **What it does.** It checks out this repository at a given `ref`, builds `flutter build apk --release` and verifies the signature with `apksigner`. It keeps `te-tengo.apk` and `te-tengo.apk.sha256` as an artifact of the **calling** run, named `te-tengo-apk` by default.
  - **Outputs:** `artifact_name`, `version_name`, `version_code`, `signed`, `certificate_sha256` and `apk_sha256`.
  - **Who calls it.** `release-android.yml` uses it, and the landing calls it the same way:
  ```yaml
  jobs:
    apk:
      uses: Te-Tengo-Tech/te-tengo-mobile-flutter/.github/workflows/build-apk.yml@develop
      with:
        ref: develop            # branch, tag or commit to build
        build_number: "7"       # optional: must grow with every published APK
      secrets: inherit
    publicar:
      needs: apk
      if: needs.apk.outputs.signed == 'true'   # never publish a debug-signed APK
      runs-on: ubuntu-latest
      steps:
        - uses: actions/download-artifact@v8
          with:
            name: ${{ needs.apk.outputs.artifact_name }}
        # then upload te-tengo.apk and te-tengo.apk.sha256 to R2
  ```
- **What the calling repository needs:**
  - **Secrets:** `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD`, with the **same** release key as here. Optionally `GOOGLE_SERVICES_JSON`, and `TT_API_URL` as a secret or variable.
  - **`MOBILE_REPO_TOKEN`:** a fine-grained token with read-only *Contents* on this repository, used to check it out.
  - **Access from this repository:** none to configure. The repository is public, so any repository can call its reusable workflows (the *Settings → Actions → General → Access* setting only exists for private repositories).

### Installing it (what testers do)
1. **Open the landing page on the phone** and tap the Android download. Chrome may warn that the file can be harmful: choose «Descargar de todas formas».
2. **Open the downloaded file** from the notification or from *Archivos → Descargas*.
3. **Allow the install source.** The first time, Android asks to allow the browser or file manager to install apps: «Instalar apps desconocidas» → enable «Permitir de esta fuente», then go back. The path differs by brand; on most phones it is *Ajustes → Apps → Acceso especial → Instalar apps desconocidas*.
4. **Install.** Google Play Protect may show «App no reconocida» or «App no segura», because the app does not come from the Play Store: «Más detalles» → «Instalar de todas formas». Do not turn Play Protect off.
5. **Turn the install source off again.** Optional, but recommended: disable «Permitir de esta fuente» once installed.
6. **Open Te Tengo and accept notifications** when it asks, so alerts arrive.

Optional check before installing: compare the file's SHA-256 with `te-tengo.apk.sha256`, published next to it.

### How updates work
- **No automatic updates.** A sideloaded app is not updated by the Play Store. Testers update by downloading `te-tengo.apk` again from the same link and installing it over the current app: «¿Quieres actualizar esta app?» → «Actualizar». The session, settings and cached data are kept.
- **The team announces new versions** through the pilot's channel (WhatsApp or e-mail). An in-app «Hay una versión nueva» notice would need a backend field and copy in the prototype first, so it is future work.
- **An update only installs when both rules hold:**
  - **The same signing key.** The APK must be signed with the same release key as the installed one. With another key, Android shows «App no instalada» (signatures conflict) and the tester would have to uninstall first, losing the session. This is why debug-signed builds must never be published, and why **losing the keystore** means every tester reinstalls.
  - **A higher versionCode.** The `+N` in `pubspec.yaml`, or `build_number`, must be higher than the installed build.
- **Play and sideload do not mix.** With Play App Signing, Google signs the APKs it serves with its own app signing key, not the release key. A Play install and a sideloaded APK therefore cannot update each other. If the app later moves to Play, either have testers uninstall once, or, when creating the app in Play Console, choose to **use the existing release key as the app signing key** (*Use a different key → export and upload a key from Java keystore*), instead of letting Google generate one.

### Limits and risks
- **Firebase.** Push through FCM does not depend on the signing certificate. If Google sign-in or App Check is added later, register the release key's SHA-1 and SHA-256 in Firebase (`keytool -list -v -keystore upload-keystore.jks`).
- **Android developer verification.** Google announced that certified Android devices will require apps, sideloaded ones included, to come from **verified developers**: first in a few countries from September 2026, then worldwide in 2027. Peru was not in the first group. Before then, the owner should register the app in the Android Developer Console with the release key's certificate, or distribution must move to Play.
- **Corporate or child-managed phones** may block unknown sources altogether. Install those from Play, or on another phone.

## One-time setup (account owner)
0. **Release key, needed for both channels.** Create it as in *Local release build*, step 1, and save it as the four `ANDROID_*` secrets in this repository and in the landing repository (`te-tengo-landing-astro`), which publishes the APK. Keep two backups of the `.jks` and its passwords outside GitHub. Steps 1 to 8 below are only needed for Google Play.
1. **Google Play Console developer account.**
   - **Cost and verification.** A one-time **US$25** fee, plus identity verification with an ID document, at <https://play.google.com/console/signup>.
   - **Personal or organization.** A *personal* account is enough for the thesis. An *organization* account needs a D-U-N-S number, but is exempt from the testing rule below.
2. **Create the app.** In *Create app*: name «Te Tengo», default language Spanish (Latin America) or Spanish (Spain), type *App*, *Free*, and accept the declarations. The package name `tech.tetengo.te_tengo` is fixed by the **first uploaded AAB** and can never change.
3. **Play App Signing: upload key vs app signing key.**
   - **Play App Signing** is mandatory for new apps. Google generates and keeps the **app signing key**, which signs the APKs that phones install.
   - The team only holds the **upload key** above, which proves that an upload comes from the team.
   - If the upload key leaks or is lost, Play support resets it. The app signing key is never at risk.
   - For Firebase or Google sign-in, register the **app signing** certificate's SHA-1/SHA-256 in Firebase as well. Find it under *Test and release → App integrity*.
4. **The first upload is manual.**
   - The Play Developer API cannot upload to an app that has never had a build.
   - Build the AAB locally (or download the run artifact) and upload it in *Testing → Internal testing → Create new release*. This also enrolls the app in Play App Signing.
   - From then on the workflow uploads.
   - While the app is still a **draft** (never reviewed), the API only accepts `release_status: draft`, and the release is then rolled out from the console.
5. **Service account for the workflow.**
   1. In Google Cloud (any project, e.g. the Firebase project `te-tengo-9ad70`), enable the **Google Play Android Developer API**.
   2. Create a service account and a JSON key for it.
   3. In Play Console, *Users and permissions → Invite new users*, invite the service account's e-mail with access to this app. Grant *Release to testing tracks* and *View app information*.
   4. Save the JSON as `PLAY_SERVICE_ACCOUNT_JSON`.
6. **Internal testing for the presentation.**
   - **Who.** Create a tester list (*Internal testing → Testers*): up to 100 Google accounts.
   - **Availability.** Internal releases are available within minutes and **skip the full review**. That makes them the right track for the thesis demo and the pilot families.
   - **Install.** Testers accept the opt-in link and install from the Play Store like any app. Updates arrive through the store.
7. **Rule for new personal accounts.**
   - **Who it applies to.** Personal accounts created **after 13 November 2023** cannot publish to **production** right away.
   - **The requirement.** They must first run a **closed test with at least 12 testers opted in for 14 consecutive days**, then *Apply for production* from the dashboard. Google's review usually takes 7 days or less ([Play Console Help, *App testing requirements for new personal developer accounts*](https://support.google.com/googleplay/android-developer/answer/14151465)).
   - **Not needed for the thesis.** Internal testing is enough for the thesis and is not affected.
   - **If production is wanted.** Plan the closed test at least three weeks ahead.
8. **Switch the channel on.** Set the organization variable `ENABLE_PLAY_STORE` to `true` ([RELEASES.md](RELEASES.md#turn-on-google-play)). Until then no run uploads to Play.

## Store listing and policy forms
Play Console requires these under *Policy and programs → App content* before any review: closed or open testing and production. Fill them in early, since internal testing can start without them.
- **Privacy policy URL.**
  - **Where.** A public HTTPS page; the app should link to it as well. It must name the data controller, the data collected, the purposes, the retention, the sharing with processors (AWS, Firebase) and how to exercise rights.
  - **Peruvian law.** In Peru this is governed by **Ley 29733**, Ley de Protección de Datos Personales, and its regulation (D.S. 016-2024-JUS).
  - **Health data is sensitive.** Fall events and clips of an older adult count as health data, which is **sensitive data**. It needs express, written consent: the app's consent flow (US-05) is that record. The database must also be registered with the national authority (ANPD).
- **Data safety form.** Declare what the app and its backend collect and share:
  - **Personal info:** name and e-mail (accounts) and the phone number of the older adult's contact.
  - **Health and fitness:** fall and unstable-movement events.
  - **Photos and videos:** event clips and the live view. The camera is on the household PC, but the app displays and downloads the footage.
  - **Device IDs:** the FCM push token.
  - **App activity:** history and live-view access logs.
  - **Encryption and deletion.** State that data is encrypted in transit (HTTPS) and that users can ask for deletion: revoking consent deletes the clips (US-09).
- **Health apps declaration.** The app processes health-related information, so complete the *Health apps* form. It is not a medical device. Say so in the listing ("does not replace medical care or emergency services").
- **Content rating.** Answer the IARC questionnaire (no violence, gambling or user-to-user chat); the expected result is *Everyone / PEGI 3*.
- **Target audience and ads.** The audience is adults 18+; the app shows no ads.
- **App access.** Reviewers need a demo account with a household and alerts. Give the credentials of the seeded demo household (`seed-demo.sh` in the API repository) on a reachable API.
- **Notifications.** The app asks for `POST_NOTIFICATIONS` (Android 13+). No special declaration is needed, because it uses no exact alarms and no full-screen intents.

## iOS (TestFlight)
The iOS build and its TestFlight upload are in [`release-ios.yml`](../.github/workflows/release-ios.yml), switched by the organization variable `ENABLE_IOS`. The Apple Developer Program costs 99 USD per year. Setup, secrets and signing: [RELEASES.md](RELEASES.md#turn-on-testflight).
