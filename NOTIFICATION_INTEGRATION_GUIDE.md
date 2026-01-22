# Notification System - Integration Guide

## ✅ What's Been Implemented

### 1. **API Client** (`lib/core/api_client.dart`)
- ✅ Dio HTTP client setup
- ✅ JWT token management
- ✅ Automatic token injection in headers
- ✅ Error handling
- ✅ Token storage with SharedPreferences

### 2. **Notification API** (`lib/core/notification_api.dart`)
- ✅ Register FCM token
- ✅ Get notifications (with pagination)
- ✅ Get unread counts
- ✅ Mark as read
- ✅ Mark all as read
- ✅ Delete notification
- ✅ Update preferences
- ✅ Get preferences

### 3. **Notification Service** (`lib/core/notification_service.dart`)
- ✅ Firebase Messaging setup
- ✅ Local notifications setup
- ✅ FCM token registration
- ✅ Foreground message handling
- ✅ Background message handling
- ✅ Notification tap handling
- ✅ Unread counts fetching

### 4. **Notification Screen** (`lib/ui/screens/notifications_screen.dart`)
- ✅ Connected to backend API
- ✅ Real-time data fetching
- ✅ Pagination support
- ✅ Pull to refresh
- ✅ Mark as read on tap
- ✅ Delete notification (swipe)
- ✅ Mark all as read
- ✅ Filter by type
- ✅ Loading states
- ✅ Error handling

### 5. **App Shell** (`lib/ui/shell/app_shell.dart`)
- ✅ Real-time badge counts from backend
- ✅ Auto-refresh every 30 seconds
- ✅ Notification badge widget integration

### 6. **Settings Screen** (`lib/ui/screens/settings_screen.dart`)
- ✅ Connected to notification preferences API
- ✅ Load preferences on init
- ✅ Update preferences on change
- ✅ All notification type toggles working

## 🔧 Setup Required

### 1. Firebase Configuration

**Run these commands:**
```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
- Generate `lib/firebase_options.dart` with your Firebase credentials
- Configure Android (`google-services.json`)
- Configure iOS (`GoogleService-Info.plist`)

### 2. Update API Base URL

**Edit `lib/core/api_client.dart`:**
```dart
static const String baseUrl = 'https://your-backend-domain.com/api';
```

### 3. Backend Requirements

Your backend must implement these endpoints:

#### POST `/api/notifications/register-token`
```json
{
  "fcmToken": "string",
  "deviceType": "android" | "ios"
}
```

#### GET `/api/notifications`
Query params: `page`, `limit`, `unreadOnly`
Response:
```json
{
  "success": true,
  "notifications": [...],
  "unreadCount": 5,
  "pagination": {...}
}
```

#### GET `/api/notifications/unread-count`
Response:
```json
{
  "success": true,
  "counts": {
    "total": 5,
    "messages": 2,
    "requests": 2,
    "matches": 1
  }
}
```

#### PUT `/api/notifications/:id/read`
#### PUT `/api/notifications/read-all`
#### DELETE `/api/notifications/:id`
#### PUT `/api/notifications/preferences`
#### GET `/api/notifications/preferences`

## 📱 How It Works

### 1. App Startup
```
main() → Firebase.initializeApp() → NotificationService.initialize()
→ Request permissions → Get FCM token → Register with backend
```

### 2. Notification Flow
```
Backend Event → Create Notification → Send FCM → 
Frontend receives → Show notification → Update badges
```

### 3. Real-time Updates
```
App Shell → Fetch counts every 30s → Update badges
Notification Screen → Pull to refresh → Fetch latest
```

### 4. User Actions
```
Tap notification → Mark as read → Navigate to screen
Swipe notification → Delete → Remove from list
Toggle setting → Update preference → Save to backend
```

## 🧪 Testing

### Test Notification API
1. Start backend server
2. Login to app
3. Open Notification Screen
4. Should see notifications from backend

### Test Push Notifications
1. Complete Firebase setup
2. Run app on device (not emulator for iOS)
3. Grant notification permission
4. Send test notification from Firebase Console
5. Should receive notification

### Test Badge Counts
1. Open app
2. Check navigation bar badges
3. Should update every 30 seconds
4. Badges should reflect unread counts

## 🐛 Troubleshooting

### Issue: "Firebase not initialized"
**Solution:** Run `flutterfire configure`

### Issue: "No notifications showing"
**Check:**
- Backend is running
- API base URL is correct
- User is authenticated (token exists)
- Backend returns notifications

### Issue: "Badges not updating"
**Check:**
- Notification API endpoint is working
- Unread counts endpoint returns data
- App Shell is fetching counts

### Issue: "Push notifications not working"
**Check:**
- Firebase is configured
- FCM token is registered
- Backend is sending notifications
- Device has internet connection
- Permissions are granted

## 📝 Next Steps

1. **Complete Firebase Setup**
   - Run `flutterfire configure`
   - Test push notifications

2. **Backend Implementation**
   - Implement all notification endpoints
   - Set up FCM server key
   - Send notifications on events

3. **Socket.io Integration** (Optional)
   - Real-time badge updates
   - Instant notification delivery
   - Online/offline status

4. **Testing**
   - Test all notification types
   - Test on Android and iOS
   - Test foreground and background

---

**Status:** ✅ Frontend fully connected to backend API  
**Pending:** Firebase configuration and backend implementation
