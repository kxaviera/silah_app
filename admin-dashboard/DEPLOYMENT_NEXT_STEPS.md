# Admin Dashboard Deployment - Next Steps

## ✅ Nginx Status: Active and Running

Your Nginx is running successfully! Now complete the deployment.

---

## 🚀 Next Steps

### Step 1: Build Admin Dashboard

```bash
cd /var/www/silah_app/admin-dashboard
npm install
npm run build
```

**This creates the `dist/` folder that Nginx will serve.**

---

### Step 2: Verify Build Output

```bash
ls -la /var/www/silah_app/admin-dashboard/dist/
```

**Should show:**
- `index.html`
- `assets/` folder
- Other build files

---

### Step 3: Set Correct Permissions (if needed)

```bash
sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist
sudo chmod -R 755 /var/www/silah_app/admin-dashboard/dist
```

---

### Step 4: Configure DNS

**In your domain DNS settings, add:**

- **Type:** A Record
- **Name:** `admin`
- **Value:** `88.222.241.43` (or your VPS IP)
- **TTL:** 3600

**This creates:** `admin.rewardo.fun` → Your VPS IP

---

### Step 5: Wait for DNS Propagation

DNS changes can take a few minutes to hours. Check:

```bash
# Check if DNS is resolving
nslookup admin.rewardo.fun
# or
dig admin.rewardo.fun
```

---

### Step 6: Install SSL Certificate

**After DNS is configured:**

```bash
sudo certbot --nginx -d admin.rewardo.fun
```

**This will:**
- Get SSL certificate from Let's Encrypt
- Automatically update Nginx config for HTTPS
- Set up auto-renewal

---

### Step 7: Test Admin Dashboard

**Visit in browser:**
- `http://admin.rewardo.fun` (before SSL)
- `https://admin.rewardo.fun` (after SSL)

---

## 📋 Complete Deployment Checklist

- [x] Nginx config created
- [x] Nginx config test passed
- [x] Nginx reloaded successfully
- [ ] Admin dashboard built (`npm run build`)
- [ ] Build output verified (`dist/` folder exists)
- [ ] File permissions set correctly
- [ ] DNS configured (A record for `admin.rewardo.fun`)
- [ ] DNS propagation verified
- [ ] SSL certificate installed
- [ ] Admin dashboard accessible in browser

---

## 🔍 Troubleshooting

### If admin dashboard shows 404 or blank page:

1. **Check if dist folder exists:**
   ```bash
   ls -la /var/www/silah_app/admin-dashboard/dist/
   ```

2. **Check Nginx error logs:**
   ```bash
   sudo tail -f /var/log/nginx/admin.rewardo.fun.error.log
   ```

3. **Check file permissions:**
   ```bash
   ls -la /var/www/silah_app/admin-dashboard/dist/index.html
   ```

4. **Verify Nginx is reading correct directory:**
   ```bash
   sudo nginx -T | grep -A 5 "admin.rewardo.fun"
   ```

---

## ✅ Quick Commands Summary

```bash
# 1. Build admin dashboard
cd /var/www/silah_app/admin-dashboard
npm install
npm run build

# 2. Set permissions
sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist

# 3. Verify build
ls -la /var/www/silah_app/admin-dashboard/dist/

# 4. After DNS configured, install SSL
sudo certbot --nginx -d admin.rewardo.fun
```

---

**Last Updated:** 2025-01-22
