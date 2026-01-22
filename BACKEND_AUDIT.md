# Silah Matrimony App - Backend Requirements Audit

## 📋 Table of Contents
1. [Overview](#overview)
2. [User Flows](#user-flows)
3. [Data Models](#data-models)
4. [API Endpoints](#api-endpoints)
5. [Authentication](#authentication)
6. [Payment Integration](#payment-integration)
7. [Real-time Features](#real-time-features)
8. [File Uploads](#file-uploads)
9. [Search & Filtering](#search--filtering)
10. [Privacy & Security](#privacy--security)
11. [Notifications](#notifications)
12. [Admin Dashboard](#admin-dashboard)

---

## Overview

**App Type**: Matrimony classified ads platform  
**Business Model**: Pay-per-post (3 days Standard / 7 days Featured boost)  
**Target Market**: India (with support for NRIs and international users)  
**Key Features**: Profile posting, boost options, contact requests, live chat, privacy controls

---

## User Flows

### 1. Registration & Onboarding
```
Splash Screen → Sign Up → Complete Profile → Payment → Home
```

**Sign Up Screen** (`signup_screen.dart`):
- Full name
- I am (Bride/Groom) - **role**
- Date of birth
- Country (dropdown)
- City (dropdown)
- Religion (dropdown)

**Complete Profile Screen** (`complete_profile_screen.dart`):
- Profile photo upload
- Personal details:
  - Name (pre-filled from signup)
  - Age (calculated from DOB)
  - Gender (from role)
  - Height (cm)
  - Complexion
- Location:
  - Country (home country)
  - Country of residence (where they live/work - can be different)
  - State
  - City
- Religion & Community:
  - Religion
  - Caste/Community (depends on religion)
- Education & Profession:
  - Education level
  - Profession
  - Annual income
- About me (text)
- Partner preferences (text)
- Privacy settings:
  - Hide mobile number (default: true)
  - Hide profile photos (default: false)

**Payment Post Profile Screen** (`payment_post_profile_screen.dart`):
- Shows plan options (Standard ₹299 / Featured ₹599)
- Promo code input
- Payment methods: Google Pay, PhonePe, Paytm, Other wallets
- After payment → Invoice Screen → Home

### 2. Main App Flow
```
Home (AppShell) → 4 Tabs:
  - Search (Discover)
  - Requests
  - Messages
  - Profile
```

### 3. Search/Discover Flow
**Discover Screen** (`discover_screen.dart`):
- Search bar (name search)
- Tabs: "All" / "India" / "Abroad"
- Filters button (with badge count):
  - State
  - City
  - Only NRIs (livingCountry != country)
  - Only in India (livingCountry == 'India')
  - Living in Country
  - Religion
  - Age range (min/max)
  - Height (min)
- Profile cards show:
  - Name, age, country, religion, height, profession
  - Featured/Sponsored badges
  - "Living in..." indicator if different from home country
- Click card → Ad Detail Screen

**Ad Detail Screen** (`ad_detail_screen.dart`):
- Full profile information
- "Request contact" button
- Shows: "Contact details will be shared only after approval"

### 4. Requests Flow
**Requests Screen** (`requests_screen.dart`):
- Two tabs: "Received" / "Sent"
- Received requests show:
  - Name, request type (Mobile & photos / Photos only / Mobile only)
  - Time ago
  - "NEW" badge for unread
  - Accept/Reject buttons
- Sent requests show:
  - Name, request type, time, status (Pending/Accepted/Rejected)

### 5. Messages Flow
**Messages Screen** (`messages_screen.dart`):
- List of conversations
- Search conversations
- Shows: name, preview, time, unread indicator
- Click → Chat Screen

**Chat Screen** (`chat_screen.dart`):
- Message list
- Input field
- Three-dot menu: Block user, Report user
- Safety tip banner
- When blocked: input disabled, shows "You blocked this user"

### 6. Profile & Boost Flow
**Profile Screen** (`profile_screen.dart`):
- Shows user's own profile details
- Boost status card (if active/expired)
- "Boost my profile" or "Repost my profile" button (if expired)
- Logout button

**Boost Profile Screen** (`boost_profile_screen.dart`):
- Current boost status:
  - Status (Active/Expired)
  - Type (Standard/Featured)
  - Days remaining / Expired X days ago
  - "Repost Profile" button if expired
- Analytics:
  - Total views
  - Total likes/shortlisted
  - Total requests
  - Recent viewers list
- Boost options:
  - Standard (₹299, 3 days)
  - Featured (₹599, 7 days)
- Click option → Payment Screen

**Payment Screen** (`payment_screen.dart`):
- Plan details
- Payment methods
- After payment → Invoice Screen

**Invoice Screen** (`invoice_screen.dart`):
- Invoice number, date
- Bill to (user info)
- Item details
- Amount breakdown:
  - Subtotal
  - Discount (if promo code)
  - GST (18%)
  - Total
- Payment method
- Company details (GSTIN, email, phone)
- Actions: Copy, Done, Share/Download

---

## Data Models

### 1. User Model
```typescript
{
  _id: ObjectId,
  email: string, // unique, required
  mobile: string, // unique, optional
  password: string, // hashed
  googleId?: string, // for Google Sign-In
  role: 'bride' | 'groom', // required
  fullName: string,
  dateOfBirth: Date,
  
  // Profile details
  profilePhoto?: string, // URL to uploaded image
  age: number, // calculated from DOB
  gender: 'Male' | 'Female',
  height?: number, // cm
  complexion?: string,
  
  // Location
  country: string, // home country
  livingCountry?: string, // where they live/work
  state?: string,
  city?: string,
  
  // Religion & Community
  religion: string,
  caste?: string, // depends on religion
  
  // Education & Profession
  education?: string,
  profession?: string,
  annualIncome?: string,
  
  // About
  about?: string,
  partnerPreferences?: string,
  
  // Privacy settings
  hideMobile: boolean, // default: true
  hidePhotos: boolean, // default: false
  
  // Boost status
  boostStatus: 'none' | 'active' | 'expired',
  boostType?: 'standard' | 'featured',
  boostExpiresAt?: Date,
  boostStartedAt?: Date,
  
  // Verification
  emailVerified: boolean,
  mobileVerified: boolean,
  idVerified: boolean, // future feature
  
  // Account status
  isActive: boolean,
  isBlocked: boolean,
  
  // Timestamps
  createdAt: Date,
  updatedAt: Date
}
```

### 2. Profile View Model (Analytics)
```typescript
{
  _id: ObjectId,
  profileUserId: ObjectId, // whose profile was viewed
  viewerUserId: ObjectId, // who viewed
  viewedAt: Date,
  createdAt: Date
}
```

### 3. Like/Shortlist Model
```typescript
{
  _id: ObjectId,
  userId: ObjectId, // who liked
  profileUserId: ObjectId, // whose profile was liked
  createdAt: Date
}
```

### 4. Contact Request Model
```typescript
{
  _id: ObjectId,
  fromUserId: ObjectId, // sender
  toUserId: ObjectId, // receiver
  requestType: 'mobile' | 'photos' | 'both', // what they're requesting
  status: 'pending' | 'accepted' | 'rejected',
  isRead: boolean, // for "NEW" badge
  createdAt: Date,
  updatedAt: Date
}
```

### 5. Conversation Model
```typescript
{
  _id: ObjectId,
  participants: [ObjectId, ObjectId], // sorted array of 2 user IDs
  lastMessage?: {
    text: string,
    sentBy: ObjectId,
    sentAt: Date
  },
  unreadCount: {
    [userId: string]: number // unread count per user
  },
  blockedBy?: ObjectId, // if conversation is blocked
  createdAt: Date,
  updatedAt: Date
}
```

### 6. Message Model
```typescript
{
  _id: ObjectId,
  conversationId: ObjectId,
  senderId: ObjectId,
  receiverId: ObjectId,
  text: string,
  isRead: boolean,
  createdAt: Date
}
```

### 7. Block Model
```typescript
{
  _id: ObjectId,
  blockerId: ObjectId, // who blocked
  blockedUserId: ObjectId, // who was blocked
  createdAt: Date
}
```

### 8. Report Model
```typescript
{
  _id: ObjectId,
  reporterId: ObjectId,
  reportedUserId: ObjectId,
  reason: string,
  description?: string,
  status: 'pending' | 'reviewed' | 'resolved',
  createdAt: Date
}
```

### 9. Payment/Transaction Model
```typescript
{
  _id: ObjectId,
  userId: ObjectId,
  type: 'boost' | 'repost',
  boostType: 'standard' | 'featured',
  userRole: 'bride' | 'groom', // User's role for pricing reference
  amount: number, // in paise (₹199/₹299 for standard, ₹399/₹599 for featured)
  currency: 'INR',
  discount?: number,
  gstAmount: number,
  totalAmount: number,
  promoCode?: string,
  paymentMethod: string, // 'google_pay' | 'phonepe' | 'paytm' | 'other'
  paymentIntentId?: string, // Stripe payment intent ID
  status: 'pending' | 'completed' | 'failed' | 'refunded',
  invoiceNumber: string, // e.g., "INV-1234567890"
  invoiceDate: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### 10. App Settings Model
```typescript
{
  _id: ObjectId,
  paymentEnabled: boolean, // Master payment switch
  allowFreePosting: boolean, // Allow free posting when payment enabled
  boostPricing: {
    standard: {
      bride: {
        price: number, // in paise
        duration: number, // days
        enabled: boolean // enable/disable for brides
      },
      groom: {
        price: number,
        duration: number,
        enabled: boolean // enable/disable for grooms
      }
    },
    featured: {
      bride: {
        price: number,
        duration: number,
        enabled: boolean
      },
      groom: {
        price: number,
        duration: number,
        enabled: boolean
      }
    }
  },
  company: {
    name: string,
    gstin: string,
    email: string,
    phone: string,
    address: string
  },
  app: {
    termsUrl: string,
    privacyUrl: string
  },
  updatedAt: Date,
  updatedBy: ObjectId // admin user ID
}
```

### 11. Promo Code Model
```typescript
{
  _id: ObjectId,
  code: string, // unique, uppercase
  discountType: 'percentage' | 'fixed',
  discountValue: number, // percentage (10) or fixed amount (5000 = ₹50)
  minAmount?: number, // minimum purchase amount
  maxDiscount?: number, // maximum discount cap
  validFrom: Date,
  validUntil: Date,
  usageLimit?: number, // total times can be used
  usedCount: number,
  isActive: boolean,
  createdAt: Date
}
```

---

## API Endpoints

### Authentication Routes (`/api/auth`)

#### POST `/api/auth/register`
**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "fullName": "Ahmed Ali",
  "role": "groom",
  "dateOfBirth": "1995-01-15",
  "country": "India",
  "city": "Mumbai",
  "religion": "Islam"
}
```
**Response:**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": { /* user object */ }
}
```

#### POST `/api/auth/login`
**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
**Response:**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": { /* user object */ }
}
```

#### POST `/api/auth/google`
**Request:**
```json
{
  "idToken": "google_id_token"
}
```
**Response:**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": { /* user object */ },
  "isNewUser": true
}
```

#### GET `/api/auth/me`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "user": { /* full user object */ }
}
```

#### POST `/api/auth/logout`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

#### POST `/api/auth/forgot-password`
**Request:**
```json
{
  "email": "user@example.com"
}
```

#### POST `/api/auth/reset-password`
**Request:**
```json
{
  "token": "reset_token",
  "newPassword": "newpassword123"
}
```

---

### Profile Routes (`/api/profile`)

#### PUT `/api/profile/complete`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "height": 175,
  "complexion": "Fair",
  "livingCountry": "UAE",
  "state": "Maharashtra",
  "city": "Mumbai",
  "caste": "Sunni",
  "education": "Bachelor's Degree",
  "profession": "Engineer",
  "annualIncome": "50000",
  "about": "Looking for a life partner...",
  "partnerPreferences": "Seeking someone...",
  "hideMobile": true,
  "hidePhotos": false
}
```
**Response:**
```json
{
  "success": true,
  "user": { /* updated user object */ }
}
```

#### POST `/api/profile/photo`
**Headers:** `Authorization: Bearer <token>`
**Request:** `multipart/form-data` with `photo` file
**Response:**
```json
{
  "success": true,
  "photoUrl": "https://cdn.silah.com/uploads/photo_123.jpg"
}
```

#### GET `/api/profile/search`
**Headers:** `Authorization: Bearer <token>`
**Query Parameters:**
- `q` - search query (name)
- `tab` - 'all' | 'india' | 'abroad'
- `state` - state filter
- `city` - city filter
- `onlyNRIs` - boolean (livingCountry != country)
- `onlyInIndia` - boolean (livingCountry == 'India')
- `livingCountry` - country filter
- `religion` - religion filter
- `minAge` - number
- `maxAge` - number
- `minHeight` - number
- `page` - page number (default: 1)
- `limit` - items per page (default: 20)

**Response:**
```json
{
  "success": true,
  "profiles": [
    {
      "id": "...",
      "name": "Ahmed",
      "age": 29,
      "country": "India",
      "livingCountry": "UAE",
      "state": "Maharashtra",
      "city": "Mumbai",
      "religion": "Islam",
      "role": "groom",
      "featured": true,
      "sponsored": false,
      "profession": "Engineer",
      "education": "Bachelor's Degree",
      "height": 175
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

**Important:** Filter by opposite role (bride sees grooms, groom sees brides)

#### GET `/api/profile/:userId`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "profile": {
    /* full profile object */
    /* Respect privacy settings (hideMobile, hidePhotos) */
  }
}
```
**Side effect:** Create ProfileView record

#### GET `/api/profile/me/views`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "totalViews": 128,
  "recentViews": [
    {
      "viewerId": "...",
      "viewerName": "Sara Ahmed",
      "viewedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### GET `/api/profile/me/analytics`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "totalViews": 128,
  "totalLikes": 24,
  "totalShortlisted": 8,
  "totalRequests": 12
}
```

#### POST `/api/profile/like`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "profileUserId": "user_id_here"
}
```

#### DELETE `/api/profile/like/:profileUserId`
**Headers:** `Authorization: Bearer <token>`

#### POST `/api/profile/shortlist`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "profileUserId": "user_id_here"
}
```

#### DELETE `/api/profile/shortlist/:profileUserId`
**Headers:** `Authorization: Bearer <token>`

---

### Boost Routes (`/api/boost`)

#### POST `/api/boost/activate`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "boostType": "standard", // or "featured"
  "paymentIntentId": "stripe_payment_intent_id"
}
```
**Response:**
```json
{
  "success": true,
  "boost": {
    "status": "active",
    "type": "standard",
    "expiresAt": "2024-01-18T00:00:00Z",
    "daysLeft": 3
  }
}
```

#### GET `/api/boost/status`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "boostStatus": "active", // "none" | "active" | "expired"
  "boostType": "standard",
  "expiresAt": "2024-01-18T00:00:00Z",
  "daysLeft": 2,
  "startedAt": "2024-01-15T00:00:00Z"
}
```

---

### Request Routes (`/api/requests`)

#### POST `/api/requests`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "toUserId": "user_id_here",
  "requestType": "both" // "mobile" | "photos" | "both"
}
```
**Response:**
```json
{
  "success": true,
  "request": { /* request object */ }
}
```

#### GET `/api/requests/received`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "requests": [
    {
      "id": "...",
      "fromUser": {
        "id": "...",
        "name": "Ahmed",
        "profilePhoto": "..."
      },
      "requestType": "both",
      "status": "pending",
      "isRead": false,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### GET `/api/requests/sent`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "requests": [
    {
      "id": "...",
      "toUser": {
        "id": "...",
        "name": "Sara",
        "profilePhoto": "..."
      },
      "requestType": "both",
      "status": "pending",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

#### POST `/api/requests/:requestId/accept`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "request": { /* updated request object */ },
  "contactDetails": {
    "mobile": "1234567890", // only if requestType includes "mobile"
    "photos": ["url1", "url2"] // only if requestType includes "photos"
  }
}
```

#### POST `/api/requests/:requestId/reject`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "request": { /* updated request object */ }
}
```

#### PUT `/api/requests/:requestId/read`
**Headers:** `Authorization: Bearer <token>`
**Marks request as read (removes "NEW" badge)**

---

### Message Routes (`/api/messages`)

#### GET `/api/messages/conversations`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "conversations": [
    {
      "id": "...",
      "otherUser": {
        "id": "...",
        "name": "Ahmed",
        "profilePhoto": "..."
      },
      "lastMessage": {
        "text": "Can we talk tomorrow?",
        "sentBy": "other_user_id",
        "sentAt": "2024-01-15T10:30:00Z"
      },
      "unreadCount": 2,
      "isBlocked": false
    }
  ]
}
```

#### GET `/api/messages/:conversationId`
**Headers:** `Authorization: Bearer <token>`
**Query Parameters:**
- `page` - page number
- `limit` - messages per page (default: 50)

**Response:**
```json
{
  "success": true,
  "messages": [
    {
      "id": "...",
      "senderId": "...",
      "receiverId": "...",
      "text": "Hi, nice to connect with you.",
      "isRead": true,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": { /* pagination info */ }
}
```

#### POST `/api/messages`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "receiverId": "user_id_here",
  "text": "Hello!"
}
```
**Response:**
```json
{
  "success": true,
  "message": { /* message object */ },
  "conversation": { /* conversation object */ }
}
```

#### PUT `/api/messages/:messageId/read`
**Headers:** `Authorization: Bearer <token>`
**Marks message as read**

#### PUT `/api/messages/:conversationId/read-all`
**Headers:** `Authorization: Bearer <token>`
**Marks all messages in conversation as read**

---

### Block & Report Routes (`/api/safety`)

#### POST `/api/safety/block`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "userId": "user_id_to_block"
}
```
**Response:**
```json
{
  "success": true,
  "message": "User blocked successfully"
}
```

#### DELETE `/api/safety/block/:userId`
**Headers:** `Authorization: Bearer <token>`
**Unblocks a user**

#### GET `/api/safety/blocked`
**Headers:** `Authorization: Bearer <token>`
**Returns list of blocked users**

#### POST `/api/safety/report`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "userId": "user_id_to_report",
  "reason": "Inappropriate behavior",
  "description": "User sent inappropriate messages"
}
```
**Response:**
```json
{
  "success": true,
  "report": { /* report object */ }
}
```

---

### Notification Routes (`/api/notifications`)

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

#### PUT `/api/notifications/preferences`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "pushEnabled": true,
  "messageNotifications": true,
  "requestNotifications": true,
  "matchNotifications": true,
  "profileViewNotifications": false,
  "boostReminders": true,
  "paymentNotifications": true
}
```
**Response:**
```json
{
  "success": true,
  "preferences": { /* updated preferences */ }
}
```

---

### App Settings Routes (`/api/settings`)

#### GET `/api/settings`
**No authentication required** (public settings)
**Response:**
```json
{
  "success": true,
  "settings": {
    "paymentEnabled": true,
    "allowFreePosting": false,
    "boostPricing": {
      "standard": {
        "bride": {
          "price": 19900,
          "duration": 3,
          "enabled": true
        },
        "groom": {
          "price": 29900,
          "duration": 3,
          "enabled": true
        }
      },
      "featured": {
        "bride": {
          "price": 39900,
          "duration": 7,
          "enabled": true
        },
        "groom": {
          "price": 59900,
          "duration": 7,
          "enabled": true
        }
      }
    }
  }
}
```
**Note:** Frontend should fetch this on app startup and update `AppSettingsService`. This allows admin to change pricing/controls without app update.

---

### Payment Routes (`/api/payment`)

#### POST `/api/payment/create-intent`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "boostType": "standard", // or "featured"
  "role": "bride", // or "groom" - used to determine pricing
  "promoCode": "SAVE10" // optional
}
```
**Note:** Price is determined by both `boostType` and `role`. Backend should fetch pricing from settings based on user's role.
**Response:**
```json
{
  "success": true,
  "paymentIntent": {
    "id": "stripe_payment_intent_id",
    "clientSecret": "pi_xxx_secret_xxx",
    "amount": 29900, // in paise
    "currency": "INR",
    "discount": 0,
    "gstAmount": 5382,
    "totalAmount": 35282
  }
}
```

#### POST `/api/payment/verify`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "paymentIntentId": "stripe_payment_intent_id",
  "paymentMethod": "google_pay"
}
```
**Response:**
```json
{
  "success": true,
  "transaction": { /* transaction object */ },
  "invoice": {
    "invoiceNumber": "INV-1234567890",
    "invoiceDate": "2024-01-15T10:30:00Z",
    "amount": 29900,
    "discount": 0,
    "gstAmount": 5382,
    "totalAmount": 35282
  }
}
```

#### GET `/api/payment/invoice/:invoiceNumber`
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "success": true,
  "invoice": {
    "invoiceNumber": "INV-1234567890",
    "invoiceDate": "2024-01-15T10:30:00Z",
    "user": { /* user object */ },
    "item": {
      "name": "Standard boost",
      "quantity": 1,
      "price": 29900
    },
    "subtotal": 29900,
    "discount": 0,
    "gstRate": 18,
    "gstAmount": 5382,
    "totalAmount": 35282,
    "paymentMethod": "google_pay",
    "status": "completed"
  }
}
```

#### POST `/api/payment/promo-code/validate`
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "code": "SAVE10",
  "amount": 29900
}
```
**Response:**
```json
{
  "success": true,
  "valid": true,
  "discount": 2990, // discount amount in paise
  "discountType": "percentage",
  "message": "Promo code applied successfully"
}
```

#### POST `/api/payment/webhook`
**No auth required** (Stripe webhook)
**Handles:** `payment_intent.succeeded`, `payment_intent.payment_failed`

---

## Authentication

### JWT Token Structure
```json
{
  "userId": "user_id_here",
  "email": "user@example.com",
  "role": "groom",
  "iat": 1234567890,
  "exp": 1234654290
}
```

### Token Expiry
- Access token: 7 days
- Refresh token: 30 days (optional, for future implementation)

### Google Sign-In Flow
1. Frontend gets Google ID token from Firebase
2. Sends to `/api/auth/google` with `idToken`
3. Backend verifies token with Google
4. If user exists: login and return JWT
5. If new user: create account and return JWT (user must complete profile)

---

## Payment Integration

### Payment Provider: Stripe
- **Currency**: INR (Indian Rupees)
- **Payment Methods**: Google Pay, PhonePe, Paytm (via Stripe)

### Boost Pricing
- **Standard**: ₹299 (3 days)
- **Featured**: ₹599 (7 days)

### GST Calculation
- **GST Rate**: 18%
- Applied on: (Amount - Discount)
- Example: ₹299 - ₹0 = ₹299, GST = ₹53.82, Total = ₹352.82

### Payment Flow
1. User selects boost type
2. Frontend calls `/api/payment/create-intent`
3. Backend creates Stripe PaymentIntent
4. Frontend processes payment via Stripe SDK
5. On success, frontend calls `/api/payment/verify`
6. Backend:
   - Verifies payment with Stripe
   - Creates Transaction record
   - Activates boost (updates user.boostStatus, boostExpiresAt)
   - Returns invoice data
7. Frontend navigates to Invoice Screen

### Invoice Generation
- **Invoice Number Format**: `INV-{timestamp}` (e.g., `INV-1234567890`)
- **Invoice Date**: Payment completion date
- **GSTIN**: Required for Indian businesses (to be configured)
- **Company Details**: To be configured

---

## Real-time Features

### Socket.io Events

#### Client → Server
- `join:user` - User joins (send userId)
- `send:message` - Send message
- `typing:start` - User started typing
- `typing:stop` - User stopped typing
- `read:message` - Mark message as read

#### Server → Client
- `new:message` - New message received
- `message:sent` - Message sent confirmation
- `typing:indicator` - Other user is typing
- `user:online` - User came online
- `user:offline` - User went offline
- `new:request` - New contact request received
- `request:accepted` - Request was accepted
- `request:rejected` - Request was rejected

### Room Structure
- Conversation rooms: `conversation:{conversationId}`
- User rooms: `user:{userId}` (for notifications)

---

## File Uploads

### Profile Photo Upload
- **Endpoint**: `POST /api/profile/photo`
- **Method**: `multipart/form-data`
- **Field name**: `photo`
- **Max size**: 5MB
- **Allowed formats**: JPG, PNG, WebP
- **Storage**: AWS S3 / Cloudinary / Local (development)
- **URL format**: `https://cdn.silah.com/uploads/{userId}_{timestamp}.{ext}`

### Image Processing
- Resize to max 800x800px
- Compress to reduce file size
- Generate thumbnail (200x200px)

---

## Search & Filtering

### Search Logic
1. **Role Filtering**: Always filter by opposite role (bride sees grooms, groom sees brides)
2. **Boost Priority**: Featured > Standard > None (sorting)
3. **Active Boost Only**: Only show profiles with active boost (boostStatus === 'active' && boostExpiresAt > now)
4. **Privacy**: Respect hideMobile, hidePhotos when returning profile data

### Filter Combinations
- **Tab: "All"**: No country filter
- **Tab: "India"**: `livingCountry === 'India'` OR `(livingCountry is null AND country === 'India')`
- **Tab: "Abroad"**: `livingCountry !== 'India'` AND `livingCountry !== null`
- **Only NRIs**: `livingCountry !== country` AND `livingCountry !== null`
- **Only in India**: `livingCountry === 'India'`

### Search Indexes (MongoDB)
```javascript
// User collection indexes
db.users.createIndex({ role: 1, boostStatus: 1, boostExpiresAt: 1 })
db.users.createIndex({ country: 1, livingCountry: 1 })
db.users.createIndex({ religion: 1 })
db.users.createIndex({ state: 1, city: 1 })
db.users.createIndex({ "fullName": "text" }) // text search
```

---

## Privacy & Security

### Privacy Controls
1. **Hide Mobile**: If `hideMobile === true`, mobile number not returned in profile API
2. **Hide Photos**: If `hidePhotos === true`, profilePhoto not returned in profile API
3. **Contact Requests**: Mobile/photos only shared after request is accepted

### Blocking Logic
- Blocked users cannot:
  - Send messages
  - Send contact requests
  - See each other's profiles in search
- Blocked users are filtered out in:
  - Search results
  - Messages list
  - Requests list

### Reporting
- Reports stored in database
- Admin dashboard (future) to review reports
- Auto-flag users with multiple reports

---

## Notifications

### Notification Types
1. **New Contact Request** - When user receives a contact request
2. **Request Accepted/Rejected** - When sent request is accepted/rejected
3. **New Message** - When user receives a new message
4. **New Profile Match** - When new profiles match user's preferences
5. **Profile View** - When someone views user's profile
6. **Profile Liked/Shortlisted** - When someone likes/shortlists profile
7. **Boost Expiring** - Reminder 24 hours before boost expires
8. **Boost Expired** - Notification when boost expires
9. **Payment Success** - When payment completes successfully
10. **Payment Failed** - When payment processing fails

### Push Notifications
- **Technology:** Firebase Cloud Messaging (FCM)
- **Platforms:** Android (FCM), iOS (APNs via FCM)
- **Features:**
  - Foreground notifications (in-app)
  - Background notifications (system)
  - Notification tap navigation
  - Custom notification sounds
  - Notification badges

### In-App Notifications
- Unread message count (badge on Messages tab)
- Unread request count (badge on Requests tab)
- "NEW" badge on unread requests
- Notification history screen
- Real-time badge updates via Socket.io

### Notification Badges
- **Messages Tab**: Total unread messages across all conversations
- **Requests Tab**: Total unread received requests
- **Search Tab** (optional): New matches count

### Notification Settings
- Enable/Disable push notifications
- Per-type notification preferences:
  - New messages
  - New requests
  - Request responses
  - New matches
  - Profile views
  - Profile likes
  - Boost reminders
  - Payment updates

---

## Admin Dashboard

### Overview
Web-based admin dashboard for managing the Silah matrimony platform. Built with React/Vue.js or similar web framework, consuming the admin API endpoints.

### Admin User Model
```typescript
{
  _id: ObjectId,
  email: string, // unique, required
  password: string, // hashed
  fullName: string,
  role: 'admin' | 'super_admin',
  isActive: boolean,
  lastLogin?: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### Admin Dashboard Features

#### 1. Dashboard Home
- **Statistics Overview:**
  - Total users (with growth trend)
  - Active boosts count
  - Pending reports count
  - Today's revenue
  - Total revenue (all time)
  - New users today
  - Active conversations
  - Total contact requests
- **Revenue Chart:** Daily/weekly/monthly revenue trends
- **User Growth Chart:** New user registrations over time
- **Quick Actions:** Links to common tasks

#### 2. User Management
- **User List:**
  - Search by name/email
  - Filter by: All, Active, Blocked, Verified, Boosted
  - Sort by: Registration date, Last active, Boost status
  - Pagination
- **User Details:**
  - Full profile information
  - Boost history
  - Report history
  - Block/unblock status
  - Verification status
  - Activity log
- **Actions:**
  - Block/Unblock user
  - Verify/Unverify user
  - View user's conversations
  - View user's reports
  - Delete user (soft delete)

#### 3. Reports Management
- **Reports List:**
  - Filter by: Pending, Reviewed, Resolved
  - Sort by: Date, Report count
  - Show: Reporter, Reported user, Reason, Status
- **Report Details:**
  - Full report information
  - Reporter details
  - Reported user details
  - Report history (if multiple)
  - Related reports
- **Actions:**
  - Mark as reviewed
  - Resolve report
  - Block reported user
  - Dismiss report
  - View reported user's profile

#### 4. Transactions/Payments
- **Transactions List:**
  - Filter by: Date range, Status, Payment method
  - Search by: Invoice number, User email
  - Sort by: Date, Amount
  - Show: User, Amount, Status, Invoice number, Date
- **Transaction Details:**
  - Full transaction information
  - Invoice details
  - Payment method
  - User details
  - Boost activation status
- **Actions:**
  - View invoice
  - Refund transaction
  - Export transactions (CSV/Excel)

#### 5. Analytics & Reports
- **User Analytics:**
  - User growth over time
  - User distribution by role (bride/groom)
  - User distribution by country
  - User distribution by religion
  - Active vs inactive users
- **Revenue Analytics:**
  - Revenue by day/week/month
  - Revenue by boost type (Standard/Featured)
  - Revenue by payment method
  - Average transaction value
- **Engagement Analytics:**
  - Total profile views
  - Total contact requests
  - Total messages sent
  - Active conversations
  - Boost conversion rate
- **Export Options:**
  - Export analytics as CSV/Excel
  - Generate PDF reports

#### 6. Settings
- **Boost Pricing:**
  - Standard boost price (₹299)
  - Featured boost price (₹599)
  - Boost duration (3 days / 7 days)
- **Promo Codes:**
  - Create new promo codes
  - Edit existing codes
  - Deactivate/Activate codes
  - View usage statistics
- **App Settings:**
  - Company details (for invoices)
  - GSTIN
  - Support email/phone
  - Terms & Conditions URL
  - Privacy Policy URL
- **Email Templates:**
  - Welcome email
  - Password reset email
  - Report notification email

---

### Admin API Endpoints

#### Admin Authentication Routes (`/api/admin/auth`)

##### POST `/api/admin/auth/login`
**Request:**
```json
{
  "email": "admin@silah.com",
  "password": "admin_password"
}
```
**Response:**
```json
{
  "success": true,
  "token": "admin_jwt_token",
  "admin": {
    "id": "...",
    "email": "admin@silah.com",
    "fullName": "Admin User",
    "role": "admin"
  }
}
```

##### GET `/api/admin/auth/me`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "admin": { /* admin object */ }
}
```

##### POST `/api/admin/auth/logout`
**Headers:** `Authorization: Bearer <admin_token>`

---

#### Admin Dashboard Routes (`/api/admin/dashboard`)

##### GET `/api/admin/dashboard/stats`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "stats": {
    "totalUsers": 1250,
    "activeBoosts": 89,
    "pendingReports": 12,
    "todayRevenue": 45200,
    "totalRevenue": 1250000,
    "newUsersToday": 23,
    "activeConversations": 156,
    "totalRequests": 342
  }
}
```

##### GET `/api/admin/dashboard/revenue-chart`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:**
- `period` - 'daily' | 'weekly' | 'monthly' (default: 'daily')
- `days` - number of days (default: 30)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "date": "2024-01-15",
      "revenue": 45200,
      "transactions": 15
    }
  ]
}
```

