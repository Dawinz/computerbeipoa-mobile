# Codemagic: Apple / App Store release guide (Flutter)

Bundle ID: **`com.qwantumtech.computerbeipoa`**  
Repo: **`Dawinz/computerbeipoa-mobile`**

---

## 1. Apple Developer Portal integration (certificates + upload)

In **Codemagic → Team settings → Integrations → Developer Portal**, register your App Store Connect API key.

| Item | Value |
|------|--------|
| Integration label | **`applestoreconnectkey`** (case-sensitive) |
| Key source | [App Store Connect → Users and Access → Integrations → API](https://appstoreconnect.apple.com/access/integrations/api) |
| Key role | **App Manager** or Admin |
| `.p8` file | Download once when creating the key |

In **`codemagic.yaml`**:

```yaml
integrations:
  app_store_connect: applestoreconnectkey
```

A mismatch between the label in Codemagic and YAML produces **no upload** and **no signing**.

---

## 2. Certificates and provisioning profiles (automatic)

`codemagic.yaml` creates and fetches signing assets on every build:

```yaml
environment:
  ios_signing:
    distribution_type: app_store
    bundle_identifier: com.qwantumtech.computerbeipoa

scripts:
  - keychain initialize
  - app-store-connect fetch-signing-files $BUNDLE_ID --type IOS_APP_STORE --create
  - keychain add-certificates
  - xcode-project use-profiles
  - flutter build ipa --export-options-plist=/Users/builder/export_options.plist
```

- **`--create`** — Codemagic creates the **distribution certificate** and **App Store provisioning profile** via the API if they do not exist yet.
- **`ios_signing`** — tells Codemagic which bundle ID and distribution type to match.
- **`xcode-project use-profiles`** — applies profiles to the Xcode project and writes `export_options.plist`.
- **`distribution_type: app_store`** — required for App Store / production IPAs (not ad_hoc or development).

**Apple side (one-time):** register App ID **`com.qwantumtech.computerbeipoa`** in [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) before the first build.

**Manual upload (optional):** Codemagic → **codemagic.yaml settings → Code signing identities** → upload iOS certificates / provisioning profiles. The YAML above auto-fetches via API, so manual upload is usually not needed.

---

## 3. Direct App Store (no TestFlight)

```yaml
submit_to_testflight: false
submit_to_app_store: true
release_type: AFTER_APPROVAL
```

Each green build is submitted for **App Store review**. When Apple approves, it releases automatically.

**One-time:** App Store Connect app record with screenshots, privacy policy URL, and category.

---

## 4. Checklist

- [ ] Developer Portal integration **`applestoreconnectkey`** in Codemagic
- [ ] App ID **`com.qwantumtech.computerbeipoa`** in Apple Developer
- [ ] App record in App Store Connect with listing metadata
- [ ] Codemagic app uses **Use configuration from repository**
- [ ] Workflow **iOS App Store** (not default Flutter UI workflow)
- [ ] Build log shows **Fetch distribution certificate**, **use-profiles**, signed **IPA**, and **submit_to_app_store**

---

## 5. Troubleshooting

| Symptom | Fix |
|---------|-----|
| Code signing failed | Confirm integration label `applestoreconnectkey` and App ID exists in Apple Developer |
| No certificate | Ensure API key has App Manager role; check **fetch-signing-files** step in log |
| No upload to Apple | YAML must include `publishing.app_store_connect` with `auth: integration` |
| Wrong bundle ID | Must be **`com.qwantumtech.computerbeipoa`** everywhere — never `com.beipoa.*` |

---

## 6. Reference

| Item | Value |
|------|--------|
| Codemagic integration | `applestoreconnectkey` |
| Bundle ID | `com.qwantumtech.computerbeipoa` |
| Distribution type | `app_store` |
