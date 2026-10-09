# Release pipeline

**Build once, deploy many.** A push to `release/x.y.z` or `hotfix/x.y.z` runs [`release.yml`](../.github/workflows/release.yml): it builds every artifact once, deploys those same files to **staging** and then to **produccion**, each stage after an approval on its environment, and finally opens the pull request to `main`. `main` and the tag come last, after production is approved: [`etiquetar.yml`](../.github/workflows/etiquetar.yml) tags the release and deploys nothing.

## Channels × stages × switches
| Channel | Build (no environment) | Staging (`staging`, approval) | Produccion (`produccion`, approval) | Switch |
|---|---|---|---|---|
| **PWA** (web app, [WEB_PWA.md](WEB_PWA.md)) | `PWA`: `flutter build web --base-href /` with the Firebase web config, plus `deploy/pwa/_headers` and `robots.txt` (reusable [`build-web.yml`](../.github/workflows/build-web.yml)) | `Staging · PWA`: Pages project `te-tengo-app`, alias `staging`, <https://staging.te-tengo-app.pages.dev> | `Produccion · PWA`: `te-tengo-app` production (branch `main`), <https://app.tetengo.reqsai.tech> | `ENABLE_PWA` |
| **APK** (sideload, [RELEASE_ANDROID.md](RELEASE_ANDROID.md#sideload-distribution-no-play-store)) | `APK`: signed universal `te-tengo.apk` + `.sha256` (reusable [`build-apk.yml`](../.github/workflows/build-apk.yml)); always built | `Staging · APK`: R2 `te-tengo-descargas/staging/te-tengo.apk` | `Produccion · APK`: R2 `te-tengo-descargas/te-tengo.apk`, the landing's download | `ENABLE_APK` |
| **Google Play**, internal testing track | `AAB`, only when the switch is on | — | `Produccion · Google Play (internal)` | `ENABLE_PLAY_STORE` |
| **TestFlight** (iOS) | `IPA` on `macos-26`, only when the switch is on | — | `Produccion · TestFlight` | `ENABLE_IOS` |
| *(every channel)* | — | the whole stage | — | `ENABLE_STAGING` |

Smoke checks after each deploy:
- **PWA:** `GET <url>/` answers `200` and `<url>/version.json` has this build's version and build number (Flutter writes it from `pubspec.yaml`), retried for 2 minutes.
- **APK:** `HEAD <DESCARGAS_BASE_URL>/<key>` answers `200` with the APK's size, and the public `.sha256` equals the uploaded one.
- **Google Play** and **TestFlight:** the upload itself; TestFlight waits until App Store Connect has processed the build.

## Job graph
```
Version and configuration ─┬─ APK ─┐
                           ├─ PWA ─┤
                           ├─ AAB ─┤ (ENABLE_PLAY_STORE)
                           └─ IPA ─┤ (ENABLE_IOS)
                                   ├─ Staging · PWA ─┐   environment staging   (ENABLE_STAGING + ENABLE_PWA)
                                   └─ Staging · APK ─┤   environment staging   (ENABLE_STAGING + ENABLE_APK)
                                                     ├─ Produccion · PWA ──────────┐  environment produccion (ENABLE_PWA)
                                                     ├─ Produccion · APK ──────────┤  environment produccion (ENABLE_APK)
                                                     ├─ Produccion · Google Play ──┤  environment produccion (ENABLE_PLAY_STORE)
                                                     └─ Produccion · TestFlight ───┤  environment produccion (ENABLE_IOS)
                                                                                   └─ Open the pull request to main
```
- **One approval per stage.** Every staging job needs every build, and every produccion job needs every staging job, so the jobs of one environment wait together and one review (*Review deployments*) approves them all.
- **A skipped job does not block.** A job whose switch is off is skipped, and the jobs after it still run. With `ENABLE_STAGING` off, the produccion jobs run right after the builds.
- **A failure does.** A failed build, a failed staging smoke check or a rejected staging approval skips every produccion job and the pull request.
- **The plan.** The first job writes the plan to the run summary: each stage × channel, and either *after approval* or the switch that skips it.
- **Pull request to `main`.** `Open the pull request to main` opens `release: x.y.z` (`release/x.y.z` → `main`) with what was deployed where, or comments on it when it is already open. Merging it is a human action (the rulesets require a review and the `Format and analyze` and `Tests and coverage` checks, which `CI` runs on every push to `release/*` and `hotfix/*`).
- **On `main`.** `etiquetar.yml` creates the tag `vx.y.z` (the `pubspec.yaml` version without `+N`) and a GitHub Release whose notes are the build number and the `## [x.y.z]` section of `CHANGELOG.md`, skipped when the tag exists. It then opens the back-merge pull request `chore: merge release x.y.z back into develop` (`main` → `develop`).
- **Re-running.** A new push to the same release branch runs the pipeline again with new artifacts. Runs of one branch take turns (concurrency group per branch): a deploy is never cancelled, and a run that is still queued is replaced by a newer one. To let a newer run start while an older one waits for approval, reject the older one.
- **Pull requests.** A pull request that changes `android/`, `pubspec.*`, `release.yml` or `build-apk.yml` runs only the APK build (and the AAB when `ENABLE_PLAY_STORE` is on) as a check. `CI` builds the PWA on every pull request.
- **Branch and version.** On `release/x.y.z` or `hotfix/x.y.z`, `x.y.z` must equal the `pubspec.yaml` version, or the run stops.

## Switches
The switches are **organization variables**: *Te-Tengo-Tech → Settings → Secrets and variables → Actions → Variables*. A channel is **on only when its variable is exactly `true`**. `false`, any other value, or no variable at all means off.

| Variable | Read by | When it is not `true` |
|---|---|---|
| `ENABLE_STAGING` | `release.yml` | Both staging jobs are skipped; produccion follows the builds |
| `ENABLE_PWA` | `release.yml` | Both PWA deploys are skipped (the PWA is still built) |
| `ENABLE_APK` | `release.yml` | Both R2 uploads are skipped (the APK is still built, as an artifact) |
| `ENABLE_PLAY_STORE` | `release.yml` | The AAB is not built and the Play upload is skipped |
| `ENABLE_IOS` | `release.yml` | The IPA is not built (no macOS runner starts) and the TestFlight upload is skipped |

Other organization variables (`ENABLE_DEV`, `ENABLE_API_*`, `ENABLE_LANDING_*`, `ENABLE_DESKTOP_*`, `ENABLE_WINDOWS_*`, `ENABLE_MAC_*`) switch the other repositories.

**When a switch is on and its configuration is missing, the run fails** in `Version and configuration`, before any build, with an error that names each missing secret or variable. A release is never silently left out. Turn a channel on only after its one-time setup is done.

## Secrets and variables
Secrets are **repository** secrets (*Settings → Secrets and variables → Actions → Secrets*); the variables are repository variables unless marked otherwise.

| Channel | Secrets | Variables |
|---|---|---|
| PWA | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` | `TT_API_URL`; `TT_FIREBASE_WEB_API_KEY`, `TT_FIREBASE_WEB_APP_ID`, `TT_FIREBASE_WEB_MESSAGING_SENDER_ID`, `TT_FIREBASE_WEB_PROJECT_ID`, `TT_FCM_VAPID_KEY` (required); `TT_FIREBASE_WEB_AUTH_DOMAIN`, `TT_FIREBASE_WEB_STORAGE_BUCKET`, `TT_FIREBASE_WEB_MEASUREMENT_ID` (optional) |
| APK | `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `GOOGLE_SERVICES_JSON` | `TT_API_URL`, `DESCARGAS_BASE_URL`; optional `DESCARGAS_R2_BUCKET` (default `te-tengo-descargas`) |
| Google Play | `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `GOOGLE_SERVICES_JSON`, `PLAY_SERVICE_ACCOUNT_JSON` | `TT_API_URL`; optional `PLAY_RELEASE_STATUS` (`completed` by default, `draft` while the app is a draft in Play Console) |
| TestFlight | `IOS_DIST_CERT_P12_BASE64`, `IOS_DIST_CERT_PASSWORD`, `IOS_PROVISIONING_PROFILE_BASE64`, `GOOGLE_SERVICE_INFO_PLIST`, `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_PRIVATE_KEY` | `TT_API_URL` |

| Name | Kind | Content |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | secret | Cloudflare API token with *Account → Cloudflare Pages: Edit* and *Account → Workers R2 Storage: Edit* |
| `CLOUDFLARE_ACCOUNT_ID` | secret | The Cloudflare account ID (dashboard, *Account home*, or `wrangler whoami`) |
| `TT_API_URL` | variable; a secret of the same name also works | HTTPS URL of the production API, compiled into every build (`--dart-define=TT_API_URL=…`) |
| `TT_FIREBASE_WEB_*`, `TT_FCM_VAPID_KEY` | variables | Firebase web config and web push key of the PWA; public values ([WEB_PWA.md](WEB_PWA.md#firebase-web-config-and-vapid-key)) |
| `DESCARGAS_BASE_URL` | variable | Public URL of the R2 bucket, e.g. `https://pub-<id>.r2.dev` (for the smoke check and the links in the summary) |
| `ANDROID_*`, `GOOGLE_SERVICES_JSON`, `PLAY_SERVICE_ACCOUNT_JSON` | secrets | See [RELEASE_ANDROID.md](RELEASE_ANDROID.md#secrets-and-variables-settings--secrets-and-variables--actions) |
| `IOS_DIST_CERT_P12_BASE64` | secret | `base64 -i distribution.p12`: the **Apple Distribution** certificate with its private key |
| `IOS_DIST_CERT_PASSWORD` | secret | Password chosen when exporting the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | secret | `base64 -i Te_Tengo_App_Store.mobileprovision`: the **App Store** profile of `tech.tetengo.teTengo`, made with that certificate |
| `GOOGLE_SERVICE_INFO_PLIST` | secret | `base64 -i ios/Runner/GoogleService-Info.plist` (Firebase iOS app, [FIREBASE.md](FIREBASE.md)) |
| `APP_STORE_CONNECT_KEY_ID` | secret | Key ID of the App Store Connect API key |
| `APP_STORE_CONNECT_ISSUER_ID` | secret | Issuer ID shown above the list of keys |
| `APP_STORE_CONNECT_PRIVATE_KEY` | secret | The whole `AuthKey_<key id>.p8` file, plain text with its `BEGIN`/`END` lines |

The pull requests opened by the workflows use `GITHUB_TOKEN`; the repository allows GitHub Actions to create pull requests (*Settings → Actions → General → Workflow permissions*).

## Costs
| Item | Cost | Source |
|---|---|---|
| PWA and APK | No store fee. Hosting is the team's Cloudflare account: Pages and R2 (public bucket) within the free tier | — |
| Google Play developer account | **US$25, once** | [Play Console Help: register for a developer account](https://support.google.com/googleplay/android-developer/answer/6112435) |
| Apple Developer Program (TestFlight, App Store, APNs) | **99 USD per membership year**. Prices may vary by region. Nonprofits, accredited educational institutions and government entities can request a fee waiver | [Apple Developer Program: enrollment](https://developer.apple.com/programs/enroll/) |
| GitHub Actions minutes, Linux and macOS | Free: the repository is public and the workflows use standard runners (`ubuntu-latest`, `macos-26`; not the paid `-large`/`-xlarge` ones). A private repository would be billed for them | [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions) |

## Turn on Google Play
1. Do the one-time setup in [RELEASE_ANDROID.md](RELEASE_ANDROID.md#one-time-setup-account-owner), steps 1 to 5:
   - the Play Console account (US$25);
   - the app `tech.tetengo.te_tengo`, taken from `applicationId` in `android/app/build.gradle.kts`;
   - the **first AAB uploaded by hand**, since the API cannot create the first release;
   - the service account.
2. Save `PLAY_SERVICE_ACCOUNT_JSON`, and the repository variable `TT_API_URL` if it is not set. The release key and `GOOGLE_SERVICES_JSON` already exist.
3. Set the organization variable `ENABLE_PLAY_STORE` to `true`.
4. Push the next `release/x.y.z` and approve `Produccion · Google Play (internal)`. While the app is still a draft in Play Console, set the repository variable `PLAY_RELEASE_STATUS` to `draft`, and delete it once the app has been reviewed.

## Turn on TestFlight
Done once by the account owner, on a Mac.

1. **Apple Developer Program.** Enroll at <https://developer.apple.com/programs/enroll/> (99 USD per year). An *individual* membership is enough for the thesis; an *organization* needs a D-U-N-S number.
2. **App ID with push.**
   - Where: *Certificates, Identifiers & Profiles → Identifiers → +*.
   - What: an explicit App ID `tech.tetengo.teTengo`, the Runner target's `PRODUCT_BUNDLE_IDENTIFIER`, with the **Push Notifications** capability.
   - Then upload the APNs key to Firebase ([FIREBASE.md](FIREBASE.md), step 4).
3. **App record.** *App Store Connect → Apps → + → New App*: iOS, name «Te Tengo», bundle ID `tech.tetengo.teTengo`, any SKU (e.g. `te-tengo`).
4. **Distribution certificate.**
   1. In *Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority*, save the request to disk.
   2. Under *Certificates → +*, choose **Apple Distribution** and upload the request.
   3. Download the `.cer` and open it, so it joins the private key in the login keychain.
   4. In *Keychain Access → My Certificates*, right-click it and choose *Export* as `.p12` with a password. Keychain Access writes a `.p12` that `security import` reads; one exported with OpenSSL 3 defaults may not import.
   5. Save the secrets:
      ```bash
      base64 -i distribution.p12 | gh secret set IOS_DIST_CERT_P12_BASE64
      gh secret set IOS_DIST_CERT_PASSWORD        # prompts for the value
      ```
   6. Keep the `.p12` and its password in the team's password manager. The certificate lasts one year.
5. **Provisioning profile.**
   1. Under *Profiles → +*, choose *Distribution → App Store Connect*. Select the App ID `tech.tetengo.teTengo` and the certificate from step 4, and name it e.g. «Te Tengo App Store».
   2. Download it and save the secret:
      ```bash
      base64 -i Te_Tengo_App_Store.mobileprovision | gh secret set IOS_PROVISIONING_PROFILE_BASE64
      ```
   3. Make a new profile, and update the secret, whenever the certificate is renewed or the App ID's capabilities change.
6. **Firebase iOS config:**
   ```bash
   base64 -i ios/Runner/GoogleService-Info.plist | gh secret set GOOGLE_SERVICE_INFO_PLIST
   ```
   The workflow checks that its `BUNDLE_ID` is `tech.tetengo.teTengo`.
7. **App Store Connect API key.**
   1. In *App Store Connect → Users and Access → Integrations → App Store Connect API → Team Keys → +*, create a key with the **App Manager** role.
   2. Download `AuthKey_<key id>.p8`. Apple offers it only once.
   3. Save the secrets:
      ```bash
      gh secret set APP_STORE_CONNECT_KEY_ID --body <key id>
      gh secret set APP_STORE_CONNECT_ISSUER_ID --body <issuer id>
      gh secret set APP_STORE_CONNECT_PRIVATE_KEY < AuthKey_<key id>.p8
      ```
8. **API URL.** `gh variable set TT_API_URL --body https://<api>`, if it is not set yet.
9. **TestFlight testers.**
   - **Internal testers:** up to 100 App Store Connect users of the team. They get builds without review.
   - **External testers:** up to 10 000. They need *Test Information* and a beta review of the first build.
   - **Export compliance:** each build shows *Missing Compliance* until someone answers the encryption question in App Store Connect. To answer it once for every build, the team can add `ITSAppUsesNonExemptEncryption` to `ios/Runner/Info.plist`. That is a legal declaration, so it is left to the owners.
10. **Switch it on.** Set the organization variable `ENABLE_IOS` to `true`. Push the next `release/x.y.z` and approve `Produccion · TestFlight`.

### How the iOS build signs
- **Runner.** The `IPA` job runs on `macos-26` with Xcode 26.6, selected by `XCODE_VERSION` in the workflow. Since 28 April 2026 App Store Connect accepts only builds made with Xcode 26 or later ([Apple: SDK minimum requirements](https://developer.apple.com/news/upcoming-requirements/)).
- **Certificate and profile.** As in [GitHub's guide to signing Xcode apps on macOS runners](https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications):
  - the certificate goes into a temporary keychain with a random password;
  - the profile goes into the runner's profile folders;
  - both are deleted at the end of the job.
- **Checks on the profile.** Before building, the workflow checks that the profile:
  - is an App Store profile (no device list);
  - is for `<team>.tech.tetengo.teTengo`;
  - has `aps-environment: production`;
  - has not expired;
  - contains the imported certificate.
- **Manual signing.** The project keeps automatic signing for developers. On the runner only, the workflow appends manual signing to `ios/Flutter/Release.xcconfig`, the Runner target's base configuration: `CODE_SIGN_STYLE`, `DEVELOPMENT_TEAM`, `PROVISIONING_PROFILE_SPECIFIER` and `CODE_SIGN_IDENTITY`. So the Swift package targets of the plugins are not affected.
- **Export options.** It writes an `ExportOptions.plist`:
  - `method: app-store-connect`;
  - `signingStyle: manual`;
  - the profile UUID for the bundle ID;
  - `manageAppVersionAndBuildNumber: false`.
- **Build.** It runs `flutter build ipa --release --export-options-plist=…` ([Flutter: build and release an iOS app](https://docs.flutter.dev/deployment/ios)) with:
  - `--build-name`/`--build-number` from `pubspec.yaml`, which become `CFBundleShortVersionString`/`CFBundleVersion`;
  - `--dart-define=TT_API_URL`.
- **Checks on the IPA.** It verifies:
  - the code signature;
  - the bundle ID and version;
  - `aps-environment: production`;
  - `get-task-allow: false`;
  - that `GoogleService-Info.plist` is inside.

  It keeps `te-tengo-<version>-<build>.ipa` and its SHA-256 as the `te-tengo-ios-<version>-<build>` artifact for 30 days.
- **Upload.** `Produccion · TestFlight` sends the IPA with [`apple-actions/upload-testflight-build`](https://github.com/Apple-Actions/upload-testflight-build), pinned by commit SHA. Its default backend is the App Store Connect API, which runs on Linux. The job waits until App Store Connect has processed the build, so an invalid binary fails the run.
  - Flutter's guide also shows `xcrun altool --upload-app`, which still works. The App Store Connect API path needs no Transporter or Xcode on the runner.
- **Version.** The `+N` of `pubspec.yaml` must grow for every upload of the same version, and the version must be higher than the last one approved for the App Store.
