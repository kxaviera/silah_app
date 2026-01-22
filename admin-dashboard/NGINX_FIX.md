# Nginx Configuration for Admin Dashboard - CORRECTED

## 🔧 Fix for "server directive is not allowed here" Error

This error usually means there's a syntax issue or extra content in the file.

---

## ✅ Corrected Configuration

**Delete the old file and create a new one:**

```bash
# Remove the problematic file
sudo rm /etc/nginx/sites-enabled/admin.rewardo.fun

# Create fresh config
sudo nano /etc/nginx/sites-available/admin.rewardo.fun
```

**Paste ONLY this (make sure file is completely empty first):**

```nginx
server {
    listen 80;
    server_name admin.rewardo.fun;

    root /var/www/silah_app/admin-dashboard/dist;
    index index.html;

    access_log /var/log/nginx/admin.rewardo.fun.access.log;
    error_log /var/log/nginx/admin.rewardo.fun.error.log;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

**Important:** 
- Make sure the file starts with `server {` (no extra lines before)
- Make sure the file ends with `}` (no extra lines after)
- No comments or extra content outside the server block

---

## 🔍 Troubleshooting Steps

### Step 1: Check Current File Content

```bash
cat /etc/nginx/sites-available/admin.rewardo.fun
```

Look for:
- Extra content before `server {`
- Extra content after the closing `}`
- Missing closing braces
- Syntax errors

### Step 2: Remove and Recreate

```bash
# Remove both files
sudo rm /etc/nginx/sites-available/admin.rewardo.fun
sudo rm /etc/nginx/sites-enabled/admin.rewardo.fun

# Create fresh file
sudo nano /etc/nginx/sites-available/admin.rewardo.fun
```

**Paste the corrected config above (make sure file is empty first)**

### Step 3: Enable and Test

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/admin.rewardo.fun /etc/nginx/sites-enabled/

# Test
sudo nginx -t
```

---

## ✅ Minimal Working Config (If Still Having Issues)

If you're still getting errors, try this minimal version first:

```nginx
server {
    listen 80;
    server_name admin.rewardo.fun;
    root /var/www/silah_app/admin-dashboard/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

Then test:
```bash
sudo nginx -t
```

If this works, you can add the other options back gradually.

---

## 🚨 Common Issues

1. **Extra content in file** - Make sure file only contains the server block
2. **Missing closing brace** - Count your `{` and `}` - they must match
3. **Wrong file location** - Make sure you're editing `/etc/nginx/sites-available/` not `sites-enabled/`
4. **File encoding issues** - Make sure you're using UTF-8

---

## 📋 Quick Fix Commands

```bash
# 1. Remove problematic files
sudo rm /etc/nginx/sites-enabled/admin.rewardo.fun
sudo rm /etc/nginx/sites-available/admin.rewardo.fun

# 2. Create fresh file
sudo nano /etc/nginx/sites-available/admin.rewardo.fun
# (Paste the corrected config - make sure file is empty first)

# 3. Enable site
sudo ln -s /etc/nginx/sites-available/admin.rewardo.fun /etc/nginx/sites-enabled/

# 4. Test
sudo nginx -t

# 5. If test passes, reload
sudo systemctl reload nginx
```

---

**Last Updated:** 2025-01-22
