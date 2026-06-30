# Codemagic: Apple / App Store release guide (Flutter)

Bundle ID for this app: **`com.qwantumtech.computerbeipoa`**

Use this checklist for **TestFlight / App Store** via **Codemagic** on repo **`Dawinz/computerbeipoa-mobile`**.

---

## 1. Apple key in Codemagic

Integration label (case-sensitive): **`applestoreconnectkey`**

```yaml
integrations:
  app_store_connect: applestoreconnectkey
```

Create the key in [App Store Connect → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api) with **App Manager** or Admin.

---

## 2. Green build ≠ App Store upload

You need **`publishing.app_store_connect`** in `codemagic.yaml` — not only `artifacts:`.

This repo copies IPAs to **`codemagic_publish/`** because **`build/`** is gitignored and Codemagic may skip it when publishing.

---

## 3. Checklist

- Bundle ID **`com.qwantumtech.computerbeipoa`** matches App Store Connect exactly
- `pubspec.yaml` build number (`+N`) increases each upload
- `ITSAppUsesNonExemptEncryption` = false in Info.plist (HTTPS only)
- Privacy policy URL on the website
- Codemagic: **Use configuration from repository** → workflow **iOS App Store**

---

## 4. After a build

1. Codemagic log shows App Store Connect **upload**, not artifacts-only
2. TestFlight → build **Processing** → **Ready** (15–60+ min)
3. Distribution → select build → Submit for Review

See `CODEMAGIC_SETUP.txt` for setup steps.