##### GET `/api/admin/dashboard/user-growth`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:**
- `days` - number of days (default: 30)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "date": "2024-01-15",
      "newUsers": 23,
      "totalUsers": 1250
    }
  ]
}
```

---

#### Admin User Management Routes (`/api/admin/users`)

##### GET `/api/admin/users`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:**
- `search` - search by name/email
- `filter` - 'all' | 'active' | 'blocked' | 'verified' | 'boosted'
- `sort` - 'date' | 'name' | 'boost'
- `order` - 'asc' | 'desc'
- `page` - page number
- `limit` - items per page

**Response:**
```json
{
  "success": true,
  "users": [
    {
      "id": "...",
      "name": "Ahmed Ali",
      "email": "ahmed@example.com",
      "role": "groom",
      "status": "active",
      "isVerified": true,
      "boostStatus": "active",
      "boostExpiresAt": "2024-01-18T00:00:00Z",
      "reportCount": 0,
      "createdAt": "2024-01-10T00:00:00Z",
      "lastActive": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": { /* pagination info */ }
}
```

##### GET `/api/admin/users/:userId`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "user": {
    /* full user object with all details */
    "boostHistory": [ /* array of boost transactions */ ],
    "reportHistory": [ /* array of reports */ ],
    "activityLog": [ /* array of activities */ ]
  }
}
```

##### POST `/api/admin/users/:userId/block`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "reason": "Violation of terms"
}
```
**Response:**
```json
{
  "success": true,
  "message": "User blocked successfully"
}
```

##### POST `/api/admin/users/:userId/unblock`
**Headers:** `Authorization: Bearer <admin_token>`

##### POST `/api/admin/users/:userId/verify`
**Headers:** `Authorization: Bearer <admin_token>`
**Verifies user (ID verification)**

##### POST `/api/admin/users/:userId/unverify`
**Headers:** `Authorization: Bearer <admin_token>`

##### DELETE `/api/admin/users/:userId`
**Headers:** `Authorization: Bearer <admin_token>`
**Soft delete user**

---

#### Admin Reports Routes (`/api/admin/reports`)

##### GET `/api/admin/reports`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:**
- `status` - 'pending' | 'reviewed' | 'resolved' | 'all'
- `sort` - 'date' | 'count'
- `page` - page number
- `limit` - items per page

**Response:**
```json
{
  "success": true,
  "reports": [
    {
      "id": "...",
      "reporter": {
        "id": "...",
        "name": "Sara Khan",
        "email": "sara@example.com"
      },
      "reportedUser": {
        "id": "...",
        "name": "Ahmed Ali",
        "email": "ahmed@example.com"
      },
      "reason": "Inappropriate behavior",
      "description": "User sent inappropriate messages",
      "status": "pending",
      "reportCount": 3,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": { /* pagination info */ }
}
```

##### GET `/api/admin/reports/:reportId`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "report": {
    /* full report object */
    "relatedReports": [ /* other reports for same user */ ],
    "reporterHistory": [ /* reporter's report history */ ]
  }
}
```

##### PUT `/api/admin/reports/:reportId/review`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "action": "resolve" | "dismiss" | "block_user",
  "notes": "Admin notes"
}
```
**Response:**
```json
{
  "success": true,
  "report": { /* updated report object */ }
}
```

##### POST `/api/admin/reports/:reportId/resolve`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "action": "block_user" | "dismiss",
  "notes": "Admin notes"
}
```

---

#### Admin Transactions Routes (`/api/admin/transactions`)

##### GET `/api/admin/transactions`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:**
- `startDate` - start date (ISO format)
- `endDate` - end date (ISO format)
- `status` - 'pending' | 'completed' | 'failed' | 'refunded' | 'all'
- `paymentMethod` - payment method filter
- `search` - search by invoice number or user email
- `page` - page number
- `limit` - items per page

**Response:**
```json
{
  "success": true,
  "transactions": [
    {
      "id": "...",
      "user": {
        "id": "...",
        "name": "Ahmed Ali",
        "email": "ahmed@example.com"
      },
      "type": "boost",
      "boostType": "standard",
      "amount": 29900,
      "discount": 0,
      "gstAmount": 5382,
      "totalAmount": 35282,
      "paymentMethod": "google_pay",
      "status": "completed",
      "invoiceNumber": "INV-1234567890",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": { /* pagination info */ },
  "summary": {
    "totalRevenue": 1250000,
    "totalTransactions": 450,
    "averageTransaction": 2777
  }
}
```

##### GET `/api/admin/transactions/:transactionId`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "transaction": {
    /* full transaction object */
    "invoice": { /* invoice details */ },
    "user": { /* user details */ }
  }
}
```

##### POST `/api/admin/transactions/:transactionId/refund`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "reason": "User requested refund",
  "amount": 35282 // optional, full refund if not specified
}
```
**Response:**
```json
{
  "success": true,
  "refund": {
    "id": "...",
    "amount": 35282,
    "status": "processed"
  }
}
```

