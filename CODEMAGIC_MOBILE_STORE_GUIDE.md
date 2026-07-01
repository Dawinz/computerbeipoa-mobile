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

Codemagic fetches or creates signing files via the **Developer Portal integration** — do **not** mix this with manual `fetch-signing-files --create` in YAML (that causes *"Cannot save Signing Certificates without certificate private key"*).

```yaml
integrations:
  app_store_connect: applestoreconnectkey

environment:
  ios_signing:
    distribution_type: app_store
    bundle_identifier: com.qwantumtech.computerbeipoa

scripts:
  - xcode-project use-profiles
  - flutter build ipa --export-options-plist=/Users/builder/export_options.plist
```

- **`Set up code signing identities`** (automatic Codemagic step) uses the integration to fetch/create certs and profiles.
- **`ios_signing`** must match bundle ID **`com.qwantumtech.computerbeipoa`** and `distribution_type: app_store`.
- **`xcode-project use-profiles`** applies them and writes `export_options.plist`.

**Apple side (one-time):** register App ID **`com.qwantumtech.computerbeipoa`** in [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list).

**If signing still fails:** Codemagic → **Team settings → Code signing identities** → **iOS certificates** → **Fetch certificate** (uses the same API key). Or add env var **`CERTIFICATE_PRIVATE_KEY`** (RSA private key PEM) in a group named `code-signing` only if you use manual `fetch-signing-files --create --certificate-key`.

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
| Cannot save Signing Certificates without certificate private key | Remove manual `fetch-signing-files --create` from YAML; use `ios_signing` + `xcode-project use-profiles` only |
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
