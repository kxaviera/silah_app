# Admin Dashboard - Environment Variables Setup

## 📋 Quick Setup for VPS

### Step 1: Navigate to Admin Dashboard Directory

```bash
cd /var/www/silah_app/admin-dashboard
```

---

### Step 2: Create .env File

```bash
nano .env
```

---

### Step 3: Add This Content

**For Production (VPS):**

```env
VITE_API_URL=https://api.rewardo.fun/api
```

**For Development (Local):**

```env
VITE_API_URL=http://localhost:5000/api
```

---

## ✅ Complete .env File Content

**Copy and paste this into your `.env` file:**

```env
# ============================================
# Admin Dashboard - Environment Variables
# ============================================

# Backend API URL
# Production: https://api.rewardo.fun/api
# Development: http://localhost:5000/api
VITE_API_URL=https://api.rewardo.fun/api
```

---

## 📝 Explanation

- **`VITE_API_URL`** - This is the only required variable
- **Prefix `VITE_`** - Required for Vite to expose the variable to the frontend
- **Value** - Points to your backend API URL

---

## 🔍 Verify Setup

After creating `.env`:

```bash
# Check if file exists
ls -la .env

# View content (should show VITE_API_URL)
cat .env
```

---

## 🚀 Build with Environment Variables

After setting up `.env`:

```bash
# Build for production
npm run build

# The build will use VITE_API_URL from .env
# Output will be in dist/ folder
```

---

## ⚠️ Important Notes

1. **File name:** Must be `.env` (not `.env.production` or `.env.development`)
2. **Variable prefix:** Must start with `VITE_` for Vite to expose it
3. **No quotes:** Don't use quotes around the URL value
4. **No spaces:** No spaces around the `=` sign

---

## ✅ Example .env File

**Production (VPS):**
```env
VITE_API_URL=https://api.rewardo.fun/api
```

**Development (Local):**
```env
VITE_API_URL=http://localhost:5000/api
```

---

## 🔧 How It Works

The admin dashboard uses this in `src/services/api.ts`:

```typescript
const API_URL = import.meta.env.VITE_API_URL || 'https://api.rewardo.fun/api';
const ADMIN_BASE = API_URL.replace(/\/api\/?$/, '') + '/api/admin';
```

So when you set `VITE_API_URL=https://api.rewardo.fun/api`, the admin dashboard will connect to:
- **API Base:** `https://api.rewardo.fun/api`
- **Admin API:** `https://api.rewardo.fun/api/admin`

---

## 📋 Quick Commands

```bash
# Navigate to admin dashboard
cd /var/www/silah_app/admin-dashboard

# Create .env file
nano .env

# Paste this line:
VITE_API_URL=https://api.rewardo.fun/api

# Save (Ctrl+X, Y, Enter)

# Verify
cat .env

# Build
npm run build
```

---

## ✅ That's It!

Only **ONE** environment variable is needed for the admin dashboard:
- `VITE_API_URL=https://api.rewardo.fun/api`

After creating `.env`, you can build and deploy the admin dashboard.

---

**Last Updated:** 2025-01-22
