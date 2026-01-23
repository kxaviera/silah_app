# Backend Deployment - Quick Status Check

## ✅ Already Done

- ✅ Backend code exists (`/var/www/silah_app/backend/`)
- ✅ Dependencies installed (`node_modules/` exists)
- ✅ `.env` file exists (created Jan 22 21:21)

---

## 🔍 Next: Check Current Status

Run these commands to see what's already configured:

```bash
cd /var/www/silah_app/backend

# 1. Check if .env has required values (don't show secrets!)
head -n 15 .env | grep -E "JWT_SECRET|MONGODB_URI|PORT|NODE_ENV"

# 2. Check if TypeScript is built
ls -la dist/

# 3. Check if uploads directory exists
ls -la uploads/

# 4. Check if PM2 is installed
pm2 --version

# 5. Check if backend is already running
pm2 list | grep silah-backend
```

---

## 📋 Continue with Next Steps

Based on what you find, continue with:

### If `dist/` folder doesn't exist:
```bash
npm run build
```

### If `uploads/` folder doesn't exist:
```bash
mkdir -p uploads/profile-photos
chmod -R 755 uploads
```

### If PM2 not installed:
```bash
sudo npm install -g pm2
```

### If backend not running:
```bash
pm2 start dist/server.js --name silah-backend
pm2 save
pm2 startup  # Run the command it shows
```

### Check MongoDB:
```bash
sudo systemctl status mongodb
```

---

**Run the status check commands above and share the output!**
