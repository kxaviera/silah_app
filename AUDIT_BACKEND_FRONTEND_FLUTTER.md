# Silah – Backend, Admin Dashboard & Flutter Audit

**Date:** January 24, 2026  
**Scope:** Backend (Node/Express), Admin Dashboard (React/Vite), Flutter app

---

## 1. Backend

### 1.1 Routes registered in `server.ts`

| Mount | Routes |
|-------|--------|
| `/api/auth` | auth |
| `/api/profile` | profile |
| `/api/boost` | boost |
| `/api/requests` | request |
| `/api/messages` | message |
| `/api/block` | block |
| `/api/notifications` | notification |
| `/api/settings` | settings |
| `/api/payment` | payment |
| `/api/admin/*` | admin auth, dashboard, users, reports, transactions, settings, promo-codes, activity-logs, bulk, communications, analytics, system |

All expected user and admin route mounts are present.

### 1.2 Controllers & behaviour

- **Auth:** Register, login, Google, forgot/reset password, getMe, logout, delete-account. IP logging via `UserAccessLog` on register, login, Google login. `trust proxy` set for correct `req.ip` behind Nginx.
- **Profile:** Complete profile, photo upload, search, get profile, analytics. No IP log on profile completion; IP is logged at registration/login.
- **Messages:** Conversations, get messages, send message (text + image via multer), mark read. **Fixed:** Socket emission on message create so recipients get real-time `new:message`.
- **Requests:** Send, received, sent, accept, reject, check status. `checkRequestStatus` returns `approved` and `canChat`.
- **Boost:** Activate, status.
- **Block:** Status, block, unblock.
- **Notifications:** Register FCM token (`token` / `fcmToken`), get notifications, unread counts, read/read-all, delete, preferences. **Gap:** No server-side FCM send on new message/request (tokens are stored only).
- **Settings:** App settings (public).
- **Payment:** Create intent, verify, invoice, validate promo.

### 1.3 Socket.io (`server.ts`)

- Rooms: `user:${userId}`, `conversation:${conversationId}`.
- Events: `join:user`, `leave:user`, `join:conversation`, `leave:conversation`, `typing:start`, `typing:stop`, `send:message` → `new:message`, `new:request`, `request:accepted`, `request:rejected`.
- **Fixed:** `typing:indicator` payload now includes `conversationId` so Flutter can route to the correct stream.

### 1.4 Gaps / follow-ups

| Item | Status |
|------|--------|
| FCM: send push when new message/request | Not implemented (tokens only) |
| IP log on profile completion | Optional (auth already logs at signup/login) |
| Circular dependency `message.controller` → `server` | Acceptable; consider moving socket emit to a small `socket.emit` helper if it grows |

---

## 2. Admin Dashboard (React / Vite)

### 2.1 Stack & config

- **API base:** `api.ts` – `VITE_API_URL` or `https://api.rewardo.fun/api`; admin calls use `ADMIN_BASE` = same host + `/api/admin`.
- **Auth:** `adminApi` + `localStorage` `admin_token`; 401 clears token and redirects to `/login`.

### 2.2 Pages & routes

- Login, Dashboard, Users, UserDetail, Reports, ReportDetail, Transactions, TransactionDetail, Analytics, Settings, PromoCodes, PromoCodeDetail.
- UserDetail: user CRUD, block/unblock, verify/reject, role, **access logs** (IP) via `usersService.getUserAccessLogs(id)`.

### 2.3 Services vs backend

| Service | Backend route | Notes |
|---------|----------------|-------|
| auth.service | `/admin/auth/login`, logout, me | Matches |
| users.service | `/admin/users`, `/:id`, `/:id/access-logs`, block, unblock, verify, reject, role | Matches |
| dashboard.service | `/admin/dashboard/stats`, revenue-chart, user-growth | Matches |
| reports.service | `/admin/reports`, `/:id`, review, resolve, delete | Matches |
| transactions.service | `/admin/transactions`, `/:id`, refund | Matches |
| settings.service | `/admin/settings`, pricing, payment | Matches |
| promoCodes.service | `/admin/promo-codes` CRUD, usage | Matches |

No missing admin API usage detected for current features.

