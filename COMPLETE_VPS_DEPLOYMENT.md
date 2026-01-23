# Complete VPS Deployment Guide - Fresh Start

## 🎯 Overview

This guide will help you deploy:
1. Backend API (`api.rewardo.fun`)
2. Admin Dashboard (`admin.rewardo.fun`)
3. MongoDB Database
4. Nginx Configuration
5. SSL Certificates

---

## 📋 Prerequisites

- VPS with Ubuntu 24.04 (or 22.04)
- Root access
- Domain names configured:
  - `api.rewardo.fun` → Your VPS IP
  - `admin.rewardo.fun` → Your VPS IP

---

## Step 1: Initial VPS Setup

### 1.1 Update System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 1.2 Install Basic Tools

```bash
sudo apt-get install -y curl git build-essential
```

---

## Step 2: Install Node.js 20

```bash
# Add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js 20
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

---

## Step 3: Install MongoDB

```bash
# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Add MongoDB repository (using Jammy for Ubuntu 24.04 compatibility)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update and install
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify MongoDB is running
sudo systemctl status mongod
```

---

## Step 4: Install PM2

```bash
sudo npm install -g pm2
pm2 --version
```

---

## Step 5: Install Nginx

```bash
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

---

## Step 6: Install Certbot (for SSL)

```bash
sudo apt-get install -y certbot python3-certbot-nginx
```

---

## Step 7: Clone Repository

```bash
# Create directory
sudo mkdir -p /var/www/silah_app
cd /var/www/silah_app

# Clone repository
sudo git clone https://github.com/kxaviera/silah_app.git .

# Set ownership
sudo chown -R $USER:$USER /var/www/silah_app
```

---

## Step 8: Deploy Backend API

### 8.1 Install Backend Dependencies

```bash
cd /var/www/silah_app/backend
npm install
```

### 8.2 Generate JWT Secrets

```bash
# Generate JWT Secret (for users)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
# Copy the output!

# Generate Admin JWT Secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
# Copy this output too!
```

### 8.3 Create .env File

```bash
cd /var/www/silah_app/backend
nano .env
```

**Paste this template and fill in the secrets:**

```env
NODE_ENV=production
PORT=5000
API_URL=https://api.rewardo.fun
MONGODB_URI=mongodb://localhost:27017/silah
JWT_SECRET=PASTE_FIRST_SECRET_HERE
JWT_EXPIRE=7d
ADMIN_JWT_SECRET=PASTE_SECOND_SECRET_HERE
ADMIN_JWT_EXPIRE=24h
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880
CORS_ORIGIN=https://admin.rewardo.fun,https://api.rewardo.fun
FRONTEND_URL=https://admin.rewardo.fun
ADMIN_DEFAULT_EMAIL=admin@rewardo.fun
ADMIN_DEFAULT_PASSWORD=ChangeThisPassword123!
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### 8.4 Build TypeScript

```bash
cd /var/www/silah_app/backend
npm run build
```

### 8.5 Create Uploads Directory

```bash
mkdir -p uploads/profile-photos
chmod -R 755 uploads
```

### 8.6 Start Backend with PM2

```bash
cd /var/www/silah_app/backend
pm2 start dist/server.js --name silah-backend
pm2 save
pm2 startup  # Run the command it shows you
pm2 logs silah-backend  # Check if it started successfully
```

---

## Step 9: Configure Nginx for Backend API

### 9.1 Create Nginx Config

```bash
sudo nano /etc/nginx/sites-available/api.rewardo.fun
```

**Paste this:**

```nginx
server {
    listen 80;
    server_name api.rewardo.fun;

    client_max_body_size 10M;

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /socket.io {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### 9.2 Enable Site

```bash
sudo ln -s /etc/nginx/sites-available/api.rewardo.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 9.3 Install SSL for Backend

```bash
sudo certbot --nginx -d api.rewardo.fun
```

---

## Step 10: Deploy Admin Dashboard

### 10.1 Install Dependencies

```bash
cd /var/www/silah_app/admin-dashboard
npm install
```

### 10.2 Create .env File

```bash
cd /var/www/silah_app/admin-dashboard
nano .env
```

**Paste this:**

```env
VITE_API_URL=https://api.rewardo.fun/api
```

**Save:** `Ctrl+X`, `Y`, `Enter`

### 10.3 Build Admin Dashboard

```bash
cd /var/www/silah_app/admin-dashboard
npm run build
```

### 10.4 Set Permissions

```bash
sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist
```

---

## Step 11: Configure Nginx for Admin Dashboard

### 11.1 Create Nginx Config

```bash
sudo nano /etc/nginx/sites-available/admin.rewardo.fun
```

**Paste this:**

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

**Save:** `Ctrl+X`, `Y`, `Enter`

### 11.2 Enable Site

```bash
sudo ln -s /etc/nginx/sites-available/admin.rewardo.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 11.3 Install SSL for Admin Dashboard

```bash
sudo certbot --nginx -d admin.rewardo.fun
```

---

## Step 12: Verify Everything is Working

### 12.1 Check Backend

```bash
# Check PM2 status
pm2 status

# Check backend logs
pm2 logs silah-backend --lines 20

# Test API endpoint
curl https://api.rewardo.fun/api/health
```

### 12.2 Check Admin Dashboard

Visit: **https://admin.rewardo.fun**

You should see the login page.

---

## ✅ Deployment Checklist

- [ ] Node.js 20 installed
- [ ] MongoDB installed and running
- [ ] PM2 installed
- [ ] Nginx installed and running
- [ ] Backend code cloned
- [ ] Backend dependencies installed
- [ ] Backend .env configured
- [ ] Backend built successfully
- [ ] Backend running with PM2
- [ ] Backend Nginx configured
- [ ] Backend SSL installed
- [ ] Admin dashboard dependencies installed
- [ ] Admin dashboard .env configured
- [ ] Admin dashboard built
- [ ] Admin dashboard Nginx configured
- [ ] Admin dashboard SSL installed
- [ ] Both sites accessible via HTTPS

---

## 🐛 Troubleshooting

### Backend won't start:
```bash
pm2 logs silah-backend
# Check for errors in logs
```

### MongoDB connection error:
```bash
sudo systemctl status mongod
sudo journalctl -u mongod -n 50
```

### Nginx errors:
```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

---

**Follow these steps in order. If you encounter any issues, let me know!**