##### GET `/api/admin/transactions/export`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:** Same as GET `/api/admin/transactions`
**Response:** CSV/Excel file download

---

#### Admin Analytics Routes (`/api/admin/analytics`)

##### GET `/api/admin/analytics/users`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:**
- `period` - 'daily' | 'weekly' | 'monthly'
- `days` - number of days

**Response:**
```json
{
  "success": true,
  "analytics": {
    "userGrowth": [ /* array of daily/weekly/monthly data */ ],
    "userDistribution": {
      "byRole": {
        "bride": 600,
        "groom": 650
      },
      "byCountry": {
        "India": 1000,
        "UAE": 150,
        "Saudi Arabia": 100
      },
      "byReligion": {
        "Islam": 800,
        "Hindu": 300,
        "Christian": 150
      }
    },
    "activeUsers": 850,
    "inactiveUsers": 400
  }
}
```

##### GET `/api/admin/analytics/revenue`
**Headers:** `Authorization: Bearer <admin_token>`
**Query Parameters:**
- `period` - 'daily' | 'weekly' | 'monthly'
- `days` - number of days

**Response:**
```json
{
  "success": true,
  "analytics": {
    "revenueByPeriod": [ /* array of revenue data */ ],
    "revenueByBoostType": {
      "standard": 750000,
      "featured": 500000
    },
    "revenueByPaymentMethod": {
      "google_pay": 600000,
      "phonepe": 400000,
      "paytm": 250000
    },
    "averageTransactionValue": 2777,
    "totalRevenue": 1250000
  }
}
```

