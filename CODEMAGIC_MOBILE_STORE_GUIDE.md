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

## 2. Direct App Store (no TestFlight)

`codemagic.yaml` sets:

```yaml
submit_to_testflight: false
submit_to_app_store: true
release_type: AFTER_APPROVAL
```

Each green build is submitted for **App Store review**. When Apple approves, it releases automatically — no TestFlight beta step.

**One-time:** App Store Connect must have the app record, screenshots, privacy policy URL, and category filled in before the first automated submission succeeds.

---

## 3. Checklist

- Bundle ID **`com.qwantumtech.computerbeipoa`** matches App Store Connect exactly
- `pubspec.yaml` build number (`+N`) increases each upload
- `ITSAppUsesNonExemptEncryption` = false in Info.plist (HTTPS only)
- Privacy policy URL on the website
- Codemagic: **Use configuration from repository** → workflow **iOS App Store**

---

## 4. After a build

1. Codemagic log shows App Store Connect **upload** and post-processing **submit_to_app_store**
2. App Store Connect → app → status **Waiting for Review** → **In Review** → **Ready for Sale** (after approval)
3. No TestFlight beta step — builds go straight to App Store review

See `CODEMAGIC_SETUP.txt` for setup steps.
