# Backend .env Setup Checklist

Your `.env` file has been created from `.env.example`. Edit `backend/.env` and fill in the values below.

---

## Required (must set)

| Variable | Example | Where to get it |
|----------|---------|-----------------|
| `MONGODB_URI` | `mongodb://localhost:27017/silah` or Atlas connection string | Local MongoDB or [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) |
| `JWT_SECRET` | Long random string (min 32 chars) | Generate: see below |
| `ADMIN_JWT_SECRET` | Long random string (min 32 chars) | Generate: see below |

**Generate JWT secrets (PowerShell):**
```powershell
# Run twice to get two different values
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

---

## Recommended for production

| Variable | Example | Notes |
|----------|---------|--------|
| `FRONTEND_URL` | `https://api.rewardo.fun` or your API domain | Used for CORS and links in emails |
| `NODE_ENV` | `production` | Set to `production` on server |
| `PORT` | `5000` | Port the backend listens on |

---

## Optional (enable when you use the feature)

| Feature | Variables | Notes |
|---------|-----------|--------|
| **Google Sign-In** | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` | [Google Cloud Console](https://console.cloud.google.com) → Credentials |
| **Stripe payments** | `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET` | [Stripe Dashboard](https://dashboard.stripe.com/apikeys) |
| **Email (SendGrid)** | `SENDGRID_API_KEY`, `SENDGRID_FROM_EMAIL` | [SendGrid](https://sendgrid.com) → API Keys |
| **SMS (Twilio)** | `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER` | [Twilio Console](https://console.twilio.com) |
| **Firebase (FCM push)** | `GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json` **or** `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` | [Firebase Console](https://console.firebase.google.com) → Project settings → Service accounts → Generate key |
| **File upload** | Cloudinary: `CLOUDINARY_*` **or** AWS: `AWS_*` | Only if you use cloud uploads |
| **Company (invoices)** | `COMPANY_NAME`, `COMPANY_GSTIN`, etc. | For PDF invoices |
| **Socket.io** | `SOCKET_IO_CORS_ORIGIN` | Usually same as frontend URL |

---

## Commands after editing .env

```powershell
cd d:\Silah\SIlah\backend
npm install
npm run dev
```

If MongoDB is running and `MONGODB_URI`, `JWT_SECRET`, and `ADMIN_JWT_SECRET` are set, the server should start.
