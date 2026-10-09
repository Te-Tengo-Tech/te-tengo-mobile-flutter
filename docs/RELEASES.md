# Release pipeline

**Build once, test the candidate on staging, publish the same files from `main`, tag at the end.** This is Gitflow with release candidates (model C, «tag at the end», of the team's release strategy):

- A push to `release/x.y.z` or `hotfix/x.y.z` runs [`release.yml`](../.github/workflows/release.yml). It builds every file **once**, stores them as the **release candidate** `vx.y.z-rc.N` (a GitHub pre-release), deploys that candidate to **staging** after an approval, and opens the pull request `release: x.y.z` to `main`.
- Merging that pull request runs [`produccion.yml`](../.github/workflows/produccion.yml) on `main`. It finds the candidate that was tested and publishes **its files, without rebuilding**, to **produccion** after an approval. Only when every channel succeeds does it create the tag and GitHub Release `vx.y.z` and open the back-merge pull request to `develop`.
- [`rollback.yml`](../.github/workflows/rollback.yml) puts the files of an earlier `vx.y.z` back in produccion.
- `develop` deploys nothing. Pull requests run [`ci.yml`](../.github/workflows/ci.yml) only.

```mermaid
flowchart LR
  F["feature/* · bugfix/*"] -->|"PR + CI"| D[develop]
  D -->|"branch"| R["release/x.y.z"]
  M0[main] -->|"branch"| H["hotfix/x.y.z"]
  R & H -->|"push"| B["build once<br/>APK · PWA · AAB · IPA"]
  B --> C["pre-release vx.y.z-rc.N<br/>assets + SHA256SUMS"]
  C --> S{{"staging<br/>approval"}}
  S -->|"QA finds a bug: fix on the branch"| R
  S -->|"passed"| P["PR release: x.y.z → main"]
  P -->|"merge"| M[main]
  M --> T{"tree of main =<br/>tree of the rc?"}
  T -->|"no"| X["fail: build a new rc"]
  T -->|"yes"| Q{{"produccion<br/>approval"}}
  Q -->|"every channel OK"| V["tag + GitHub Release vx.y.z"]
  V --> BM["PR main → develop"]
  Q -->|"a channel failed"| RR["no tag; re-run failed jobs<br/>(same candidate)"]
```

## Channels × stages × switches
| Channel | Candidate asset (built once) | Staging (`staging`, approval) | Produccion (`produccion`, approval) | Switch |
|---|---|---|---|---|
| **PWA** (web app, [WEB_PWA.md](WEB_PWA.md)) | `te-tengo-pwa.tar.gz`: `flutter build web --base-href /` with the Firebase web config, plus `deploy/pwa/_headers` and `robots.txt` (reusable [`build-web.yml`](../.github/workflows/build-web.yml)) | `Staging · PWA`: Pages project `te-tengo-app`, alias `staging`, <https://staging.te-tengo-app.pages.dev> | `Produccion · PWA`: `te-tengo-app` production (branch `main`), <https://app.tetengo.reqsai.tech> | `ENABLE_PWA` |
| **APK** (sideload, [RELEASE_ANDROID.md](RELEASE_ANDROID.md#sideload-distribution-no-play-store)) | `te-tengo.apk` + `te-tengo.apk.sha256`: the signed universal APK (reusable [`build-apk.yml`](../.github/workflows/build-apk.yml)); always built | `Staging · APK`: R2 `te-tengo-descargas/staging/te-tengo.apk` | `Produccion · APK`: R2 `te-tengo-descargas/te-tengo.apk`, the landing's download | `ENABLE_APK` |
| **Google Play**, internal testing track | `te-tengo.aab`, only when the switch is on | — | `Produccion · Google Play (internal)`: uploads **the same AAB** | `ENABLE_PLAY_STORE` |
| **TestFlight** (iOS) | `te-tengo.ipa` on `macos-26`, only when the switch is on | — | `Produccion · TestFlight`: uploads **the same IPA** | `ENABLE_IOS` |
| *(every channel)* | — | the whole stage | — | `ENABLE_STAGING` |

Smoke checks after each deploy:
- **PWA:** `GET <url>/` answers `200` and `<url>/version.json` has this build's version and build number, retried for 2 minutes.
- **APK:** `HEAD <DESCARGAS_BASE_URL>/<key>` answers `200` with the APK's size, and the public `.sha256` equals the uploaded one.
- **Google Play** and **TestFlight:** the upload itself; TestFlight waits until App Store Connect has processed the build.

## The release candidate
- **What it is.** The GitHub **pre-release** `vx.y.z-rc.N`, created by the `Release candidate` job on the release commit (the tag `vx.y.z-rc.N` points to it). Its assets are every file built by that run, plus `SHA256SUMS`. Run artifacts expire (they are kept 7 days here, only to hand the files to that job); pre-releases do not.
- **Its notes** give the branch, the commit SHA, the git tree (`git rev-parse HEAD^{tree}`), the build number, the channels that were on, the APK signing certificate, the SHA-256 and size of every asset, the staging result and a link to the run. The last line is a hidden HTML comment, `<!-- te-tengo-candidata {…} -->`, with the same data as JSON, which [`candidata.sh`](../.github/scripts/candidata.sh) reads. Do not edit it.
- **N** is one more than the highest `rc` of `x.y.z` among the releases and tags. A new push to the branch builds `rc.N+1`. Older candidates are never changed or deleted.
- **Version inside.** Every file has the final version `x.y.z`: the APK and AAB `versionName`, the IPA `CFBundleShortVersionString`, the PWA `version.json`. «rc» is only the label of the pre-release, so production publishes these bytes as they are.
- **Rejected versions.** If `vx.y.z` already exists, the run fails at once: a published version never changes (SemVer rule 3), so a fix is a new version (`hotfix/x.y.(z+1)`).

### Build number
The build number `B` is Android's `versionCode`, iOS's `CFBundleVersion` and `build_number` in the PWA's `version.json`. It must **grow with every candidate**: Google Play and App Store Connect reject a build number they have already seen, and Android refuses to install an APK over a higher one.

**The pipeline computes it; nobody types it.** `Version and configuration` sets
`B = max(highest B recorded by any candidate of any version + 1, the +N of pubspec.yaml)`
and every build gets it through `--build-number` (`flutter build apk|appbundle|ipa|web`).

- **Why not bump `+N` by hand for each candidate?** Every push to the release branch (a QA fix, a merged `bugfix/*`) is a new candidate. A manual bump would need a second commit each time, and a forgotten bump would fail the run. The computed number cannot repeat and costs no commit.
- **Why not the run number?** `github.run_number` restarts if the workflow is renamed or recreated, and it is not visible to the stores. The highest recorded `B` lives in the pre-releases themselves, which are durable and public.
- **The `+N` in `pubspec.yaml` is a floor.** Leave it as it is. Raise it only to jump above a build uploaded by hand, e.g. the first AAB uploaded to Play Console. Local builds (`flutter run`, `flutter build`) keep using it.
- **Two release branches at the same time.** The `Release candidate` job checks again, just before creating the pre-release, that neither `rc.N` nor `B` was taken meanwhile. If either was, it fails and asks to re-run all jobs, which numbers the candidate again. Keep one release branch open per repository.

## Job graphs
### Push to `release/x.y.z` or `hotfix/x.y.z` (`release.yml`)
```mermaid
flowchart LR
  P["Version and configuration<br/>number rc.N and B, check secrets, plan"] --> A[APK] & W[PWA] & AAB["AAB<br/>(ENABLE_PLAY_STORE)"] & I["IPA<br/>(ENABLE_IOS)"]
  A & W & AAB & I --> C["Release candidate<br/>pre-release vx.y.z-rc.N"]
  C --> SP["Staging · PWA<br/>(ENABLE_STAGING + ENABLE_PWA)"] & SA["Staging · APK<br/>(ENABLE_STAGING + ENABLE_APK)"]
  SP & SA --> PR["Pull request to main<br/>staging = passed/skipped"]
```
- **The configuration is checked first.** `Version and configuration` fails, before any build, when a channel that is on lacks a secret or variable; the error names each one. It also fails when the branch name is not `release/<pubspec version>` or `hotfix/<pubspec version>`.
- **The plan.** It writes the plan to the run summary: each stage × channel, and either what will happen or the switch that skips it.
- **One approval for staging.** Both staging jobs need only the candidate, so they wait together and one review (*Review deployments*) approves both. They download the candidate's assets and check their SHA-256 before deploying.
- **The staging result is recorded.** `Pull request to main` writes `passed` (a staging job deployed) or `skipped` (staging switched off) into the candidate's notes. A failed or rejected staging job stops the run, and the candidate stays `pending`, which produccion refuses.
- **Pull request to `main`.** `release: x.y.z` (`release/x.y.z` → `main`) is opened with the candidate, the staging URLs and the SHA-256 of every file. A later candidate updates its description and comments on it. Merging it is a human action: the rulesets require a review and the `Format and analyze` and `Tests and coverage` checks. A pull request opened with `GITHUB_TOKEN` starts no `pull_request` workflows, so those checks come from the `CI` run of the push to the same commit: `ci.yml` also runs on pushes to `release/**`, `hotfix/**` and `main` for this reason.
- **Re-running.** Runs of one branch take turns (concurrency group per branch): a deploy is never cancelled, and a run that is still queued is replaced by a newer one. To let a newer run start while an older one waits for approval, reject the older one.
- **Pull requests.** A pull request that changes `android/`, `pubspec.*`, `release.yml` or `build-apk.yml` runs only the APK build (and the AAB when `ENABLE_PLAY_STORE` is on) as a check, with no candidate. `CI` builds the PWA on every pull request.

### Push to `main` (`produccion.yml`)
```mermaid
flowchart LR
  L["Find the tested candidate<br/>tree of main = tree of the rc,<br/>staging passed, channels ready"] --> PW["Produccion · PWA<br/>(ENABLE_PWA)"] & PA["Produccion · APK<br/>(ENABLE_APK)"] & PP["Produccion · Google Play<br/>(ENABLE_PLAY_STORE)"] & PT["Produccion · TestFlight<br/>(ENABLE_IOS)"]
  PW & PA & PP & PT --> T["Tag and back-merge<br/>GitHub Release vx.y.z + PR main → develop"]
```
- **Which candidate.** `Find the tested candidate` reads `x.y.z` from `pubspec.yaml` and takes the newest pre-release `vx.y.z-rc.N` whose recorded tree equals `git rev-parse HEAD^{tree}` of the `main` commit. A merge commit of a release branch that already contains `main` has exactly the tree of the branch's last commit, so it matches.
- **When nothing matches, the run fails** with «main differs from the tested candidate». This happens when `main` changed while the release was in QA (e.g. a hotfix), or when a commit reached `main` without a release. Bring the change into the release branch, push it to build a new rc, pass staging and merge again.
- **The matching candidate must have passed staging** (`passed`, or `skipped` because `ENABLE_STAGING` was off).
- **Every channel that is on must have been on when the candidate was built.** Otherwise its configuration was never checked and it never went through staging. The run fails before the approval and asks for a new candidate, or for the switch to be set to `false`.
- **Its secrets are checked too.** Each channel that is on must have its secrets.
- **One approval for produccion.** The four jobs need only that job, so they wait together. Each downloads its asset from the candidate, checks it against `SHA256SUMS` and publishes it: the PWA files to Pages, the APK to R2, the AAB to Google Play, the IPA to TestFlight. Nothing is compiled.
- **Tag at the end.** `Tag and back-merge` runs only when no produccion job failed or was rejected (a job skipped by its switch does not block). It:
  - creates the GitHub Release `vx.y.z` (and its tag) on the `main` commit, with the candidate's assets and notes made of the `## [x.y.z]` section of `CHANGELOG.md`, the candidate and the checksums;
  - opens `chore: merge release x.y.z back into develop` (`main` → `develop`).

  With every channel switched off it still tags, since the version reached `main`.
- **Partial failure.** If a channel fails (say the APK upload), there is no tag. *Re-run failed jobs* publishes the **same** candidate again and then tags.
- **Already released.** When `vx.y.z` exists and points to the same tree, nothing runs. When it exists with another tree, the run fails: the version on `main` must be new.
- **One at a time.** Produccion and rollback share one concurrency group.

### Rollback (`rollback.yml`, manual)
*Actions → Rollback → Run workflow* from `main`, with the version `x.y.z` of an existing final release:
- `Check the release` checks that `vx.y.z` is a final release (not a candidate) with the needed assets.
- After an approval on `produccion`:
  - `Rollback · PWA` (input `pwa`, on by default, and `ENABLE_PWA`) republishes its `te-tengo-pwa.tar.gz`;
  - `Rollback · APK` (input `apk`, off by default, and `ENABLE_APK`) republishes its `te-tengo.apk`.
  
  Both check the SHA-256 first and run the same smoke checks.
- **No build.**
- **APK.** Android does not install an older `versionCode` over a newer one. Phones that already have the newer APK keep it, so the APK rollback only helps new installs.
- **Stores.** Google Play and TestFlight are not republished: stores take each build number once and only higher ones. Halt the release in Play Console, or expire the build in TestFlight; testers can still install an earlier TestFlight build.
- **Real fix.** Usually a `hotfix/x.y.(z+1)`.
- **Database.** The app has no database of its own. If the bad release came with an API migration, restore the API database from the backup taken before that deploy (`te-tengo-infra`) together with the rollback.

## Identity: how «the same bytes» is checked
- **Build.** `Release candidate` checks that the APK it stores has the SHA-256 that `apksigner` verified in the APK job, and writes `SHA256SUMS`.
- **Every deploy.** Each staging, produccion and rollback job downloads the asset from the release and runs `sha256sum --check` against that release's `SHA256SUMS` before publishing it.
- **The PWA.** It is stored as one archive, so its SHA-256 covers the whole site. The deploy's smoke check also compares the served `version.json` with the archive's.
- **Code.** Produccion requires the tree of the `main` commit to equal the recorded tree of the candidate, so the code on `main` is the code that was built and tested.
- **The final release** carries the same assets and the same `SHA256SUMS` as its candidate. Its notes link to the candidate.

## Switches
The switches are **organization variables**: *Te-Tengo-Tech → Settings → Secrets and variables → Actions → Variables*. A channel is **on only when its variable is exactly `true`**. `false`, any other value, or no variable at all means off.

| Variable | Read by | When it is not `true` |
|---|---|---|
| `ENABLE_STAGING` | `release.yml` | Both staging jobs are skipped; the candidate is marked `skipped` and the pull request is opened right after it (an urgent hotfix). Produccion still needs its approval |
| `ENABLE_PWA` | `release.yml`, `produccion.yml`, `rollback.yml` | No PWA deploy (the PWA is still built and stored in the candidate) |
| `ENABLE_APK` | `release.yml`, `produccion.yml`, `rollback.yml` | No R2 upload (the APK is still built and stored in the candidate when it is signed with the release key) |
| `ENABLE_PLAY_STORE` | `release.yml`, `produccion.yml` | The AAB is not built and the Play upload is skipped |
| `ENABLE_IOS` | `release.yml`, `produccion.yml` | The IPA is not built (no macOS runner starts) and the TestFlight upload is skipped |

Other organization variables (`ENABLE_API_*`, `ENABLE_LANDING_*`, `ENABLE_DESKTOP_*`, `ENABLE_WINDOWS_*`, `ENABLE_MAC_*`) switch the other repositories.

**When a switch is on and its configuration is missing, the run fails** in its first job, before any build or approval, with an error that names each missing secret or variable. A release is never silently left out. Turn a channel on only after its one-time setup is done, and **before** pushing the release branch: a channel turned on after the candidate was built makes produccion fail (see above).

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

The workflows use `GITHUB_TOKEN` for everything on GitHub: the pre-releases, tags and final releases (`contents: write`, only in the jobs that create them) and the pull requests. The repository allows GitHub Actions to create pull requests (*Settings → Actions → General → Workflow permissions*), and no tag ruleset may block `GITHUB_TOKEN` from creating `v*` tags.

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
4. Push the next `release/x.y.z` (its candidate then includes `te-tengo.aab`), merge its pull request into `main` and approve `Produccion · Google Play (internal)`. While the app is still a draft in Play Console, set the repository variable `PLAY_RELEASE_STATUS` to `draft`, and delete it once the app has been reviewed. If the first AAB uploaded by hand had a build number at or above the next computed one, raise the `+N` of `pubspec.yaml` above it ([Build number](#build-number)).

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
10. **Switch it on.** Set the organization variable `ENABLE_IOS` to `true`. Push the next `release/x.y.z` (its candidate then includes `te-tengo.ipa`), merge its pull request into `main` and approve `Produccion · TestFlight`.

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

  It keeps `te-tengo-<version>-<build>.ipa` as a run artifact for 7 days, and the `Release candidate` job stores it in the candidate as `te-tengo.ipa`.
- **Upload.** On `main`, `Produccion · TestFlight` ([`produccion.yml`](../.github/workflows/produccion.yml)) downloads the candidate's `te-tengo.ipa`, checks its SHA-256 and sends that same IPA with [`apple-actions/upload-testflight-build`](https://github.com/Apple-Actions/upload-testflight-build), pinned by commit SHA. Its default backend is the App Store Connect API, which runs on Linux. The job waits until App Store Connect has processed the build, so an invalid binary fails the run.
  - Flutter's guide also shows `xcrun altool --upload-app`, which still works. The App Store Connect API path needs no Transporter or Xcode on the runner.
- **Version.** The build number grows with every candidate on its own ([Build number](#build-number)); the version must be higher than the last one approved for the App Store.
