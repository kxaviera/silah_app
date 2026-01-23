# VPS Update Commands - Complete Verification System

## Quick Update Commands

Run these commands on your VPS server to update everything:

```bash
# 1. Navigate to project directory
cd /var/www/silah_app

# 2. Pull latest code
git pull origin main

# 3. Update Backend
cd backend
npm install
npm run build
pm2 restart silah-backend

# 4. Update Admin Dashboard
cd ../admin-dashboard
npm install
npm run build
sudo chown -R www-data:www-data dist
sudo systemctl reload nginx

# 5. Verify services are running
pm2 status
sudo systemctl status nginx
```

## Detailed Step-by-Step Update

### Step 1: Update Backend

```bash
cd /var/www/silah_app/backend

# Pull latest code
git pull origin main

# Install any new dependencies
npm install

# Rebuild TypeScript
npm run build

# Restart backend with PM2
pm2 restart silah-backend

# Check logs for any errors
pm2 logs silah-backend --lines 50
```

### Step 2: Update Admin Dashboard

```bash
cd /var/www/silah_app/admin-dashboard

# Pull latest code
git pull origin main

# Install any new dependencies
npm install

# Build production version
npm run build

# Set correct permissions
sudo chown -R www-data:www-data dist

# Reload Nginx
sudo systemctl reload nginx

# Verify build output
ls -la dist/
```

### Step 3: Verify Everything is Working

```bash
# Check backend is running
pm2 status
curl https://api.rewardo.fun/health

# Check admin dashboard is accessible
curl -I https://admin.rewardo.fun

# Check backend logs for errors
pm2 logs silah-backend --lines 100

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

## What Changed in This Update

### Backend Changes:
1. ✅ User verification system (`isVerified`, `verifiedAt`, `verifiedBy`, `verificationNotes`)
2. ✅ Boost activation requires verification
3. ✅ Contact requests require verification (both sender and receiver)
4. ✅ Profile completion sets `isVerified: false` (Under Review status)
5. ✅ Admin endpoints for verify/reject users with notes

### Admin Dashboard Changes:
1. ✅ Enhanced UserDetail page with complete profile information
2. ✅ Verify/Reject dialogs with notes
3. ✅ Verification status display in user list

### Flutter App Changes:
1. ✅ Verification status badges (Under Review/Verified/Rejected)
2. ✅ Boost button checks verification before allowing boost
3. ✅ Contact request button checks verification
4. ✅ Verified badge on profile cards
5. ✅ Removed "tap anywhere" from splash screen (production mode)

## Troubleshooting

### If backend fails to start:
```bash
# Check TypeScript compilation errors
cd /var/www/silah_app/backend
npm run build

# Check PM2 logs
pm2 logs silah-backend

# Restart PM2
pm2 restart silah-backend
pm2 save
```

### If admin dashboard doesn't update:
```bash
# Clear browser cache (Ctrl+Shift+Delete)
# Or hard refresh (Ctrl+F5)

# Rebuild admin dashboard
cd /var/www/silah_app/admin-dashboard
rm -rf dist node_modules
npm install
npm run build
sudo chown -R www-data:www-data dist
sudo systemctl reload nginx
```

### If MongoDB connection fails:
```bash
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB if needed
sudo systemctl restart mongod

# Check backend .env file has correct MONGODB_URI
cd /var/www/silah_app/backend
cat .env | grep MONGODB_URI
```

## Post-Update Checklist

- [ ] Backend is running (check `pm2 status`)
- [ ] Admin dashboard loads (visit https://admin.rewardo.fun)
- [ ] Test user verification in admin dashboard
- [ ] Test boost activation requires verification
- [ ] Test contact requests require verification
- [ ] Check Flutter app shows verification badges correctly

## Rollback (if needed)

If something goes wrong, you can rollback:

```bash
cd /var/www/silah_app
git log --oneline -5  # Find previous commit hash
git reset --hard <previous-commit-hash>
cd backend && npm run build && pm2 restart silah-backend
cd ../admin-dashboard && npm run build && sudo systemctl reload nginx
```

---

**Last Updated:** $(date)
**Commit:** Latest from main branch
**Status:** ✅ Production Ready
