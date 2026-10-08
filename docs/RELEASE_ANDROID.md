# Releasing the Android app (Google Play, internal testing)

This document covers how the app reaches testers' phones through Google Play's **internal testing** track. The workflow [`release-android.yml`](../.github/workflows/release-android.yml) builds the signed Android App Bundle (AAB) and uploads it. The steps under *One-time setup* are done by hand, once, by the account owner.

## How the pipeline works
| Trigger | What happens |
|---|---|
| Pull request touching `android/`, `pubspec.*` or the workflow | Builds the release AAB (debug-signed) to keep the release path green; nothing is uploaded |
| Manual run (*Actions → Release Android → Run workflow*) | Builds the AAB, keeps it as a run artifact and, when configured, uploads it to the **internal** track. Optional inputs: `build_number` (versionCode override) and `release_status` (`completed` or `draft`) |
| Tag `mobile-v<version>`, e.g. `mobile-v1.0.0` | Same as a manual run. The tag must match `version:` in `pubspec.yaml` |

- **Version.** It comes from `pubspec.yaml`, as `version: <versionName>+<versionCode>`. Google Play rejects a versionCode it has already seen, so **bump the `+N` before every upload**, or pass `build_number` in a manual run.
- **Inert without secrets.** Each missing secret is listed in a notice on the run page, and the Play step is skipped. Without the upload key, the AAB is signed with the debug key: fine for checking the build, rejected by Play.

### Secrets and variables (*Settings → Secrets and variables → Actions*)
| Name | Kind | Content |
|---|---|---|
| `GOOGLE_SERVICES_JSON` | secret | `base64 -i android/app/google-services.json` (Firebase, [FIREBASE.md](FIREBASE.md)) |
| `ANDROID_KEYSTORE_BASE64` | secret | `base64 -i upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_PASSWORD` | secret | Passwords of the keystore and of the key |
| `ANDROID_KEY_ALIAS` | secret | Key alias, e.g. `upload` |
| `PLAY_SERVICE_ACCOUNT_JSON` | secret | JSON key of the service account with access to the app in Play Console (plain JSON, not base64) |
| `TT_API_URL` | **variable** | HTTPS URL of the production API, compiled into the app (`--dart-define`) |

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
   ```
   Without `key.properties`, the build logs that it uses the debug key.

## One-time setup (account owner)
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

## Future work: iOS (TestFlight)
- **Apple Developer Program.** iOS distribution needs it: **US$99 per year**, plus identity verification.
- **The equivalent path:**
  1. Create the App ID `tech.tetengo.teTengo` and the app record in App Store Connect.
  2. Upload the APNs key to Firebase ([FIREBASE.md](FIREBASE.md)).
  3. Build with `flutter build ipa` on a macOS runner, using an App Store Connect API key, distribution certificate and provisioning profile as secrets (for example with fastlane `match` + `pilot`).
  4. Upload to **TestFlight**. Internal testers (up to 100 team members) get builds without review; external testers (up to 10 000) need a light beta review.
- **Not built yet.** No iOS workflow exists yet, because it cannot run without the paid membership.
