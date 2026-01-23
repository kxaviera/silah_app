# Fix: App Using localhost Instead of Production API

## Problem
The app is built with `development` environment, so it's trying to connect to `http://localhost:5000/api` instead of `https://api.rewardo.fun/api`.

## Solution: Rebuild with Production Environment

### For Android APK:
```bash
flutter clean
flutter build apk --release --dart-define=ENV=production
```

### For Android App Bundle (for Play Store):
```bash
flutter clean
flutter build appbundle --release --dart-define=ENV=production
```

### For iOS:
```bash
flutter clean
flutter build ios --release --dart-define=ENV=production
```

### For Testing (without building):
```bash
flutter run --release --dart-define=ENV=production
```

---

## Verify Configuration

After building, the app will use:
- **API URL:** `https://api.rewardo.fun/api`
- **Socket URL:** `https://api.rewardo.fun`

---

## Quick Test

After rebuilding, test signup again. It should now connect to the production API.

---

## Alternative: Force Production Mode

If you want to always use production (not recommended for development), you can temporarily change `app_config.dart`:

```dart
static const String environment = 'production'; // Force production
```

But it's better to use `--dart-define=ENV=production` when building.
