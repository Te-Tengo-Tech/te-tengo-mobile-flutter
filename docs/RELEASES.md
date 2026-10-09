# Release channels

A release merged into `main` can reach users through four channels. Each one has an **on/off switch**, an organization-level Actions variable, and each publishing step waits for an approval on the **`produccion` environment** (required reviewers, `main` only). Nothing reaches users without that approval.

| Channel | Who builds and publishes it | Where users get it | Switch |
|---|---|---|---|
| **PWA** (web app) | The landing's `publicar.yml`, started by [`notificar-landing.yml`](../.github/workflows/notificar-landing.yml) | `https://app.tetengo.reqsai.tech/` ([WEB_PWA.md](WEB_PWA.md)) | `ENABLE_PWA` |
| **APK** (sideload) | The landing's `publicar.yml`, which calls [`build-apk.yml`](../.github/workflows/build-apk.yml) | `te-tengo.apk` on Cloudflare R2, linked from the landing ([RELEASE_ANDROID.md](RELEASE_ANDROID.md#sideload-distribution-no-play-store)) | `ENABLE_APK` |
| **Google Play**, internal testing track | [`release-android.yml`](../.github/workflows/release-android.yml), job `Upload to Google Play (internal)` | Play Store, for the testers on the internal track | `ENABLE_PLAY_STORE` |
| **TestFlight** (iOS) | [`release-ios.yml`](../.github/workflows/release-ios.yml), job `Upload to TestFlight` | The TestFlight app, for the testers of the App Store Connect app | `ENABLE_IOS` |

## Switches
The switches are **organization variables**: *Te-Tengo-Tech → Settings → Secrets and variables → Actions → Variables*. There is one control panel for every repository, and each one needs repository access *All repositories*, or this repository among the selected ones. A channel is **on only when its variable is exactly `true`**. `false`, any other value, or no variable at all means off.

| Variable | Read by | When it is not `true` |
|---|---|---|
| `ENABLE_PWA` | `notificar-landing.yml` here; the landing's `publicar.yml` | The landing skips the PWA deploy. If `ENABLE_APK` is not `true` either, this repository does not send the dispatch |
| `ENABLE_APK` | `notificar-landing.yml` here; the landing's `publicar.yml` | The landing skips the APK upload. If `ENABLE_PWA` is not `true` either, this repository does not send the dispatch |
| `ENABLE_PLAY_STORE` | `release-android.yml` | On a push to `main` the AAB is not built and the Play job is skipped, so no approval is asked. Pull requests and manual runs still build the AAB as a check |
| `ENABLE_IOS` | `release-ios.yml` | Every job is skipped, so no macOS runner starts and no approval is asked |

Other organization variables (`ENABLE_API_*`, `ENABLE_LANDING_*`, `ENABLE_DESKTOP_*`, `ENABLE_WINDOWS_*`) switch channels of the other repositories.

**When a switch is on and its configuration is missing, the run fails.** `release-android.yml` and `release-ios.yml` check every secret and variable of their channel before building. A missing one is an error that names it, so a release is never silently left out. Turn a channel on only after its one-time setup is done.

## What runs on a push to `main`
`CI` and the APK build check of `Release Android` always run. The rest depends on the switches.

| Switches | Release Android | Release iOS | Notify the landing (after `CI` succeeds) |
|---|---|---|---|
| All four off | `Build AAB` skipped, `Upload to Google Play (internal)` skipped, `APK` (artifact only) runs | `Build IPA` skipped, `Upload to TestFlight` skipped | Skipped |
| `ENABLE_PWA` and/or `ENABLE_APK` on | Same | Same | Sends `publicar-movil`. The landing builds, waits for approval on its `produccion`, then publishes the channels that are on |
| `ENABLE_PLAY_STORE` on | `Build AAB` (fails at once if a Play secret is missing) → `Upload to Google Play (internal)` waits for approval → uploads. `APK` runs | Unchanged | Unchanged |
| `ENABLE_IOS` on | Unchanged | `Build IPA` on `macos-26` (fails at once if an iOS secret is missing) → `Upload to TestFlight` waits for approval → uploads | Unchanged |

A manual run (*Actions → Release Android / Release iOS → Run workflow*) follows the same switches. From a branch other than `main` it only builds, because the `produccion` environment only accepts `main`. Both workflows take a `build_number` input that overrides the `+N` of `pubspec.yaml`.

## Secrets and variables per channel
Secrets are **repository** secrets: *Settings → Secrets and variables → Actions → Secrets*. The landing's secrets are listed in its [docs/DEPLOY.md](https://github.com/Te-Tengo-Tech/te-tengo-landing-astro/blob/develop/docs/DEPLOY.md).