### 2.4 Gaps / follow-ups

| Item | Status |
|------|--------|
| API URL | Uses `api.rewardo.fun`; confirm if Silah uses same backend or different domain (e.g. `api.silah.in`) |
| Activity logs / system health | Routes exist in backend; dashboard may not have dedicated UI for all – confirm if needed |

---

## 3. Flutter App

### 3.1 Config & API

- **AppConfig:** `baseUrl` = production `https://api.rewardo.fun/api` (or staging/local). Same domain note as admin.
- **ApiClient:** Dio, baseUrl, auth header from SharedPreferences `auth_token`, 401 clears token.
- **Screens:** Splash, Signup, Login, Forgot/Reset password, Complete profile, Payment post profile, Invoice, AppShell (Discover, Requests, Messages, Profile), Create ad, Payment, Boost activity, Settings, Terms, Privacy, Help, Notifications, Safety tutorial, Ad detail, Chat (via MaterialPageRoute).

### 3.2 API usage vs backend

- **AuthApi:** register, login, getMe, logout, forgot/reset – paths match backend.
- **ProfileApi:** complete, photo, search, get profile, analytics – match.
- **RequestApi:** send (userId + toUserId), received, sent, accept, reject, checkStatus – match.
- **MessageApi:** conversations, get messages, send message, send image (multipart), mark read – match.
- **NotificationApi:** register token, get notifications, unread counts, read – match.
- **BlockApi, BoostApi, PaymentApi, SettingsApi:** Aligned with backend.

### 3.3 Navigation

- **Named routes in `main.dart`:** splash, signup, login, forgot-password, reset-password, complete-profile, payment-post-profile, invoice, home (AppShell), create-ad, payment, boost-activity, requests, settings, terms, privacy, help, help-detail, notifications, safety-tutorial.
- ChatScreen, AdDetailScreen, etc. opened via `Navigator.push(MaterialPageRoute(...))` – correct (no need for global route names).
- **Fixed:** Discover screen “Check now” used literal `'/notifications'`; now uses `NotificationsScreen.routeName` and import for consistency.

### 3.4 Socket (SocketService)

- Connect with userId, join conversation, listen `new:message`, `typing:indicator`.
- Send message: full message object after API success; typing:start/stop include `userId`. Backend now sends `conversationId` in typing payload so Flutter can route typing to the right conversation.

### 3.5 Chat screen

- Sender detection uses `senderId` (object or string) so “me” vs “other” alignment is correct.
- Send flow: API first, then socket broadcast; backend also emits on message create.
- Image messages: local file vs network URL with base URL for backend paths; errorBuilder for broken images.

### 3.6 Gaps / follow-ups

| Item | Status |
|------|--------|
| API base URL | Confirm production domain (rewardo.fun vs silah-specific) |
| Delete profile | Delete profile dialog exists; ensure backend `delete-account` and any profile cleanup are sufficient |
| Deep links / notification routes | “Route not found” from notifications often due to wrong base URL or old build; ensure notification payload uses correct route names and backend URL |

---

## 4. Fixes applied in this audit

1. **Backend – message.controller.ts**  
   - Import `io` from `../server`.  
   - After creating and populating a message, emit `new:message` to `conversation:${convId}` with the message object (including `conversationId`) so all participants get it in real time.

2. **Backend – server.ts**  
   - `typing:indicator` payload now includes `conversationId` (in addition to `userId`, `isTyping`) so Flutter can route typing to the correct conversation stream.

3. **Flutter – discover_screen.dart**  
   - Replaced literal `'/notifications'` with `NotificationsScreen.routeName` and added import for `notifications_screen.dart`.

---

## 5. Summary

| Layer | Status | Notes |
|-------|--------|--------|
| Backend | Aligned | Socket emit on message create + typing payload fix. FCM sending still pending. |
| Admin Dashboard | Aligned | Services and routes match backend; confirm API base URL for Silah. |
| Flutter | Aligned | APIs and routes match backend; notification route and socket behaviour fixed. |

No structural gaps found between backend, admin, and Flutter; the main follow-ups are FCM push sending, confirming production API domain, and any optional IP logging on profile completion.
