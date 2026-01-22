# Firebase Setup Guide for Silah App

## Overview
This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in the Silah app.

## Prerequisites
- Firebase account
- Flutter project initialized
- Android Studio / Xcode installed

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Silah"
4. Enable Google Analytics (optional)
5. Create project

## Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.silah.app` (or your package name)
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Update `android/build.gradle`:
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## Step 3: Add iOS App

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.silah.app` (or your bundle ID)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory
5. Open `ios/Runner.xcworkspace` in Xcode
6. Enable Push Notifications capability
7. Add Background Modes → Remote notifications

## Step 4: Generate Firebase Options

Run in terminal:
```bash
flutter pub add firebase_core
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart` with your Firebase config
- Configure both Android and iOS

## Step 5: Update Firebase Options

The generated `lib/firebase_options.dart` will have your actual Firebase credentials.

## Step 6: Test Push Notifications

1. Run the app
2. Grant notification permissions
3. Check Firebase Console → Cloud Messaging
4. Send a test notification

## Troubleshooting

### Android Issues
- Make sure `google-services.json` is in `android/app/`
- Check `minSdkVersion` is at least 21
- Verify Google Services plugin is applied

### iOS Issues
- Make sure `GoogleService-Info.plist` is in `ios/Runner/`
- Enable Push Notifications in Xcode
- Check APNs certificates are configured
- For simulator: Push notifications don't work on iOS simulator

## Environment Variables

Update `lib/core/api_client.dart`:
```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

## Production Checklist

- [ ] Firebase project created
- [ ] Android app added and configured
- [ ] iOS app added and configured
- [ ] `google-services.json` added
- [ ] `GoogleService-Info.plist` added
- [ ] `firebase_options.dart` generated
- [ ] Push notifications tested
- [ ] API base URL updated
- [ ] Backend FCM server key configured

---

**Note:** The `lib/firebase_options.dart` file is a placeholder. You must run `flutterfire configure` to generate the actual file with your Firebase project credentials.
