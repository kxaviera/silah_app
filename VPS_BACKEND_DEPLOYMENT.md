# VPS Backend Deployment Guide - Node.js/TypeScript

**Backend Type:** Node.js + Express + TypeScript (NOT PHP/Laravel)

---

## 🚨 Important Notes

1. **This is NOT a PHP/Laravel project** - No Composer, no `artisan` commands
2. **This is a Node.js project** - Uses `npm` or `yarn`
3. **Port 80 conflict** - Apache2 is conflicting with Nginx (stop Apache2 or use Nginx)

---

## ✅ Correct Deployment Steps

### Step 1: Stop Apache2 (if using Nginx)

```bash
sudo systemctl stop apache2
sudo systemctl disable apache2
```

Or if you want to keep Apache2, configure it to use a different port.

---

### Step 2: Navigate to Backend Directory

```bash
cd /var/www/silah_app/backend
```

---

### Step 3: Install Node.js Dependencies

```bash
# Install Node.js if not already installed
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install dependencies
npm install
```

---

### Step 4: Create .env File

```bash
# Create .env file
nano .env
```

**Add this configuration:**

```env
# Server Configuration
NODE_ENV=production
PORT=5000
API_URL=https://api.rewardo.fun

# MongoDB
MONGODB_URI=mongodb://localhost:27017/silah

# JWT Secret (Generate with: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
JWT_SECRET=<generate-random-64-char-string>
JWT_EXPIRES_IN=7d

# Admin JWT Secret (Generate another one)
ADMIN_JWT_SECRET=<generate-another-random-64-char-string>
ADMIN_JWT_EXPIRE=24h

# Google OAuth (if using)
GOOGLE_CLIENT_ID=<your-google-client-id>
GOOGLE_CLIENT_SECRET=<your-google-client-secret>

# Stripe (if using)
STRIPE_SECRET_KEY=sk_live_<your-key>
STRIPE_PUBLISHABLE_KEY=pk_live_<your-key>

# SendGrid (if using)
SENDGRID_API_KEY=SG.<your-key>
SENDGRID_FROM_EMAIL=noreply@rewardo.fun

# Firebase (for push notifications)
FIREBASE_PROJECT_ID=<your-project-id>
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n<key>\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=<service-account-email>

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880

# CORS
CORS_ORIGIN=https://admin.rewardo.fun,https://api.rewardo.fun
FRONTEND_URL=https://admin.rewardo.fun
```

**Save:** `Ctrl+X`, then `Y`, then `Enter`

---

### Step 5: Generate JWT Secrets

```bash
# Generate JWT Secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Generate Admin JWT Secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

Copy the output and add to your `.env` file.

---

### Step 6: Create Uploads Directory

```bash
mkdir -p uploads
chmod 755 uploads
```

---

### Step 7: Build TypeScript

```bash
# Build TypeScript to JavaScript
npm run build
```

This creates a `dist/` folder with compiled JavaScript.

---

### Step 8: Create Admin User

```bash
# Create initial admin user
npm run create-admin
```

Or manually:
```bash
npx ts-node scripts/create-admin.ts
```

---

### Step 9: Start with PM2

```bash
# Install PM2 globally
sudo npm install -g pm2

# Start the backend
pm2 start dist/server.js --name silah-backend

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Follow the instructions shown

# Check status
pm2 status
pm2 logs silah-backend
```

---

### Step 10: Configure Nginx (if using)

**Create Nginx config for API:**

```bash
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

**Enable the site:**

```bash
sudo ln -s /etc/nginx/sites-available/api.rewardo.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### Step 11: Install SSL Certificate

```bash
sudo certbot --nginx -d api.rewardo.fun
```

---

## 🔍 Verify Deployment

### Test Backend

```bash
# Test health endpoint
curl http://localhost:5000/health

# Test from outside
curl https://api.rewardo.fun/health
```

### Check PM2 Status

```bash
pm2 status
pm2 logs silah-backend
```

---

## 📋 Quick Command Reference

```bash
# Navigate to backend
cd /var/www/silah_app/backend

# Install dependencies
npm install

# Build TypeScript
npm run build

# Start with PM2
pm2 start dist/server.js --name silah-backend

# Restart
pm2 restart silah-backend

# Stop
pm2 stop silah-backend

# View logs
pm2 logs silah-backend

# View status
pm2 status
```

---

## ⚠️ Common Issues

### Issue 1: Port 80 Already in Use

**Solution:** Stop Apache2 or configure it differently
```bash
sudo systemctl stop apache2
sudo systemctl disable apache2
```

### Issue 2: MongoDB Not Running

**Solution:** Start MongoDB
```bash
sudo systemctl start mongod
sudo systemctl enable mongod
```

### Issue 3: Build Errors

**Solution:** Check Node.js version (should be 18+)
```bash
node --version
npm --version
```

---

## ✅ Success Checklist

- [ ] Node.js installed (v18+)
- [ ] Dependencies installed (`npm install`)
- [ ] `.env` file created with all variables
- [ ] JWT secrets generated and added
- [ ] TypeScript built (`npm run build`)
- [ ] Uploads directory created
- [ ] Admin user created
- [ ] PM2 installed and configured
- [ ] Backend running on port 5000
- [ ] Nginx configured (if using)
- [ ] SSL certificate installed
- [ ] Health endpoint accessible

---

**Last Updated:** 2025-01-22
