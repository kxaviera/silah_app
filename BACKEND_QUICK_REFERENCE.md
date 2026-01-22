# Silah Backend - Quick Reference Guide

## 🚀 Quick Start Checklist

### 1. Core Models (Priority Order)
1. ✅ **User** - Authentication, profile, boost status
2. ✅ **Transaction** - Payment records, invoices
3. ✅ **ContactRequest** - Privacy-controlled contact sharing
4. ✅ **Conversation** - Chat threads
5. ✅ **Message** - Individual messages
6. ✅ **ProfileView** - Analytics (views, likes, shortlists)
7. ✅ **Block** - User blocking
8. ✅ **Report** - User reporting
9. ✅ **PromoCode** - Discount codes

### 2. Critical API Endpoints (Must Have First)

#### Authentication
- `POST /api/auth/register` - User signup
- `POST /api/auth/login` - Email/password login
- `POST /api/auth/google` - Google Sign-In
- `GET /api/auth/me` - Get current user

#### Profile
- `PUT /api/profile/complete` - Complete profile after signup
- `POST /api/profile/photo` - Upload profile photo
- `GET /api/profile/search` - Search profiles (with filters)
- `GET /api/profile/:userId` - View profile detail

#### Boost
- `POST /api/boost/activate` - Activate boost after payment
- `GET /api/boost/status` - Get current boost status

#### App Settings
- `GET /api/settings` - Get public app settings (pricing, payment controls)

#### Payment
- `POST /api/payment/create-intent` - Create Stripe payment intent
- `POST /api/payment/verify` - Verify payment and activate boost
- `GET /api/payment/invoice/:invoiceNumber` - Get invoice

#### Requests
- `POST /api/requests` - Send contact request
- `GET /api/requests/received` - Get received requests
- `POST /api/requests/:id/accept` - Accept request
- `POST /api/requests/:id/reject` - Reject request

---

## 🔑 Key Business Rules

### 1. Role-Based Filtering
- **Brides** only see **Grooms** in search
- **Grooms** only see **Brides** in search
- Always filter by opposite role: `role !== currentUser.role`

### 2. Boost Visibility
- Only profiles with **active boost** appear in search:
  ```javascript
  boostStatus === 'active' && boostExpiresAt > new Date()
  ```
- Boost types (Role-Based Pricing):
  - **Standard** (3 days):
    - Bride: ₹199
    - Groom: ₹299
  - **Featured** (7 days):
    - Bride: ₹399
    - Groom: ₹599

### 3. Privacy Controls
- `hideMobile === true` → Don't return mobile in profile API
- `hidePhotos === true` → Don't return profilePhoto in profile API
- Mobile/photos only shared after contact request is **accepted**

### 4. Search Tabs Logic
- **"All"**: No country filter
- **"India"**: `livingCountry === 'India'` OR `(livingCountry is null AND country === 'India')`
- **"Abroad"**: `livingCountry !== 'India'` AND `livingCountry !== null`

### 5. Blocking
- Blocked users cannot:
  - See each other in search
  - Send messages
  - Send contact requests
- Filter blocked users in all queries

### 6. Payment Controls (Admin)
- **paymentEnabled**: Master switch for payment system
  - `true`: Payment required (users must pay to boost)
  - `false`: All boosts are free
- **allowFreePosting**: Allow users to skip payment
  - Only works when `paymentEnabled: true`
  - `true`: Users can choose to post for free
  - `false`: Payment is mandatory
- **Boost Options**: Can enable/disable per role
  - Each boost type (standard/featured) can be enabled/disabled for bride/groom separately
  - When disabled, option won't appear in UI

---

## 💰 Payment Flow

```
1. User selects boost type (Standard/Featured)
2. Frontend → POST /api/payment/create-intent
   → Backend creates Stripe PaymentIntent
   → Returns: { paymentIntentId, clientSecret, amount, gstAmount, totalAmount }
3. Frontend processes payment via Stripe SDK
4. On success → POST /api/payment/verify
   → Backend verifies payment with Stripe
   → Creates Transaction record
   → Activates boost (updates user.boostStatus, boostExpiresAt)
   → Returns invoice data
5. Frontend → Invoice Screen
```

