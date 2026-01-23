# 🚀 Next Steps - Production Deployment Roadmap

## ✅ Completed

- ✅ Admin Dashboard deployed and working
- ✅ Node.js 20 installed
- ✅ Nginx configured for admin dashboard
- ✅ Frontend API URL configured (`https://api.rewardo.fun/api`)

---

## 📋 Priority Tasks

### 1. 🔒 Install SSL Certificate for Admin Dashboard (HIGH PRIORITY)

**Why:** Security and HTTPS encryption

```bash
# Install Certbot (if not already installed)
sudo apt-get install -y certbot python3-certbot-nginx

# Get SSL certificate for admin dashboard
sudo certbot --nginx -d admin.rewardo.fun

# Follow prompts:
# - Enter email address
# - Agree to terms
# - Choose redirect HTTP to HTTPS (recommended: Yes)
```

**After SSL:** Access via **https://admin.rewardo.fun**

---

### 2. 🖥️ Deploy Backend API (CRITICAL)

**Status:** Backend code exists but needs deployment to VPS

**Steps:**

#### 2.1. Verify Backend is on VPS

```bash
# Check if backend folder exists
ls -la /var/www/silah_app/backend/

# If not, clone from GitHub
cd /var/www/silah_app
git clone https://github.com/kxaviera/silah_app.git temp
mv temp/backend ./
rm -rf temp
```

#### 2.2. Install Backend Dependencies

```bash
cd /var/www/silah_app/backend
npm install
npm run build
```

#### 2.3. Configure Backend Environment

```bash
# Create .env file
nano /var/www/silah_app/backend/.env
```

**Required variables:**
```env
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb://localhost:27017/silah
JWT_SECRET=your_jwt_secret_here
ADMIN_JWT_SECRET=your_admin_jwt_secret_here
SENDGRID_API_KEY=your_sendgrid_key
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
STRIPE_SECRET_KEY=your_stripe_key
FRONTEND_URL=https://your-frontend-domain.com
```

#### 2.4. Start Backend with PM2

```bash
# Install PM2 globally (if not installed)
sudo npm install -g pm2

# Start backend
cd /var/www/silah_app/backend
pm2 start dist/server.js --name silah-backend

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

#### 2.5. Configure Nginx for Backend API

```bash
# Create Nginx config for API
sudo nano /etc/nginx/sites-available/api.rewardo.fun
```

**Add this configuration:**
```nginx
server {
    listen 80;
    server_name api.rewardo.fun;

    # Increase body size for file uploads
    client_max_body_size 10M;

    # Backend API
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

    # Socket.io
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

**Enable and test:**
```bash
sudo ln -s /etc/nginx/sites-available/api.rewardo.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 2.6. Install SSL for Backend API

```bash
sudo certbot --nginx -d api.rewardo.fun
```

#### 2.7. Verify Backend is Running

```bash
# Check PM2 status
pm2 status

# Check backend logs
pm2 logs silah-backend

# Test API endpoint
curl https://api.rewardo.fun/api/health
```

---

### 3. 🗄️ Setup MongoDB (If Not Already Done)

```bash
# Install MongoDB (if not installed)
sudo apt-get install -y mongodb

# Start MongoDB
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Verify MongoDB is running
sudo systemctl status mongodb

# Create database (MongoDB will create it automatically on first connection)
```

---

### 4. 🧪 Test End-to-End Integration

#### 4.1. Test Admin Dashboard → Backend Connection

1. Open admin dashboard: `https://admin.rewardo.fun`
2. Try logging in (should connect to backend API)
3. Test dashboard features (users, reports, transactions)

#### 4.2. Test Flutter App → Backend Connection

1. Build Flutter app in release mode
2. Install on device/emulator
3. Test signup/login flow
4. Test profile creation
5. Test messaging
6. Test notifications

---

### 5. 📱 Build Flutter App for Production

#### 5.1. Android Build

```bash
cd D:\Silah\SIlah  # Or your Flutter project path

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

**Output:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

#### 5.2. iOS Build (if applicable)

```bash
# Build iOS
flutter build ios --release

# Create IPA (requires Xcode)
# Open Xcode → Archive → Distribute
```

---

### 6. 🔍 Final Verification Checklist

- [ ] Admin dashboard accessible via HTTPS
- [ ] Backend API deployed and running
- [ ] Backend API accessible via HTTPS
- [ ] MongoDB running and connected
- [ ] PM2 managing backend process
- [ ] SSL certificates installed for both domains
- [ ] DNS configured (A records for both domains)
- [ ] Admin dashboard can connect to backend
- [ ] Flutter app can connect to backend
- [ ] End-to-end testing completed

---

## 🎯 Recommended Order

1. **Install SSL for admin dashboard** (5 minutes)
2. **Deploy backend API** (30-45 minutes)
3. **Install SSL for backend API** (5 minutes)
4. **Test admin dashboard → backend connection** (10 minutes)
5. **Build Flutter app** (15 minutes)
6. **Test Flutter app → backend connection** (30 minutes)
7. **Final verification** (15 minutes)

**Total Estimated Time:** ~2 hours

---

## 📝 Quick Command Reference

### Backend Management

```bash
# Navigate to backend
cd /var/www/silah_app/backend

# Start backend
pm2 start dist/server.js --name silah-backend

# Restart backend
pm2 restart silah-backend

# Stop backend
pm2 stop silah-backend

# View logs
pm2 logs silah-backend

# View status
pm2 status
```

### Nginx Management

```bash
# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Check status
sudo systemctl status nginx
```

### SSL Management

```bash
# Get SSL certificate
sudo certbot --nginx -d domain.com

# Renew certificates
sudo certbot renew

# Test auto-renewal
sudo certbot renew --dry-run
```

---

## 🆘 Need Help?

If you encounter any issues:
1. Check PM2 logs: `pm2 logs silah-backend`
2. Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Check MongoDB status: `sudo systemctl status mongodb`
4. Verify environment variables in `.env` file
5. Test API endpoints: `curl https://api.rewardo.fun/api/health`

---

**Last Updated:** 2025-01-23
**Status:** Ready for Backend Deployment
