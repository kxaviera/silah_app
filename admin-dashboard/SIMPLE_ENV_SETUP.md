# Admin Dashboard .env File - Simple Setup

## ✅ Only ONE URL Needed!

The admin dashboard `.env` file only needs **ONE** environment variable:

```env
VITE_API_URL=https://api.rewardo.fun/api
```

---

## 🔍 Why Only One?

The admin dashboard automatically constructs the admin API URL from the base URL:

**In `src/services/api.ts`:**
```typescript
const API_URL = import.meta.env.VITE_API_URL || 'https://api.rewardo.fun/api';
const ADMIN_BASE = API_URL.replace(/\/api\/?$/, '') + '/api/admin';
```

So when you set:
- `VITE_API_URL=https://api.rewardo.fun/api`

It automatically creates:
- **Base API:** `https://api.rewardo.fun/api`
- **Admin API:** `https://api.rewardo.fun/api/admin` (auto-generated)

---

## 📝 Complete .env File Content

**That's it! Just this one line:**

```env
VITE_API_URL=https://api.rewardo.fun/api
```

---

## ✅ Quick Setup

```bash
cd /var/www/silah_app/admin-dashboard
nano .env
```

**Paste this:**
```env
VITE_API_URL=https://api.rewardo.fun/api
```

**Save:** `Ctrl+X`, `Y`, `Enter`

---

## 🎯 Summary

- ✅ **Only 1 variable needed:** `VITE_API_URL`
- ✅ **Only 1 URL needed:** `https://api.rewardo.fun/api`
- ✅ **Admin API URL is auto-generated** from the base URL

**That's all!** No need for a second URL.

---

**Last Updated:** 2025-01-22