### GST Calculation
- **Rate**: 18%
- **Formula**: `GST = (Amount - Discount) * 0.18`
- **Total**: `Amount - Discount + GST`

### Invoice Format
- **Number**: `INV-{timestamp}`
- **Date**: Payment completion date
- **GSTIN**: Required (configure in env)

---

## 📊 Analytics Endpoints

### Profile Analytics
```
GET /api/profile/me/analytics
Returns:
- totalViews
- totalLikes
- totalShortlisted
- totalRequests
```

### Recent Viewers
```
GET /api/profile/me/views
Returns:
- totalViews
- recentViews[] (with viewer name, time)
```

---

## 🔔 Real-time Events (Socket.io)

### Client → Server
- `join:user` - Join user room
- `send:message` - Send message
- `typing:start` - Start typing indicator
- `typing:stop` - Stop typing indicator

### Server → Client
- `new:message` - New message received
- `typing:indicator` - Other user typing
- `new:request` - New contact request
- `request:accepted` - Request accepted
- `request:rejected` - Request rejected

---

## 🗄️ Database Indexes (Critical)

```javascript
// Users - Search performance
db.users.createIndex({ role: 1, boostStatus: 1, boostExpiresAt: 1 })
db.users.createIndex({ country: 1, livingCountry: 1, state: 1, city: 1 })
db.users.createIndex({ religion: 1 })
db.users.createIndex({ "fullName": "text" })

// Requests - Fast retrieval
db.requests.createIndex({ toUserId: 1, status: 1, createdAt: -1 })
db.requests.createIndex({ fromUserId: 1, status: 1, createdAt: -1 })

// Messages - Chat performance
db.messages.createIndex({ conversationId: 1, createdAt: -1 })

// Blocks - Filter blocked users
db.blocks.createIndex({ blockerId: 1, blockedUserId: 1 }, { unique: true })
```

---

## 🛡️ Security Checklist

- [ ] JWT token validation on all protected routes
- [ ] Password hashing (bcrypt, salt rounds: 10)
- [ ] Input validation (email format, phone format, etc.)
- [ ] Rate limiting on auth endpoints
- [ ] CORS configuration
- [ ] File upload validation (size, type)
- [ ] SQL injection prevention (MongoDB is safe, but validate inputs)
- [ ] XSS prevention (sanitize user inputs)
- [ ] HTTPS in production
- [ ] Environment variables for secrets

---

## 📝 Environment Variables Template

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
GOOGLE_CLIENT_ID=xxx
GOOGLE_CLIENT_SECRET=xxx

# Stripe
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# File Upload (choose one)
# AWS S3
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_BUCKET_NAME=silah-uploads
AWS_REGION=ap-south-1

# OR Cloudinary
CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx

