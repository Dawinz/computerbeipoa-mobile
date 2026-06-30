# Computer Beipoa Mobile

Flutter storefront for [Computer Beipoa](https://computerbeipoa.co.tz) — connects to the production NestJS API.

| | |
|---|---|
| **Bundle ID (iOS)** | `com.qwantumtech.computerbeipoa` |
| **Package (Android)** | `com.qwantumtech.computerbeipoa` |
| **Codemagic repo** | This repository (`Dawinz/computerbeipoa-mobile`) |

## Features

- Product catalog, search, and filters
- Product detail with image gallery
- Shopping cart (local persistence)
- Checkout with demo mobile money (M-Pesa, Tigo Pesa, Airtel Money)
- Account / support links

## API configuration

Production defaults are built in. Override for local dev:

```bash
flutter run \
  --dart-define=API_URL=http://10.0.2.2:4000/api/v1 \
  --dart-define=WEB_URL=http://10.0.2.2:3000
```

## Run locally

```bash
flutter pub get
flutter run
```

## iOS App Store (Codemagic)

1. Connect this repo in [Codemagic](https://codemagic.io) with **Use configuration from repository**
2. Add Apple integration labeled **`applestoreconnectkey`**
3. Register bundle ID **`com.qwantumtech.computerbeipoa`** in Apple Developer / App Store Connect
4. Run workflow **iOS App Store**

See `CODEMAGIC_SETUP.txt` and `CODEMAGIC_MOBILE_STORE_GUIDE.md`.

## Monorepo

The main platform (API, web, admin) lives in [Dawinz/computer-beipoa](https://github.com/Dawinz/computer-beipoa). Copy app changes back to `apps/mobile` there when you develop in the monorepo.
