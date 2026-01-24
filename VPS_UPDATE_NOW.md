# VPS Update - Step by Step Commands

## Connect to Your VPS

```bash
ssh root@88.222.241.43
```

## Update Commands (Run These One by One)

### Step 1: Navigate to Project Directory
```bash
cd /var/www/silah_app
```

### Step 2: Pull Latest Code
```bash
git pull origin main
```

### Step 3: Update Backend
```bash
cd backend
npm install
npm run build
pm2 restart silah-backend
```

### Step 4: Check Backend Status
```bash
pm2 status
pm2 logs silah-backend --lines 20
```

### Step 5: Update Admin Dashboard
```bash
cd ../admin-dashboard
npm install
npm run build
sudo chown -R www-data:www-data dist
sudo systemctl reload nginx
```

### Step 6: Verify Everything
```bash
# Check backend health
curl https://api.rewardo.fun/health

# Check admin dashboard
curl -I https://admin.rewardo.fun

# Check PM2 status
pm2 status
```

## If You Get Errors

### Backend Build Fails:
```bash
cd /var/www/silah_app/backend
rm -rf node_modules package-lock.json
npm install
npm run build
pm2 restart silah-backend
```

### Admin Dashboard Build Fails:
```bash
cd /var/www/silah_app/admin-dashboard
rm -rf node_modules package-lock.json dist
npm install
npm run build
sudo chown -R www-data:www-data dist
sudo systemctl reload nginx
```

### MongoDB Connection Issues:
```bash
sudo systemctl status mongod
sudo systemctl restart mongod
```

## Quick One-Liner (If Everything Works)
```bash
cd /var/www/silah_app && git pull origin main && cd backend && npm install && npm run build && pm2 restart silah-backend && cd ../admin-dashboard && npm install && npm run build && sudo chown -R www-data:www-data dist && sudo systemctl reload nginx
```
