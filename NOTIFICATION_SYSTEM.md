# Notification System - Complete Specification

## Overview
Comprehensive notification system for Silah matrimony app including push notifications, in-app notifications, and notification badges.

## Notification Types

### 1. **New Contact Request**
- **Trigger:** User receives a contact request
- **Push Notification:** "You have a new contact request from [Name]"
- **In-App:** Badge on Requests tab, "NEW" badge on request card
- **Action:** Navigate to Requests screen

### 2. **Request Accepted/Rejected**
- **Trigger:** User's sent request is accepted/rejected
- **Push Notification:** "[Name] accepted your contact request" / "[Name] rejected your contact request"
- **In-App:** Update request status in Requests screen
- **Action:** Navigate to Requests screen (Sent tab)

### 3. **New Message**
- **Trigger:** User receives a new message
- **Push Notification:** "[Name]: [Message preview]"
- **In-App:** Badge on Messages tab, unread indicator on conversation
- **Action:** Navigate to Chat screen

### 4. **New Profile Match**
- **Trigger:** New profile matches user's preferences
- **Push Notification:** "New matches found! Check them out"
- **In-App:** Badge on Search tab (optional)
- **Action:** Navigate to Discover screen

### 5. **Profile View**
- **Trigger:** Someone viewed user's profile
- **Push Notification:** "[Name] viewed your profile"
- **In-App:** Update in Boost Profile analytics
- **Action:** Navigate to Boost Profile screen

### 6. **Profile Liked/Shortlisted**
- **Trigger:** Someone liked/shortlisted user's profile
- **Push Notification:** "[Name] liked your profile" / "[Name] shortlisted your profile"
- **In-App:** Update in Boost Profile analytics
- **Action:** Navigate to Boost Profile screen

### 7. **Boost Expiring**
- **Trigger:** Boost expires in 24 hours
- **Push Notification:** "Your boost expires tomorrow. Repost to stay visible!"
- **In-App:** Warning in Boost Profile screen
- **Action:** Navigate to Boost Profile screen

### 8. **Boost Expired**
- **Trigger:** Boost has expired
- **Push Notification:** "Your boost has expired. Repost now to get more visibility!"
- **In-App:** "Repost" button in Profile screen
- **Action:** Navigate to Boost Profile screen

### 9. **Payment Success**
- **Trigger:** Payment completed successfully
- **Push Notification:** "Payment successful! Your profile is now live"
- **In-App:** Navigate to Invoice screen
- **Action:** Show invoice

### 10. **Payment Failed**
- **Trigger:** Payment processing failed
- **Push Notification:** "Payment failed. Please try again"
- **In-App:** Error message in Payment screen
- **Action:** Navigate to Payment screen

---

## Push Notification Implementation

### Technology Stack
- **Firebase Cloud Messaging (FCM)** for Android
- **Apple Push Notification Service (APNs)** for iOS
- **Firebase Cloud Messaging** for cross-platform

### Dependencies
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.3.0
```

### Setup Steps

1. **Firebase Setup**
   - Create Firebase project
   - Add Android app (get `google-services.json`)
   - Add iOS app (get `GoogleService-Info.plist`)
   - Enable Cloud Messaging API

2. **Android Configuration**
   - Add `google-services.json` to `android/app/`
   - Update `android/build.gradle`
   - Update `android/app/build.gradle`

3. **iOS Configuration**
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Enable Push Notifications capability
   - Configure APNs certificates

---

## Backend Notification Endpoints

### Notification Model
```typescript
{
  _id: ObjectId,
  userId: ObjectId,
  type: 'new_request' | 'request_accepted' | 'request_rejected' | 
        'new_message' | 'new_match' | 'profile_view' | 
        'profile_liked' | 'profile_shortlisted' | 
        'boost_expiring' | 'boost_expired' | 
        'payment_success' | 'payment_failed',
  title: string,
  body: string,
  data?: {
    requestId?: string,
    conversationId?: string,
    profileId?: string,
    transactionId?: string
  },
  isRead: boolean,
  createdAt: Date
}
```

### API Endpoints

#### POST `/api/notifications/register-token`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "fcmToken": "firebase_cloud_messaging_token",
  "deviceType": "android" | "ios"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Token registered successfully"
}
```

#### GET `/api/notifications`
**Headers:** `Authorization: Bearer <token>`
**Query Parameters:**
- `page` - page number (default: 1)
- `limit` - items per page (default: 20)
- `unreadOnly` - boolean (default: false)

**Response:**
```json
{
  "success": true,
  "notifications": [
    {
      "id": "...",
      "type": "new_request",
      "title": "New Contact Request",
      "body": "Ahmed sent you a contact request",
      "data": {
        "requestId": "..."
      },
      "isRead": false,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "unreadCount": 5,
  "pagination": { /* pagination info */ }
}
```

#### PUT `/api/notifications/:notificationId/read`
**Headers:** `Authorization: Bearer <token>`
**Marks notification as read**

#### PUT `/api/notifications/read-all`
**Headers:** `Authorization: Bearer <token>`
**Marks all notifications as read**

#### DELETE `/api/notifications/:notificationId`
**Headers:** `Authorization: Bearer <token>`
**Deletes notification**

#### GET `/api/notifications/unread-count`
**Headers:** `Authorization: Bearer <token>`
**Response:**
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

---

