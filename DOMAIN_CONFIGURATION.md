# Domain Configuration - rewardo.fun

**Date:** 2025-01-22  
**Status:** ✅ **DOMAINS CONFIGURED**

---

## 🌐 Domain Names

- **Backend API:** `https://api.rewardo.fun`
- **Admin Dashboard:** `https://admin.rewardo.fun`
- **Flutter App:** Uses `api.rewardo.fun` for API calls

---

## ✅ Configuration Updates

### 1. Flutter App (`lib/core/app_config.dart`)

**Production URL:**
```dart
case 'production':
  return 'https://api.rewardo.fun/api';
```

**Status:** ✅ Updated

---

### 2. Admin Dashboard (`admin-dashboard/src/services/api.ts`)

**Default URL:**
```typescript
const API_URL = import.meta.env.VITE_API_URL || 'https://api.rewardo.fun/api';
```

**Status:** ✅ Updated

**Environment Files:**
- ✅ `.env.production` - `VITE_API_URL=https://api.rewardo.fun/api`
- ✅ `.env.development` - `VITE_API_URL=http://localhost:5000/api`

---

## 🔧 Backend Configuration

### CORS Settings

Update backend `.env` file:
```env
CORS_ORIGIN=https://admin.rewardo.fun,https://api.rewardo.fun
FRONTEND_URL=https://admin.rewardo.fun
```

### Nginx Configuration (if using)

**Backend API Server:**
```nginx
server {
    listen 80;
    server_name api.rewardo.fun;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**Admin Dashboard Server:**
```nginx
server {
    listen 80;
    server_name admin.rewardo.fun;

    root /var/www/admin-dashboard/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 🔒 SSL/HTTPS Setup

### Using Certbot (Let's Encrypt)

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Get SSL certificates
sudo certbot --nginx -d api.rewardo.fun
sudo certbot --nginx -d admin.rewardo.fun

# Auto-renewal
sudo certbot renew --dry-run
```

---

## 📱 Flutter App Build

### Production Build

```bash
# Android
flutter build apk --release --dart-define=ENV=production

# iOS
flutter build ios --release --dart-define=ENV=production
```

The app will automatically use `https://api.rewardo.fun/api` when built with `ENV=production`.

---

## 🌐 Admin Dashboard Build

### Production Build

```bash
cd admin-dashboard
npm install
npm run build
```

The build will use `.env.production` which points to `https://api.rewardo.fun/api`.

### Deploy

```bash
# Copy dist/ folder to web server
# Or use Vite preview for testing
npm run preview
```

---

## ✅ Verification Checklist

- [x] Flutter app configured with `api.rewardo.fun`
- [x] Admin dashboard configured with `api.rewardo.fun`
- [x] Environment files created
- [ ] Backend CORS updated
- [ ] Nginx configured (if using)
- [ ] SSL certificates installed
- [ ] DNS records configured
- [ ] Production build tested

---

## 📝 DNS Configuration

### Required DNS Records

1. **A Record for `api.rewardo.fun`**
   - Type: A
   - Name: api
   - Value: `88.222.241.43` (or your VPS IP)
   - TTL: 3600

2. **A Record for `admin.rewardo.fun`**
   - Type: A
   - Name: admin
   - Value: `88.222.241.43` (or your VPS IP)
   - TTL: 3600

---

## 🚀 Deployment Steps

1. **Update DNS Records** (if not already done)
2. **Update Backend CORS** in `.env` file
3. **Configure Nginx** (if using)
4. **Install SSL Certificates** with Certbot
5. **Build Flutter App** with production environment
6. **Build Admin Dashboard** with production environment
7. **Deploy Admin Dashboard** to web server
8. **Test All Endpoints** to verify connectivity

---

## 🔍 Testing

### Test Backend API
```bash
curl https://api.rewardo.fun/health
```

### Test Admin Dashboard
```bash
# Open in browser
https://admin.rewardo.fun
```

### Test Flutter App
- Build with production environment
- Install on device
- Verify API calls work

---

**Last Updated:** 2025-01-22  
**Status:** ✅ **CONFIGURATION COMPLETE**