##### GET `/api/admin/analytics/engagement`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "analytics": {
    "totalProfileViews": 12500,
    "totalContactRequests": 3420,
    "totalMessages": 8900,
    "activeConversations": 156,
    "boostConversionRate": 0.15, // 15% of users boost
    "requestAcceptanceRate": 0.65 // 65% of requests accepted
  }
}
```

---

#### Admin Settings Routes (`/api/admin/settings`)

##### GET `/api/admin/settings`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "settings": {
    "paymentEnabled": true,
    "allowFreePosting": false,
    "boostPricing": {
      "standard": {
        "bride": {
          "price": 19900, // in paise
          "duration": 3, // days
          "enabled": true // enable/disable this option for brides
        },
        "groom": {
          "price": 29900,
          "duration": 3,
          "enabled": true // enable/disable this option for grooms
        }
      },
      "featured": {
        "bride": {
          "price": 39900,
          "duration": 7,
          "enabled": true
        },
        "groom": {
          "price": 59900,
          "duration": 7,
          "enabled": true
        }
      }
    },
    "company": {
      "name": "Silah Matrimony",
      "gstin": "29ABCDE1234F1Z5",
      "email": "support@silah.com",
      "phone": "+91-1234567890",
      "address": "123 Main St, Mumbai, Maharashtra 400001"
    },
    "app": {
      "termsUrl": "https://silah.com/terms",
      "privacyUrl": "https://silah.com/privacy"
    }
  }
}
```

