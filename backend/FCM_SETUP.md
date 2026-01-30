# FCM (Firebase Cloud Messaging) Setup in Backend

The backend can send push notifications to the Silah app when:
- **New message** – receiver gets a push
- **New contact request** – recipient gets a push
- **Request accepted** – sender gets a push
- **Request rejected** – sender gets a push

---

## 1. Prerequisites

- Firebase project (e.g. **silah-app-e0bb8**) with the Android/iOS app (e.g. `com.silah.app`) added
- Flutter app already registers FCM tokens via `POST /api/notifications/register-token`

---

## 2. Backend: Configure Firebase Admin

Use **one** of these in your backend `.env`.

### Option A: Service account JSON file (recommended)

1. [Firebase Console](https://console.firebase.google.com) → your project → **Project settings** (gear) → **Service accounts**
2. Click **Generate new private key**
3. Save the JSON file (e.g. `firebase-service-account.json`)
4. Upload it to the server, e.g. `/var/www/silah_app/backend/firebase-service-account.json`
5. In `.env`:

```env
GOOGLE_APPLICATION_CREDENTIALS=/var/www/silah_app/backend/firebase-service-account.json
```

**Security:** Add to `.gitignore` and never commit this file.

### Option B: Env vars only (no file)

From the same service account JSON, set in `.env`:

```env
FIREBASE_PROJECT_ID=silah-app-e0bb8
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@silah-app-e0bb8.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_KEY_LINES_HERE\n-----END PRIVATE KEY-----\n"
```

- Use your real **project_id** and **client_email** from the JSON.
- For **FIREBASE_PRIVATE_KEY**: paste the full `private_key` value as **one line**, with `\n` where there are newlines (no real line breaks in the env value).

---

## 3. Install and run backend

```bash
cd /var/www/silah_app/backend
npm install
npm run build
pm2 restart all
```

---

## 4. Verify

- If FCM is initialized, logs on startup show: `FCM: Initialized with ...`
- If env is missing, FCM is skipped and the server still runs; tokens are stored but no push is sent.
- Send a test message or contact request from another account; the target user should get a push when the app is in background/closed (if the app is configured for background FCM).

---

## 5. Code reference

- **Service:** `src/services/fcm.service.ts` – initializes Firebase Admin and sends to user tokens
- **Triggers:** `message.controller.ts` (new message), `request.controller.ts` (new request, accept, reject)
