# Rebuild APK for Production Testing

## Quick Steps

1. **Clean previous build:**
   ```bash
   flutter clean
   ```

2. **Build APK with production environment:**
   ```bash
   flutter build apk --release
   ```
   
   **Note:** The app is now configured to use production API by default (`https://api.rewardo.fun/api`)

3. **Find your APK:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. **Install on your phone:**
   - Transfer `app-release.apk` to your phone
   - Install it (enable "Install from unknown sources" if needed)

---

## What Changed

✅ **Default environment** set to `production` in `app_config.dart`
✅ **Better error messages** - Now shows specific connection errors
✅ **Debug info** - Shows API URL in error messages (in debug mode)

---

## Testing

After installing the new APK:

1. Try to signup
2. If it fails, check the error message - it will show:
   - The specific error (connection timeout, server error, etc.)
   - The API URL being used (in debug builds)

---

## Expected Behavior

- **API URL:** `https://api.rewardo.fun/api`
- **Should connect** to your production backend
- **Error messages** will be more descriptive

---

## If Still Failing

Share the exact error message shown in the app. The new error messages will help identify:
- Connection issues
- Server errors
- Network problems