##### PUT `/api/admin/settings/boost-pricing`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "standard": {
    "bride": {
      "price": 19900,
      "duration": 3,
      "enabled": true
    },
    "groom": {
      "price": 29900,
      "duration": 3,
      "enabled": true
    }
  },
  "featured": {
    "bride": {
      "price": 39900,
      "duration": 7,
      "enabled": true
    },
    "groom": {
      "price": 59900,
      "duration": 7,
      "enabled": true
    }
  }
}
```
**Note:** 
- `price`: Amount in paise (₹199 = 19900)
- `duration`: Number of days the boost is valid
- `enabled`: Enable/disable this boost option for the specific role

##### PUT `/api/admin/settings/payment`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "paymentEnabled": true,
  "allowFreePosting": false
}
```
**Response:**
```json
{
  "success": true,
  "settings": {
    "paymentEnabled": true,
    "allowFreePosting": false
  }
}
```
**Note:**
- `paymentEnabled`: Master switch to enable/disable payment system
  - `true`: Payment required (users must pay to boost)
  - `false`: Payment disabled (all boosts are free)
- `allowFreePosting`: Allow users to skip payment and post for free
  - Only applicable when `paymentEnabled: true`
  - `true`: Users can choose to skip payment
  - `false`: Payment is mandatory when enabled

