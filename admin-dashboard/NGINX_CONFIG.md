# Nginx Configuration for Admin Dashboard

## 📋 Complete Nginx Config for admin.rewardo.fun

### Step 1: Create Nginx Config File

```bash
sudo nano /etc/nginx/sites-available/admin.rewardo.fun
```

---

### Step 2: Add This Configuration

**Paste this entire configuration:**

```nginx
server {
    listen 80;
    server_name admin.rewardo.fun;

    # Root directory (where admin dashboard build files are)
    root /var/www/silah_app/admin-dashboard/dist;
    index index.html;

    # Logging
    access_log /var/log/nginx/admin.rewardo.fun.access.log;
    error_log /var/log/nginx/admin.rewardo.fun.error.log;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Main location - serve React app
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # API proxy (optional - if you want to proxy through admin domain)
    # Uncomment if needed:
    # location /api {
    #     proxy_pass http://localhost:5000;
    #     proxy_http_version 1.1;
    #     proxy_set_header Upgrade $http_upgrade;
    #     proxy_set_header Connection 'upgrade';
    #     proxy_set_header Host $host;
    #     proxy_set_header X-Real-IP $remote_addr;
    #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto $scheme;
    #     proxy_cache_bypass $http_upgrade;
    # }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

---

## ✅ Step-by-Step Setup

### Step 1: Create the config file

```bash
sudo nano /etc/nginx/sites-available/admin.rewardo.fun
```

### Step 2: Paste the configuration above

### Step 3: Enable the site

```bash
sudo ln -s /etc/nginx/sites-available/admin.rewardo.fun /etc/nginx/sites-enabled/
```

### Step 4: Test Nginx configuration

```bash
sudo nginx -t
```

**Expected output:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Step 5: Reload Nginx

```bash
sudo systemctl reload nginx
```

---

## 🔒 Step 6: Install SSL Certificate (After DNS is configured)

```bash
sudo certbot --nginx -d admin.rewardo.fun
```

This will automatically:
- Get SSL certificate from Let's Encrypt
- Update Nginx config to use HTTPS
- Set up auto-renewal

---

## 📝 Important Notes

1. **Root directory:** `/var/www/silah_app/admin-dashboard/dist`
   - Make sure you've built the admin dashboard first: `npm run build`
   - The `dist/` folder must exist

2. **React SPA routing:** `try_files $uri $uri/ /index.html;`
   - This ensures React Router works correctly
   - All routes will serve `index.html`

3. **Static assets caching:** 
   - JS/CSS/images cached for 1 year
   - Helps with performance

4. **API proxy:** 
   - Currently commented out
   - Admin dashboard connects directly to `api.rewardo.fun`
   - Uncomment if you want to proxy API through admin domain

---

## 🔍 Verify Setup

### Check if site is enabled:

```bash
ls -la /etc/nginx/sites-enabled/ | grep admin
```

### Check Nginx status:

```bash
sudo systemctl status nginx
```

### Test in browser:

After DNS is configured, visit: `http://admin.rewardo.fun`

---

## 🚀 Complete Setup Checklist

- [ ] Build admin dashboard: `cd /var/www/silah_app/admin-dashboard && npm run build`
- [ ] Create Nginx config file
- [ ] Enable site with symlink
- [ ] Test Nginx configuration
- [ ] Reload Nginx
- [ ] Configure DNS (A record for `admin.rewardo.fun`)
- [ ] Install SSL certificate with Certbot
- [ ] Test admin dashboard in browser

---

## 📋 Quick Copy-Paste Commands

```bash
# 1. Create config
sudo nano /etc/nginx/sites-available/admin.rewardo.fun
# (Paste the config above)

# 2. Enable site
sudo ln -s /etc/nginx/sites-available/admin.rewardo.fun /etc/nginx/sites-enabled/

# 3. Test
sudo nginx -t

# 4. Reload
sudo systemctl reload nginx

# 5. Install SSL (after DNS configured)
sudo certbot --nginx -d admin.rewardo.fun
```

---

**Last Updated:** 2025-01-22
