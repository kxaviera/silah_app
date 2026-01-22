# App Icon Setup Guide

## ✅ Completed

1. **Splash Screen Updated**
   - Background color changed to `#28BC79` (green)
   - Logo added: `assets/logos/logo.png`
   - Location: `lib/ui/screens/splash_screen.dart`

2. **Login Screen Updated**
   - Logo added: `assets/logos/logo_green.png`
   - Location: `lib/ui/screens/login_screen.dart`

3. **Signup Screen Updated**
   - Logo added: `assets/logos/logo_green.png`
   - Location: `lib/ui/screens/signup_screen.dart`

4. **App Icon Configuration**
   - `flutter_launcher_icons` package installed
   - Configuration added to `pubspec.yaml`
   - Source icon: `assets/icons/app_icon.png`

## 📱 Generate App Icons

To generate app icons for Android and iOS, run:

```bash
flutter pub run flutter_launcher_icons
```

This will:
- Generate all required icon sizes for Android (mipmap folders)
- Generate all required icon sizes for iOS (Assets.xcassets)
- Replace the default Flutter icons with your custom icon

## 📋 Requirements

### App Icon File
- **Location**: `assets/icons/app_icon.png`
- **Recommended Size**: 1024x1024px (square)
- **Format**: PNG with transparency support
- **Background**: Should have a background color (not transparent) for best results

### Logo Files
- **Splash Screen**: `assets/logos/logo.png` (used on green background)
- **Login/Signup**: `assets/logos/logo_green.png` (used on white background)

## 🎨 Color Reference

- **Splash Background**: `#28BC79` (green)
- **Primary Theme Color**: `#2E7D32` (Material green)

## 📝 Notes

- After running `flutter pub run flutter_launcher_icons`, rebuild the app to see the new icons
- For Android, icons are generated in `android/app/src/main/res/mipmap-*/`
- For iOS, icons are generated in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- The icon will appear on the device home screen and app stores

## 🔄 Next Steps

1. Ensure `assets/icons/app_icon.png` exists (1024x1024px recommended)
2. Run `flutter pub run flutter_launcher_icons`
3. Rebuild the app: `flutter run` or `flutter build apk`
