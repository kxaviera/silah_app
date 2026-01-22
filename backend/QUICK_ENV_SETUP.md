# Quick .env Setup for VPS

## Step 1: Generate JWT Secrets

Run these commands on your VPS to generate secure random strings:

```bash
# Generate JWT Secret (for users)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Generate Admin JWT Secret (for admin dashboard)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**Copy both outputs** - you'll need them for the .env file.

---

## Step 2: Create .env File

```bash
cd /var/www/silah_app/backend
nano .env
```

---

## Step 3: Copy This Template

Paste this into your `.env` file and fill in the values:

```env
# ============================================
# SERVER CONFIGURATION
# ============================================
NODE_ENV=production
PORT=5000
API_URL=https://api.rewardo.fun

# ============================================
# MONGODB DATABASE
# ============================================
MONGODB_URI=mongodb://localhost:27017/silah

# ============================================
# JWT AUTHENTICATION (User Tokens)
# ============================================
# Paste the FIRST generated secret here
JWT_SECRET=PASTE_FIRST_GENERATED_SECRET_HERE
JWT_EXPIRES_IN=7d

# ============================================
# ADMIN JWT AUTHENTICATION
# ============================================
# Paste the SECOND generated secret here
ADMIN_JWT_SECRET=PASTE_SECOND_GENERATED_SECRET_HERE
ADMIN_JWT_EXPIRE=24h

# ============================================
# GOOGLE OAUTH (Optional - leave empty if not using)
# ============================================
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# ============================================
# STRIPE PAYMENT (Optional - leave empty if not using)
# ============================================
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=

# ============================================
# SENDGRID EMAIL (Optional - leave empty if not using)
# ============================================
SENDGRID_API_KEY=
SENDGRID_FROM_EMAIL=noreply@rewardo.fun

# ============================================
# TWILIO SMS (Optional - leave empty if not using)
# ============================================
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=

# ============================================
# FIREBASE (Optional - leave empty if not using)
# ============================================
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=

# ============================================
# FILE UPLOAD
# ============================================
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880

# ============================================
# CORS CONFIGURATION
# ============================================
CORS_ORIGIN=https://admin.rewardo.fun,https://api.rewardo.fun
FRONTEND_URL=https://admin.rewardo.fun

# ============================================
# ADMIN DEFAULT CREDENTIALS
# ============================================
ADMIN_DEFAULT_EMAIL=admin@rewardo.fun
ADMIN_DEFAULT_PASSWORD=ChangeThisPassword123!
```

---

## Step 4: Minimum Required Values

**For basic functionality, you MUST fill these:**

1. ✅ `JWT_SECRET` - Generate and paste
2. ✅ `ADMIN_JWT_SECRET` - Generate and paste
3. ✅ `MONGODB_URI` - Usually `mongodb://localhost:27017/silah`
4. ✅ `ADMIN_DEFAULT_EMAIL` - Your admin email
5. ✅ `ADMIN_DEFAULT_PASSWORD` - Your admin password (change it!)

**Optional (can leave empty for now):**
- Google OAuth
- Stripe
- SendGrid
- Twilio
- Firebase

---

## Step 5: Save and Exit

- Press `Ctrl+X`
- Press `Y` to confirm
- Press `Enter` to save

---

## Step 6: Verify

```bash
# Check if .env file exists
ls -la .env

# View first few lines (don't show secrets!)
head -n 10 .env
```

---

## Example .env (Minimal Setup)

```env
NODE_ENV=production
PORT=5000
API_URL=https://api.rewardo.fun
MONGODB_URI=mongodb://localhost:27017/silah
JWT_SECRET=abc123def456ghi789jkl012mno345pqr678stu901vwx234yz567abc890def123ghi456jkl789mno012pqr345stu678
JWT_EXPIRES_IN=7d
ADMIN_JWT_SECRET=xyz789abc012def345ghi678jkl901mno234pqr567stu890vwx123yz456abc789def012ghi345jkl678mno901pqr234
ADMIN_JWT_EXPIRE=24h
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880
CORS_ORIGIN=https://admin.rewardo.fun,https://api.rewardo.fun
FRONTEND_URL=https://admin.rewardo.fun
ADMIN_DEFAULT_EMAIL=admin@rewardo.fun
ADMIN_DEFAULT_PASSWORD=SecurePassword123!
```

---

## ⚠️ Security Notes

1. **NEVER commit .env to git** - It's in .gitignore
2. **Change admin password** after first login
3. **Keep secrets secure** - Don't share them
4. **Use strong passwords** - At least 12 characters

---

**Ready to deploy!** After creating .env, continue with:
```bash
npm run build
pm2 start dist/server.js --name silah-backend
```
