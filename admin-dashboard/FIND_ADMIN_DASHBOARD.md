# Find Admin Dashboard Directory on VPS

## Step 1: Find the admin dashboard directory

Run these commands to locate it:

```bash
# Check if admin-dashboard exists in common locations
ls -la /var/www/silah_app/admin-dashboard 2>/dev/null || echo "Not in /var/www/silah_app/admin-dashboard"

# Or search for it
find /var/www -name "admin-dashboard" -type d 2>/dev/null

# Or check the git repository location
cd /var/www/silah_app && ls -la
```

## Step 2: Once you find it, navigate and build

```bash
# Replace <path> with the actual path you found
cd <path>/admin-dashboard
npm run build
```

## Step 3: Alternative - Check current directory structure

```bash
# See what's in /var/www/silah_app
cd /var/www/silah_app
ls -la

# Check if admin-dashboard is directly here
ls -la admin-dashboard

# Or check if it's in a different location
find /var/www -name "package.json" -path "*/admin-dashboard/*" 2>/dev/null
```

---

## Common Locations to Check:

1. `/var/www/silah_app/admin-dashboard`
2. `/var/www/admin-dashboard`
3. `/root/silah_app/admin-dashboard`
4. Check where you cloned the git repo

---

## If admin-dashboard doesn't exist:

You may need to pull the latest code from git:

```bash
cd /var/www/silah_app
git pull origin main
ls -la admin-dashboard
```