| Channel | In this repository | In the landing repository |
|---|---|---|
| PWA | `DISPATCH_TOKEN` (secret) | `TT_API_URL`, `TT_FIREBASE_WEB_*`, `TT_FCM_VAPID_KEY` (variables) and its Cloudflare secrets |
| APK | `DISPATCH_TOKEN` (secret) | The four `ANDROID_*` secrets with the **same** release key as here, `GOOGLE_SERVICES_JSON`, `TT_API_URL` and its R2 configuration |
| Google Play | Secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `GOOGLE_SERVICES_JSON`, `PLAY_SERVICE_ACCOUNT_JSON`; variable `TT_API_URL` | none |
| TestFlight | Secrets `IOS_DIST_CERT_P12_BASE64`, `IOS_DIST_CERT_PASSWORD`, `IOS_PROVISIONING_PROFILE_BASE64`, `GOOGLE_SERVICE_INFO_PLIST`, `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_PRIVATE_KEY`; variable `TT_API_URL` | none |

| Name | Kind | Content |
|---|---|---|
| `TT_API_URL` | repository **variable**; a secret of the same name also works | HTTPS URL of the production API, compiled into the Android and iOS apps (`--dart-define=TT_API_URL=…`). The landing has its own |
| `DISPATCH_TOKEN` | secret | Fine-grained token: resource owner `Te-Tengo-Tech`, only `te-tengo-landing-astro`, *Contents: Read and write* (README, *Release flow*) |
| `ANDROID_*`, `GOOGLE_SERVICES_JSON`, `PLAY_SERVICE_ACCOUNT_JSON` | secrets | See [RELEASE_ANDROID.md](RELEASE_ANDROID.md#secrets-and-variables-settings--secrets-and-variables--actions) |
| `IOS_DIST_CERT_P12_BASE64` | secret | `base64 -i distribution.p12`: the **Apple Distribution** certificate with its private key |
| `IOS_DIST_CERT_PASSWORD` | secret | Password chosen when exporting the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | secret | `base64 -i Te_Tengo_App_Store.mobileprovision`: the **App Store** profile of `tech.tetengo.teTengo`, made with that certificate |
| `GOOGLE_SERVICE_INFO_PLIST` | secret | `base64 -i ios/Runner/GoogleService-Info.plist` (Firebase iOS app, [FIREBASE.md](FIREBASE.md)) |
| `APP_STORE_CONNECT_KEY_ID` | secret | Key ID of the App Store Connect API key |
| `APP_STORE_CONNECT_ISSUER_ID` | secret | Issuer ID shown above the list of keys |
| `APP_STORE_CONNECT_PRIVATE_KEY` | secret | The whole `AuthKey_<key id>.p8` file, plain text with its `BEGIN`/`END` lines |

## Costs
| Item | Cost | Source |
|---|---|---|
| PWA and APK | No store fee. Hosting is the landing's Cloudflare account ([its DEPLOY.md](https://github.com/Te-Tengo-Tech/te-tengo-landing-astro/blob/develop/docs/DEPLOY.md)) | — |
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
4. Merge the next release into `main`, or run *Release Android* from `main`. Approve `Upload to Google Play (internal)`. While the app is still a draft in Play Console, run it by hand with `release_status: draft`.

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
10. **Switch it on.** Set the organization variable `ENABLE_IOS` to `true`. Merge the next release into `main`, or run *Release iOS* from `main`, and approve `Upload to TestFlight`.

### How the iOS build signs
- **Runner.** `Build IPA` runs on `macos-26` with Xcode 26.6, selected by `XCODE_VERSION` in the workflow. Since 28 April 2026 App Store Connect accepts only builds made with Xcode 26 or later ([Apple: SDK minimum requirements](https://developer.apple.com/news/upcoming-requirements/)).
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
- **Upload.** `Upload to TestFlight` sends the IPA with [`apple-actions/upload-testflight-build`](https://github.com/Apple-Actions/upload-testflight-build), pinned by commit SHA. Its default backend is the App Store Connect API, which runs on Linux. The job waits until App Store Connect has processed the build, so an invalid binary fails the run.
  - Flutter's guide also shows `xcrun altool --upload-app`, which still works. The App Store Connect API path needs no Transporter or Xcode on the runner.
- **Version.** The `+N` of `pubspec.yaml` must grow for every upload of the same version, and the version must be higher than the last one approved for the App Store.
