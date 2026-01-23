# Fix Admin Dashboard Login Issues

## Issue 1: Test Mode Still Showing

The admin dashboard needs to be rebuilt with the latest changes (test mode removed).

## Step 1: Pull Latest Code

```bash
cd /var/www/silah_app
git pull origin main
```

## Step 2: Rebuild Admin Dashboard

```bash
cd /var/www/silah_app/admin-dashboard
npm run build
sudo chown -R www-data:www-data dist
sudo systemctl reload nginx
```

## Issue 2: Invalid Credentials

## Step 3: Check/Create Admin User

```bash
cd /var/www/silah_app/backend

# Check if admin exists
npm run create-admin

# If it says "Admin user already exists", check the email shown
# Then check your .env file for the password:
cat .env | grep ADMIN
```

## Step 4: Verify Admin User in Database

If you want to check directly in MongoDB:

```bash
# Connect to MongoDB
mongosh

# Switch to your database (replace with your actual database name)
use silah

# Check admin users
db.adminusers.find().pretty()

# Exit MongoDB
exit
```

## Step 5: Create New Admin (if needed)

If admin doesn't exist or you want to create a new one:

```bash
cd /var/www/silah_app/backend

# Set custom credentials (optional)
export ADMIN_EMAIL=admin@rewardo.fun
export ADMIN_PASSWORD=YourSecurePassword123
export ADMIN_NAME=Admin User

# Create admin
npm run create-admin
```

---

## Quick Fix Commands (All in One)

```bash
# 1. Pull latest code
cd /var/www/silah_app && git pull origin main

# 2. Rebuild admin dashboard
cd admin-dashboard && npm run build && sudo chown -R www-data:www-data dist && sudo systemctl reload nginx

# 3. Create/check admin user
cd ../backend && npm run create-admin
```

---

## After Running These Commands

1. **Test Mode should be gone** from the login page
2. **Use the credentials** shown by `create-admin` script
3. **Login at:** https://admin.rewardo.fun

---

## If Still Having Issues

Share the output of:
```bash
cd /var/www/silah_app/backend && npm run create-admin
```

This will show if admin exists and what email it's using.
