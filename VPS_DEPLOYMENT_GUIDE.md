# Silah Backend - VPS Deployment Guide

## 🚀 Step-by-Step VPS Deployment

### Prerequisites

**VPS Requirements:**
- Ubuntu 20.04+ or similar Linux distribution
- Minimum 2GB RAM, 2 CPU cores
- 20GB+ storage
- Root or sudo access

**Software Required:**
- Node.js 18+ and npm
- MongoDB 6.0+
- PM2 (Process Manager)
- Nginx (Reverse Proxy)
- Git
- SSL Certificate (Let's Encrypt)

---

## Step 1: Connect to VPS

```bash
ssh root@your-vps-ip
# or
ssh username@your-vps-ip
```

---

## Step 2: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

---

## Step 3: Install Node.js

```bash
# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # Should show v18.x or higher
npm --version
```

---

## Step 4: Install MongoDB

```bash
# Import MongoDB GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Install MongoDB
sudo apt update
sudo apt install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify MongoDB is running
sudo systemctl status mongod
```

---

## Step 5: Install PM2 (Process Manager)

```bash
sudo npm install -g pm2

# Verify installation
pm2 --version
```

---

## Step 6: Install Nginx

```bash
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify Nginx is running
sudo systemctl status nginx
```

---

## Step 7: Clone Backend Repository

```bash
# Navigate to home directory
cd ~

# Clone your backend repository
# Replace with your actual repository URL
git clone https://github.com/yourusername/silah-backend.git

# Navigate to backend directory
cd silah-backend

# Install dependencies
npm install
```

---

## Step 8: Configure Environment Variables

```bash
# Create .env file
nano .env
```

**Add the following configuration:**

```env
# Server Configuration
NODE_ENV=production
PORT=5000
API_URL=https://api.yourdomain.com

# MongoDB
MONGODB_URI=mongodb://localhost:27017/silah
# Or if using MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/silah

# JWT Secret (Generate a strong random string)
JWT_SECRET=your-super-secret-jwt-key-change-this-to-random-string
JWT_EXPIRES_IN=7d

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Stripe Payment (if using)
STRIPE_SECRET_KEY=sk_live_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_live_your_stripe_publishable_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# SendGrid Email (if using)
SENDGRID_API_KEY=SG.your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@yourdomain.com

# Twilio SMS (if using)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=+1234567890

# Firebase Admin SDK (for push notifications)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880

# CORS
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com

# Admin
ADMIN_JWT_SECRET=your-admin-jwt-secret-change-this
ADMIN_DEFAULT_EMAIL=admin@yourdomain.com
ADMIN_DEFAULT_PASSWORD=change-this-password
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

---

## Step 9: Generate JWT Secrets

```bash
# Generate random JWT secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Generate admin JWT secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

Copy the generated strings and add them to your `.env` file.

---

## Step 10: Create Uploads Directory

```bash
# Create uploads directory for profile photos
mkdir -p uploads
chmod 755 uploads
```

---

## Step 11: Build TypeScript (if using TypeScript)

```bash
# If your backend uses TypeScript
npm run build

# Or if you have a build script
npm run compile
```

---

## Step 12: Start Backend with PM2

```bash
# Start the application
pm2 start dist/server.js --name silah-backend
# Or if using JavaScript directly:
# pm2 start server.js --name silah-backend

# Save PM2 configuration
pm2 save

# Setup PM2 to start on system boot
pm2 startup
# Follow the instructions shown

# Check status
pm2 status
pm2 logs silah-backend
```

---

## Step 13: Configure Nginx Reverse Proxy

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/silah-backend
```

**Add the following configuration:**

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

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

    # Static files (profile photos)
    location /uploads {
        alias /home/username/silah-backend/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

**Enable the site:**

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/silah-backend /etc/nginx/sites-enabled/

# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

---

## Step 14: Install SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d api.yourdomain.com

# Follow the prompts:
# - Enter your email
# - Agree to terms
# - Choose whether to redirect HTTP to HTTPS (recommended: Yes)

# Test auto-renewal
sudo certbot renew --dry-run
```

**Nginx will automatically update with SSL configuration.**

---

## Step 15: Configure Firewall

```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

---

## Step 16: Update Frontend API URL

**In your Flutter app, update `lib/core/app_config.dart`:**

```dart
case 'production':
  return 'https://api.yourdomain.com/api'; // Your VPS domain
```

---

## Step 17: Test Backend

```bash
# Test API endpoint
curl https://api.yourdomain.com/api/settings

# Test Socket.io (from browser console)
# Open: https://api.yourdomain.com/socket.io/?EIO=4&transport=polling
```

---

## Step 18: Create Admin User (First Time)

```bash
# SSH into your server
ssh root@your-vps-ip

# Navigate to backend directory
cd ~/silah-backend

# Run admin creation script (if you have one)
# Or manually create admin via MongoDB:

# Connect to MongoDB
mongosh

# Switch to database
use silah

# Create admin user
db.adminusers.insertOne({
  email: "admin@yourdomain.com",
  password: "$2b$10$hashedpassword", // Use bcrypt hash
  role: "superadmin",
  createdAt: new Date(),
  isActive: true
})

# Exit MongoDB
exit
```

**Or use your admin registration endpoint if available.**

---

## 📋 Post-Deployment Checklist

- [ ] Backend is running on PM2
- [ ] MongoDB is running
- [ ] Nginx is configured and running
- [ ] SSL certificate is installed
- [ ] Firewall is configured
- [ ] Environment variables are set
- [ ] Admin user is created
- [ ] API endpoints are accessible
- [ ] Socket.io is working
- [ ] File uploads directory has correct permissions
- [ ] Frontend API URL is updated

---

## 🔧 Useful PM2 Commands

```bash
# View logs
pm2 logs silah-backend

# Restart application
pm2 restart silah-backend

# Stop application
pm2 stop silah-backend

# Delete application
pm2 delete silah-backend

# Monitor
pm2 monit

# View all processes
pm2 list
```

---

## 🔧 Useful Nginx Commands

```bash
# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

---

## 🔧 Useful MongoDB Commands

```bash
# Start MongoDB
sudo systemctl start mongod

# Stop MongoDB
sudo systemctl stop mongod

# Restart MongoDB
sudo systemctl restart mongod

# Check status
sudo systemctl status mongod

# Connect to MongoDB shell
mongosh

# Backup database
mongodump --out /backup/$(date +%Y%m%d)

# Restore database
mongorestore /backup/20241201
```

---

## 🐛 Troubleshooting

### Backend not starting
```bash
# Check PM2 logs
pm2 logs silah-backend --lines 50

# Check if port is in use
sudo lsof -i :5000

# Check environment variables
pm2 env silah-backend
```

### Nginx 502 Bad Gateway
```bash
# Check if backend is running
pm2 status

# Check backend logs
pm2 logs silah-backend

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

### MongoDB connection issues
```bash
# Check MongoDB status
sudo systemctl status mongod

# Check MongoDB logs
sudo tail -f /var/log/mongodb/mongod.log

# Test MongoDB connection
mongosh
```

### SSL certificate issues
```bash
# Renew certificate manually
sudo certbot renew

# Check certificate status
sudo certbot certificates
```

---

## 📝 Environment Variables Reference

**Required:**
- `NODE_ENV` - Environment (production)
- `PORT` - Server port (5000)
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - JWT signing secret
- `CORS_ORIGIN` - Allowed CORS origins

**Optional but Recommended:**
- `GOOGLE_CLIENT_ID` - Google OAuth
- `GOOGLE_CLIENT_SECRET` - Google OAuth
- `STRIPE_SECRET_KEY` - Payment processing
- `SENDGRID_API_KEY` - Email service
- `TWILIO_ACCOUNT_SID` - SMS service
- `FIREBASE_PROJECT_ID` - Push notifications

---

## 🚀 Quick Deployment Script

Save this as `deploy.sh`:

```bash
#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo apt install -y nginx

# Clone repository (update URL)
cd ~
git clone https://github.com/yourusername/silah-backend.git
cd silah-backend

# Install dependencies
npm install

# Create .env file (you need to edit this)
cp .env.example .env
nano .env

# Create uploads directory
mkdir -p uploads
chmod 755 uploads

# Build (if TypeScript)
npm run build

# Start with PM2
pm2 start dist/server.js --name silah-backend
pm2 save
pm2 startup

echo "Backend deployed! Now configure Nginx and SSL."
```

**Make executable:**
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## 📞 Support

If you encounter issues:
1. Check PM2 logs: `pm2 logs silah-backend`
2. Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Check MongoDB logs: `sudo tail -f /var/log/mongodb/mongod.log`
4. Verify environment variables are set correctly
5. Test API endpoints individually

---

**Last Updated:** 2024-12-XX
