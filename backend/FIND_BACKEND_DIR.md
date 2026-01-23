# Find Backend Directory and Rebuild

## 🔍 Issue

You're not in the correct directory. Let's find where the backend is located.

---

## ✅ Solution: Find and Navigate to Backend

```bash
# Find the backend directory
find /var/www -name "package.json" -path "*/backend/*" 2>/dev/null

# Or check common locations
ls -la /var/www/silah_app/backend/ 2>/dev/null || echo "Not found"
ls -la /var/www/backend/ 2>/dev/null || echo "Not found"

# Once you find it, navigate there
cd /path/to/backend

# Pull latest changes
git pull origin main

# Rebuild TypeScript
npm run build

# Restart backend
pm2 restart silah-backend

# Check logs
pm2 logs silah-backend --lines 50
```

---

## 🔄 Alternative: Check PM2 to Find the Path

```bash
# Check PM2 process details to see where it's running from
pm2 describe silah-backend

# This will show the script path, which tells you where the backend is
```

---

**Run the find command first to locate the backend directory!**
