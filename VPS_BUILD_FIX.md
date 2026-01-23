# Quick Fix for VPS Build Error

The deployment script was using `npm install --production` which skips dev dependencies needed for TypeScript compilation.

## Immediate Fix on VPS

Run this command on your VPS to fix the build:

```bash
cd /var/www/silah_app/backend
npm install
npm run build
pm2 restart silah-backend
```

## Or Pull Latest Code (Includes Fix)

```bash
cd /var/www/silah_app
git pull origin main
cd backend
npm install
npm run build
pm2 restart silah-backend
```

The deployment script has been updated to install all dependencies (including dev dependencies) so TypeScript can build properly.
