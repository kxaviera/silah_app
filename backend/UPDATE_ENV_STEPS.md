# Quick Steps to Update .env File

## 🚀 Quick Start (Minimum Required)

### Step 1: Generate JWT Secrets

I've generated secure secrets for you. Copy these values:

**JWT_SECRET:** (Generated below - copy from terminal output)
**ADMIN_JWT_SECRET:** (Generated below - copy from terminal output)

### Step 2: Open .env File

Open: `D:\Silah\Backend\.env` in your text editor

### Step 3: Update Minimum Required Values

Replace these lines in your `.env` file:

```env
# Replace this:
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# With your generated secret (copy from terminal)
JWT_SECRET=paste-generated-secret-here
```

```env
# Replace this:
ADMIN_JWT_SECRET=your-super-secret-admin-jwt-key-change-this-in-production

# With your generated secret (copy from terminal)
ADMIN_JWT_SECRET=paste-generated-secret-here
```

### Step 4: Configure MongoDB

**Option A: Local MongoDB (if installed locally)**
```env
MONGODB_URI=mongodb://localhost:27017/silah
```

**Option B: MongoDB Atlas (Cloud - Recommended)**
1. Go to https://www.mongodb.com/cloud/atlas
2. Sign up (free tier available)
3. Create a cluster
4. Click "Connect" → "Connect your application"
5. Copy the connection string
6. Replace `<password>` with your password
7. Replace `<dbname>` with `silah`

Example:
```env
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/silah?retryWrites=true&w=majority
```

### Step 5: Test Configuration

```bash
cd D:\Silah\Backend
npm run dev
```

You should see:
```
✅ MongoDB Connected
🚀 Server running on port 5000
```

---

## 📋 Complete Configuration Guide

For detailed instructions on all optional services (Google OAuth, Stripe, SendGrid, Twilio, etc.), see:
- `ENV_CONFIGURATION_GUIDE.md` - Complete step-by-step guide

---

## ✅ What You Need Right Now

**Minimum to get started:**
1. ✅ JWT_SECRET (generated below)
2. ✅ ADMIN_JWT_SECRET (generated below)
3. ⚠️ MONGODB_URI (you need to set this up)

**Everything else is optional** and can be added later.

---

## 🔒 Security Note

- Never share these secrets
- Use different secrets for production
- The `.env` file is already in `.gitignore` (won't be committed)