## Frontend Implementation

### Notification Service
```dart
// lib/core/notification_service.dart
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Initialize notifications
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      // Send token to backend
      await registerToken(token);
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }
  
  // Register token with backend
  static Future<void> registerToken(String token) async {
    // Call API: POST /api/notifications/register-token
  }
  
  // Handle foreground notification
  static void _handleForegroundMessage(RemoteMessage message) {
    // Show in-app notification
    // Update badge counts
  }
  
  // Handle background notification tap
  static void _handleBackgroundMessage(RemoteMessage message) {
    // Navigate to relevant screen
  }
}
```

### Notification Badge Widget
```dart
// lib/ui/widgets/notification_badge.dart
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  
  const NotificationBadge({
    required this.count,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    
    return Badge(
      label: Text('$count'),
      child: child,
    );
  }
}
```

### Notification Screen
- List of all notifications
- Filter by type
- Mark as read
- Delete notifications
- Navigate to relevant screen on tap

---

## In-App Notification Badges

### Implementation Locations

1. **Messages Tab Badge**
   - Show unread message count
   - Update in real-time via Socket.io
   - Clear when all messages read

2. **Requests Tab Badge**
   - Show unread request count
   - Update when new request received
   - Clear when request read

3. **Search Tab Badge (Optional)**
   - Show new matches count
   - Update when new profiles match preferences

---

## Notification Settings

### User Preferences
- Enable/Disable push notifications
- Notification types:
  - New messages
  - New requests
  - Request responses
  - New matches
  - Profile views
  - Profile likes
  - Boost reminders
  - Payment updates

### Settings Screen Updates
```dart
// Add to Settings Screen
SwitchListTile(
  title: Text('Push notifications'),
  subtitle: Text('Get alerts for messages and requests'),
  value: pushNotificationsEnabled,
  onChanged: (value) {
    // Update setting
    // Call API to update preference
  },
),
Divider(),
Text('Notification Types'),
SwitchListTile(
  title: Text('New messages'),
  value: messageNotificationsEnabled,
  onChanged: (value) => updateNotificationPreference('messages', value),
),
SwitchListTile(
  title: Text('New requests'),
  value: requestNotificationsEnabled,
  onChanged: (value) => updateNotificationPreference('requests', value),
),
// ... more notification types
```

---

## Backend Notification Triggers

### When to Send Notifications

1. **New Contact Request**
   ```typescript
   // In request controller
   async function createRequest(req, res) {
     const request = await Request.create({...});
     
     // Send notification
     await sendNotification(request.toUserId, {
       type: 'new_request',
       title: 'New Contact Request',
       body: `${request.fromUser.name} sent you a contact request`,
       data: { requestId: request._id }
     });
   }
   ```

2. **Request Accepted/Rejected**
   ```typescript
   async function acceptRequest(req, res) {
     const request = await Request.findByIdAndUpdate(...);
     
     // Send notification to requester
     await sendNotification(request.fromUserId, {
       type: 'request_accepted',
       title: 'Request Accepted',
       body: `${request.toUser.name} accepted your contact request`,
       data: { requestId: request._id }
     });
   }
   ```

3. **New Message**
   ```typescript
   // In message controller or Socket.io handler
   async function sendMessage(conversationId, senderId, receiverId, text) {
     const message = await Message.create({...});
     
     // Send notification
     await sendNotification(receiverId, {
       type: 'new_message',
       title: sender.name,
       body: text.substring(0, 50),
       data: { conversationId, messageId: message._id }
     });
   }
   ```

4. **New Match**
   ```typescript
   // Background job or when new profile created
   async function checkMatches(userId) {
     const matches = await findMatchingProfiles(userId);
     
     if (matches.length > 0) {
       await sendNotification(userId, {
         type: 'new_match',
         title: 'New Matches Found',
         body: `You have ${matches.length} new profile matches`,
         data: { matchCount: matches.length }
       });
     }
   }
   ```

5. **Boost Expiring**
   ```typescript
   // Scheduled job (cron)
   async function checkExpiringBoosts() {
     const expiringBoosts = await User.find({
       boostStatus: 'active',
       boostExpiresAt: {
         $gte: new Date(),
         $lte: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
       }
     });
     
     for (const user of expiringBoosts) {
       await sendNotification(user._id, {
         type: 'boost_expiring',
         title: 'Boost Expiring Soon',
         body: 'Your boost expires tomorrow. Repost to stay visible!',
       });
     }
   }
   ```

---

## Notification Delivery Flow

```
1. Event occurs (new message, request, etc.)
2. Backend creates Notification record
3. Backend sends push notification via FCM
4. Backend emits Socket.io event (if user online)
5. Frontend receives notification:
   - If app in foreground: Show in-app notification
   - If app in background: Show system notification
   - Update badge counts
   - Update UI if relevant screen is open
6. User taps notification → Navigate to relevant screen
```

---

## Testing Checklist

- [ ] Push notification permission request
- [ ] FCM token registration
- [ ] Foreground notification display
- [ ] Background notification display
- [ ] Notification tap navigation
- [ ] Badge count updates
- [ ] Mark as read functionality
- [ ] Delete notification
- [ ] Notification settings toggle
- [ ] All notification types working
- [ ] Real-time badge updates via Socket.io
- [ ] Notification history screen

---

**Last Updated:** 2024-01-15
