# Backend API Deployment - Step by Step

## 🎯 Goal
Deploy the backend API to your VPS at `https://api.rewardo.fun`

---

## Step 1: Verify Backend Code is on VPS

```bash
# Check if backend folder exists
ls -la /var/www/silah_app/backend/

# If backend folder doesn't exist, clone from GitHub
cd /var/www/silah_app
git pull origin main
# OR if backend is in separate location:
# git clone https://github.com/kxaviera/silah_app.git temp
# mv temp/backend ./
# rm -rf temp
```

**Expected:** You should see `package.json`, `src/`, `tsconfig.json`, etc.

---

## Step 2: Install Node.js Dependencies

```bash
cd /var/www/silah_app/backend

# Install all dependencies
npm install

# This will take a few minutes...
```

**Expected output:** `added XXX packages` and `found 0 vulnerabilities`

---

## Step 3: Generate JWT Secrets

```bash
# Generate JWT Secret (for users)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Copy the output - you'll need it!

# Generate Admin JWT Secret (for admin dashboard)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Copy this output too!
```

**⚠️ Important:** Save both secrets - you'll paste them in the `.env` file.

---

## Step 4: Create .env File

```bash
cd /var/www/silah_app/backend
nano .env
```

**Paste this template and fill in the values:**

```env
# ============================================
# SERVER CONFIGURATION
# ============================================
NODE_ENV=production
PORT=5000
API_URL=https://api.rewardo.fun

# ============================================
# MONGODB DATABASE
# ============================================
MONGODB_URI=mongodb://localhost:27017/silah

# ============================================
# JWT AUTHENTICATION (User Tokens)
# ============================================
# Paste the FIRST generated secret here
JWT_SECRET=PASTE_FIRST_SECRET_HERE
JWT_EXPIRES_IN=7d

# ============================================
# ADMIN JWT AUTHENTICATION
# ============================================
# Paste the SECOND generated secret here
ADMIN_JWT_SECRET=PASTE_SECOND_SECRET_HERE
ADMIN_JWT_EXPIRE=24h

# ============================================
# GOOGLE OAUTH (Optional - leave empty)
# ============================================
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# ============================================
# STRIPE PAYMENT (Optional - leave empty)
# ============================================
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=

# ============================================
# SENDGRID EMAIL (Optional - leave empty)
# ============================================
SENDGRID_API_KEY=
SENDGRID_FROM_EMAIL=noreply@rewardo.fun

# ============================================
# TWILIO SMS (Optional - leave empty)
# ============================================
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=

# ============================================
# FIREBASE (Optional - leave empty)
# ============================================
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=

# ============================================
# FILE UPLOAD
# ============================================
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880

# ============================================
# CORS CONFIGURATION
# ============================================
CORS_ORIGIN=https://admin.rewardo.fun,https://api.rewardo.fun
FRONTEND_URL=https://admin.rewardo.fun

# ============================================
# ADMIN DEFAULT CREDENTIALS
# ============================================
ADMIN_DEFAULT_EMAIL=admin@rewardo.fun
ADMIN_DEFAULT_PASSWORD=ChangeThisPassword123!
```

**To save:**
- Press `Ctrl+X`
- Press `Y` to confirm
- Press `Enter` to save

---

## Step 5: Verify MongoDB is Running

```bash
# Check MongoDB status
sudo systemctl status mongodb

# If not running, start it
sudo systemctl start mongodb
sudo systemctl enable mongodb
```

**Expected:** MongoDB should be `active (running)`

---

## Step 6: Build TypeScript Code

```bash
cd /var/www/silah_app/backend

# Build TypeScript to JavaScript
npm run build

# This creates a 'dist' folder with compiled JavaScript
```

**Expected output:** `dist/` folder created with `server.js` inside

---

## Step 7: Create Uploads Directory

```bash
cd /var/www/silah_app/backend
mkdir -p uploads/profile-photos
chmod -R 755 uploads
```

---

## Step 8: Install PM2 (If Not Installed)

```bash
# Install PM2 globally
sudo npm install -g pm2

# Verify installation
pm2 --version
```

---

## Step 9: Start Backend with PM2

```bash
cd /var/www/silah_app/backend

# Start backend
pm2 start dist/server.js --name silah-backend

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Copy and run the command it shows you (usually starts with 'sudo env PATH=...')
```

**Check status:**
```bash
pm2 status
pm2 logs silah-backend
```

**Expected:** Backend should show as `online` and logs should show "Server running on port 5000"

---

## Step 10: Configure Nginx for Backend API

```bash
# Create Nginx config for API
sudo nano /etc/nginx/sites-available/api.rewardo.fun
```

**Paste this configuration:**

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

**Save:** `Ctrl+X`, `Y`, `Enter`

**Enable the site:**
```bash
sudo ln -s /etc/nginx/sites-available/api.rewardo.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Step 11: Install SSL Certificate for Backend

```bash
sudo certbot --nginx -d api.rewardo.fun

# Follow prompts:
# - Enter email address
# - Agree to terms
# - Choose redirect HTTP to HTTPS (recommended: Yes)
```

---

## Step 12: Verify Backend is Working

```bash
# Test health endpoint (if you have one)
curl https://api.rewardo.fun/api/health

# Or test any endpoint
curl https://api.rewardo.fun/api/auth/health

# Check PM2 status
pm2 status

# Check logs
pm2 logs silah-backend --lines 50
```

---

## Step 13: Create Admin User (Optional)

```bash
cd /var/www/silah_app/backend

# Create admin user (uses ADMIN_DEFAULT_EMAIL and ADMIN_DEFAULT_PASSWORD from .env)
npm run create-admin
```

---

## ✅ Verification Checklist

- [ ] Backend code is on VPS
- [ ] Dependencies installed (`npm install`)
- [ ] JWT secrets generated and added to `.env`
- [ ] `.env` file created with all required values
- [ ] MongoDB is running
- [ ] TypeScript code built (`npm run build`)
- [ ] Uploads directory created
- [ ] Backend started with PM2
- [ ] PM2 configured to start on boot
- [ ] Nginx configured for `api.rewardo.fun`
- [ ] SSL certificate installed
- [ ] Backend accessible via `https://api.rewardo.fun`
- [ ] Admin dashboard can connect to backend

---

## 🐛 Troubleshooting

### Backend won't start:
```bash
# Check logs
pm2 logs silah-backend

# Check if port 5000 is in use
sudo lsof -i :5000

# Restart backend
pm2 restart silah-backend
```

### MongoDB connection error:
```bash
# Check MongoDB status
sudo systemctl status mongodb

# Check MongoDB logs
sudo journalctl -u mongodb -n 50
```

### Nginx errors:
```bash
# Check Nginx config
sudo nginx -t

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

---

## 🎉 Success!

Once all steps are complete:
- ✅ Backend API is running
- ✅ Accessible via `https://api.rewardo.fun`
- ✅ Admin dashboard can connect
- ✅ Flutter app can connect

**Next:** Test the admin dashboard → backend connection!

---

**Last Updated:** 2025-01-23