##### PUT `/api/admin/settings/company`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "name": "Silah Matrimony",
  "gstin": "29ABCDE1234F1Z5",
  "email": "support@silah.com",
  "phone": "+91-1234567890",
  "address": "123 Main St, Mumbai, Maharashtra 400001"
}
```

---

#### Admin Promo Codes Routes (`/api/admin/promo-codes`)

##### GET `/api/admin/promo-codes`
**Headers:** `Authorization: Bearer <admin_token>`
**Response:**
```json
{
  "success": true,
  "promoCodes": [
    {
      "id": "...",
      "code": "SAVE10",
      "discountType": "percentage",
      "discountValue": 10,
      "minAmount": 29900,
      "maxDiscount": 5000,
      "validFrom": "2024-01-01T00:00:00Z",
      "validUntil": "2024-12-31T23:59:59Z",
      "usageLimit": 100,
      "usedCount": 45,
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

##### POST `/api/admin/promo-codes`
**Headers:** `Authorization: Bearer <admin_token>`
**Request:**
```json
{
  "code": "SAVE10",
  "discountType": "percentage",
  "discountValue": 10,
  "minAmount": 29900,
  "maxDiscount": 5000,
  "validFrom": "2024-01-01T00:00:00Z",
  "validUntil": "2024-12-31T23:59:59Z",
  "usageLimit": 100
}
```

##### PUT `/api/admin/promo-codes/:codeId`
**Headers:** `Authorization: Bearer <admin_token>`
**Update promo code**

##### DELETE `/api/admin/promo-codes/:codeId`
**Headers:** `Authorization: Bearer <admin_token>`
**Deactivate promo code**

---

### Admin Middleware

#### Admin Authentication Middleware
```typescript
// middleware/adminAuth.middleware.ts
export const adminProtect = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({
        success: false,
        error: { message: 'Not authorized' }
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const admin = await Admin.findById(decoded.id);
    
    if (!admin || !admin.isActive) {
      return res.status(401).json({
        success: false,
        error: { message: 'Admin not found or inactive' }
      });
    }

    req.admin = admin;
    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      error: { message: 'Not authorized' }
    });
  }
};
```

---

### Admin Dashboard UI Recommendations

#### Technology Stack
- **Frontend Framework:** React.js or Vue.js
- **UI Library:** Material-UI, Ant Design, or Tailwind CSS
- **State Management:** Redux or Zustand
- **Charts:** Chart.js, Recharts, or ApexCharts
- **HTTP Client:** Axios
- **Routing:** React Router or Vue Router

#### Key Pages/Screens
1. **Login Page** - Admin authentication
2. **Dashboard Home** - Statistics and charts
3. **Users Page** - User list with filters and actions
4. **User Detail Page** - Full user information
5. **Reports Page** - Reports list with filters
6. **Report Detail Page** - Report review and actions
7. **Transactions Page** - Payment transactions list
8. **Transaction Detail Page** - Transaction and invoice details
9. **Analytics Page** - Charts and graphs
10. **Settings Page** - App configuration

#### Design Guidelines
- **Color Scheme:** Match app theme (Green primary, white background, light grey, black text)
- **Responsive:** Mobile-friendly design
- **Professional:** Clean, modern admin panel design
- **Accessibility:** WCAG compliant

---

## Additional Features to Consider

### 1. Verification Badges
- Mobile verified (OTP verification)
- Email verified (email link)
- ID verified (document upload - future)

### 2. Safety Tutorial
- One-time modal/screen on first login
- Explains: safety rules, how to block/report, "We never ask for OTP or money"

### 3. Profile Completion Score
- Show percentage of profile completion
- Encourage users to complete profile

### 4. Match Suggestions
- Algorithm-based matching (future)
- Based on preferences, location, religion, etc.

### 5. Admin Dashboard (Future)
- User management
- Report review
- Analytics
- Payment management

---

## Environment Variables

```env
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/silah

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRE=7d

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Stripe
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# File Upload
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_BUCKET_NAME=silah-uploads
AWS_REGION=ap-south-1

# Or Cloudinary
CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx

# Company Details (for invoices)
COMPANY_NAME=Silah Matrimony
COMPANY_GSTIN=29ABCDE1234F1Z5
COMPANY_EMAIL=support@silah.com
COMPANY_PHONE=+91-1234567890
COMPANY_ADDRESS=123 Main St, Mumbai, Maharashtra 400001
```

---

## Database Indexes Summary

```javascript
// Users
db.users.createIndex({ email: 1 }, { unique: true })
db.users.createIndex({ mobile: 1 }, { sparse: true, unique: true })
db.users.createIndex({ role: 1, boostStatus: 1, boostExpiresAt: 1 })
db.users.createIndex({ country: 1, livingCountry: 1, state: 1, city: 1 })
db.users.createIndex({ religion: 1 })
db.users.createIndex({ "fullName": "text" })

// Profile Views
db.profileviews.createIndex({ profileUserId: 1, viewedAt: -1 })
db.profileviews.createIndex({ viewerUserId: 1 })

// Contact Requests
db.requests.createIndex({ toUserId: 1, status: 1, createdAt: -1 })
db.requests.createIndex({ fromUserId: 1, status: 1, createdAt: -1 })

// Conversations
db.conversations.createIndex({ participants: 1 })
db.conversations.createIndex({ "lastMessage.sentAt": -1 })

// Messages
db.messages.createIndex({ conversationId: 1, createdAt: -1 })
db.messages.createIndex({ senderId: 1, receiverId: 1 })

// Blocks
db.blocks.createIndex({ blockerId: 1, blockedUserId: 1 }, { unique: true })

// Transactions
db.transactions.createIndex({ userId: 1, createdAt: -1 })
db.transactions.createIndex({ invoiceNumber: 1 }, { unique: true })
```

---

## API Response Format

### Success Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Optional success message"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "message": "Error message",
    "code": "ERROR_CODE",
    "field": "fieldName" // optional, for validation errors
  }
}
```

### Common Error Codes
- `VALIDATION_ERROR` - Input validation failed
- `UNAUTHORIZED` - Invalid or missing token
- `FORBIDDEN` - User doesn't have permission
- `NOT_FOUND` - Resource not found
- `DUPLICATE_ENTRY` - Email/mobile already exists
- `PAYMENT_FAILED` - Payment processing failed
- `BOOST_EXPIRED` - Boost has expired
- `ALREADY_BLOCKED` - User is already blocked
- `SERVER_ERROR` - Internal server error

---

## Testing Checklist

### Authentication
- [ ] Register with email/password
- [ ] Register with Google
- [ ] Login with email/password
- [ ] Login with Google
- [ ] Get current user
- [ ] Logout
- [ ] Forgot password
- [ ] Reset password

### Profile
- [ ] Complete profile
- [ ] Upload profile photo
- [ ] Search profiles (all filters)
- [ ] View profile detail
- [ ] Get profile analytics
- [ ] Like/unlike profile
- [ ] Shortlist/unshortlist profile

### Boost
- [ ] Get boost status
- [ ] Activate standard boost
- [ ] Activate featured boost
- [ ] Repost after expiry

### Requests
- [ ] Send contact request
- [ ] Get received requests
- [ ] Get sent requests
- [ ] Accept request
- [ ] Reject request
- [ ] Mark request as read

### Messages
- [ ] Get conversations
- [ ] Get messages
- [ ] Send message
- [ ] Mark message as read
- [ ] Real-time message delivery

### Safety
- [ ] Block user
- [ ] Unblock user
- [ ] Get blocked users
- [ ] Report user

### Payment
- [ ] Create payment intent
- [ ] Validate promo code
- [ ] Verify payment
- [ ] Get invoice
- [ ] Handle webhook

---

## Next Steps

1. **Backend Setup**
   - Initialize Node.js/Express/TypeScript project
   - Set up MongoDB connection
   - Configure environment variables

2. **Implement Core Features**
   - Authentication (register, login, Google)
   - User model and profile completion
   - Search and filtering
   - Boost activation

3. **Payment Integration**
   - Stripe setup
   - Payment intent creation
   - Webhook handling
   - Invoice generation

4. **Real-time Features**
   - Socket.io setup
   - Message delivery
   - Typing indicators

5. **File Uploads**
   - Configure storage (S3/Cloudinary)
   - Image processing
   - Photo upload endpoint

6. **Testing**
   - Unit tests
   - Integration tests
   - API testing with Postman

7. **Deployment**
   - Production environment setup
   - Database migration
   - SSL certificates
   - Domain configuration

---

**Document Version**: 1.0  
**Last Updated**: 2024-01-15  
**Author**: Backend Audit
