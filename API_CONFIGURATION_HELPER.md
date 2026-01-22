# API Configuration Helper

## Step 1: Update API URLs

### Instructions:

1. **Open:** `lib/core/app_config.dart`

2. **Update Production URL:**
   ```dart
   case 'production':
     return 'https://YOUR_PRODUCTION_URL/api'; // Replace YOUR_PRODUCTION_URL
   ```

3. **Update Staging URL (if applicable):**
   ```dart
   case 'staging':
     return 'https://YOUR_STAGING_URL/api'; // Replace YOUR_STAGING_URL
   ```

### Example:
If your production backend is at `https://api.silahmatrimony.com`, update to:
```dart
case 'production':
  return 'https://api.silahmatrimony.com/api';
```

### Important Notes:

- **URL Format:** Must include protocol (`https://`) and end with `/api`
- **Socket.io:** Will automatically use the same domain (without `/api`)
- **SSL:** Production must use `https://` (not `http://`)
- **CORS:** Ensure backend allows requests from your app domain

### After Updating:

1. Save the file
2. Run: `flutter clean`
3. Test connectivity (Step 2)

---

## Quick Test Commands

### Test Development (localhost):
```bash
flutter run
```

### Test Staging:
```bash
flutter run --dart-define=ENV=staging
```

### Test Production:
```bash
flutter run --dart-define=ENV=production
```

---

**Next:** After updating URLs, proceed to Step 2: Test API Connectivity