# Company (for invoices)
COMPANY_NAME=Silah Matrimony
COMPANY_GSTIN=29ABCDE1234F1Z5
COMPANY_EMAIL=support@silah.com
COMPANY_PHONE=+91-1234567890
```

---

## 🧪 Testing Priority

1. **Authentication** (Critical)
   - Register, Login, Google Sign-In
   - Token validation

2. **Profile Search** (Critical)
   - Role filtering
   - Boost filtering
   - All filter combinations

3. **Payment** (Critical)
   - Payment intent creation
   - Payment verification
   - Boost activation

4. **Contact Requests** (High)
   - Send, Accept, Reject
   - Privacy controls

5. **Messages** (High)
   - Send, Receive
   - Real-time delivery

---

## 🚨 Common Issues & Solutions

### Issue: Profiles not showing in search
**Check:**
- User has active boost? (`boostStatus === 'active' && boostExpiresAt > now`)
- Role filtering correct? (bride sees grooms, groom sees brides)
- User not blocked?

### Issue: Payment succeeds but boost not activated
**Check:**
- Webhook received? Check Stripe dashboard
- Transaction record created?
- User boostStatus updated?
- boostExpiresAt set correctly?

### Issue: Contact request not showing contact details
**Check:**
- Request status is 'accepted'?
- Request type includes 'mobile' or 'photos'?
- User's privacy settings (hideMobile, hidePhotos)?

### Issue: Messages not delivering in real-time
**Check:**
- Socket.io connection established?
- User joined correct room?
- Blocked users filtered?

---

## 📦 Dependencies Needed

```json
{
  "express": "^4.18.2",
  "mongoose": "^7.5.0",
  "jsonwebtoken": "^9.0.2",
  "bcryptjs": "^2.4.3",
  "dotenv": "^16.3.1",
  "cors": "^2.8.5",
  "helmet": "^7.0.0",
  "express-validator": "^7.0.1",
  "multer": "^1.4.5-lts.1",
  "stripe": "^13.0.0",
  "socket.io": "^4.6.1",
  "google-auth-library": "^8.8.0",
  "nodemailer": "^6.9.4"
}
```

---

## 🔐 Admin Dashboard

### Admin Authentication
- `POST /api/admin/auth/login` - Admin login
- `GET /api/admin/auth/me` - Get current admin

### Admin Endpoints (Priority)
1. **Dashboard Stats**
   - `GET /api/admin/dashboard/stats` - Overview statistics
   - `GET /api/admin/dashboard/revenue-chart` - Revenue trends

2. **User Management**
   - `GET /api/admin/users` - List users (with filters)
   - `GET /api/admin/users/:userId` - User details
   - `POST /api/admin/users/:userId/block` - Block user
   - `POST /api/admin/users/:userId/unblock` - Unblock user
   - `POST /api/admin/users/:userId/verify` - Verify user

3. **Reports Management**
   - `GET /api/admin/reports` - List reports (with filters)
   - `GET /api/admin/reports/:reportId` - Report details
   - `PUT /api/admin/reports/:reportId/review` - Review report

4. **Transactions**
   - `GET /api/admin/transactions` - List transactions
   - `GET /api/admin/transactions/:id` - Transaction details
   - `POST /api/admin/transactions/:id/refund` - Refund transaction

5. **Analytics**
   - `GET /api/admin/analytics/users` - User analytics
   - `GET /api/admin/analytics/revenue` - Revenue analytics
   - `GET /api/admin/analytics/engagement` - Engagement metrics

6. **Settings**
   - `GET /api/admin/settings` - Get all settings
   - `PUT /api/admin/settings/boost-pricing` - Update pricing, duration, enable/disable per role
   - `PUT /api/admin/settings/payment` - Enable/disable payment, allow free posting
   - `PUT /api/admin/settings/company` - Update company details

7. **Promo Codes**
   - `GET /api/admin/promo-codes` - List promo codes
   - `POST /api/admin/promo-codes` - Create promo code
   - `PUT /api/admin/promo-codes/:id` - Update promo code

### Admin Middleware
- `adminProtect` - Verify admin JWT token
- Check `req.admin.role` for super_admin permissions

---

## 🎯 MVP Scope (Minimum Viable Product)

### Must Have (Phase 1)
- ✅ User registration & login (email + Google)
- ✅ Profile completion
- ✅ Profile search with filters
- ✅ Boost activation (Standard/Featured)
- ✅ Payment integration (Stripe)
- ✅ Invoice generation
- ✅ Contact requests (send, accept, reject)
- ✅ Basic messaging (send, receive)
- ✅ Block/Report users

### Nice to Have (Phase 2)
- ⏳ Real-time messaging (Socket.io)
- ⏳ Typing indicators
- ⏳ Push notifications
- ⏳ Profile analytics dashboard
- ⏳ Promo codes
- ⏳ Email verification
- ⏳ Mobile OTP verification
- ⏳ Admin dashboard (web-based)

### Future (Phase 3)
- ⏳ ID verification
- ⏳ Match suggestions algorithm
- ⏳ Admin dashboard
- ⏳ Advanced analytics
- ⏳ Safety tutorial

---

**Last Updated**: 2024-01-15
