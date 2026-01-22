# Silah Backend - VPS Deployment Commands
# VPS IP: 88.222.241.43

## 🚀 Step-by-Step Deployment Commands

### Step 1: Connect to Your VPS

```bash
ssh root@88.222.241.43
# Or if you have a username:
# ssh username@88.222.241.43
```

**If this is your first time connecting, you may need to accept the SSH fingerprint.**

---

### Step 2: Run Initial Setup Script

Once connected to your VPS, run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js
node --version
npm --version

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
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Certbot for SSL
sudo apt install -y certbot python3-certbot-nginx

# Configure Firewall
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

echo "✅ Basic setup complete!"
```

---

### Step 3: Clone Backend Repository

**Option A: If backend is in a separate repository**
```bash
cd ~
git clone <your-backend-repo-url> silah-backend
cd silah-backend
npm install
```

**Option B: If backend is in the same repository**
```bash
cd ~
git clone https://github.com/kxaviera/silah_app.git silah-app
cd silah-app
# Navigate to backend directory if it exists
# npm install
```

---

### Step 4: Create Environment File

```bash
cd ~/silah-backend  # or wherever your backend is
nano .env
```

**Add this configuration (update with your actual values):**

```env
# Server Configuration
NODE_ENV=production
PORT=5000
API_URL=http://88.222.241.43

# MongoDB
MONGODB_URI=mongodb://localhost:27017/silah

# JWT Secret (Generate with: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
JWT_SECRET=<generate-random-64-char-string>
JWT_EXPIRES_IN=7d

# Google OAuth (if using)
GOOGLE_CLIENT_ID=<your-google-client-id>
GOOGLE_CLIENT_SECRET=<your-google-client-secret>

# Stripe (if using)
STRIPE_SECRET_KEY=sk_live_<your-key>
STRIPE_PUBLISHABLE_KEY=pk_live_<your-key>

# SendGrid (if using)
SENDGRID_API_KEY=SG.<your-key>
SENDGRID_FROM_EMAIL=noreply@yourdomain.com

# Firebase (for push notifications)
FIREBASE_PROJECT_ID=<your-project-id>
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n<key>\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=<service-account-email>

# File Upload
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=5242880

# CORS (update with your domain when you have one)
CORS_ORIGIN=http://88.222.241.43,https://yourdomain.com

# Admin
ADMIN_JWT_SECRET=<generate-another-random-64-char-string>
ADMIN_DEFAULT_EMAIL=admin@yourdomain.com
ADMIN_DEFAULT_PASSWORD=<secure-password>
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

**Copy the output and add to your `.env` file.**

---

### Step 6: Create Uploads Directory

```bash
mkdir -p uploads
chmod 755 uploads
```

---

### Step 7: Build and Start Backend

```bash
# Build (if TypeScript)
npm run build

# Start with PM2
pm2 start dist/server.js --name silah-backend
# Or if JavaScript directly:
# pm2 start server.js --name silah-backend

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

### Step 8: Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/silah-backend
```

**Add this configuration:**

```nginx
server {
    listen 80;
    server_name 88.222.241.43;

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
        alias /root/silah-backend/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

**Save:** `Ctrl+X`, then `Y`, then `Enter`

**Enable the site:**

```bash
sudo ln -s /etc/nginx/sites-available/silah-backend /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

---

### Step 9: Test Backend

```bash
# Test API endpoint
curl http://88.222.241.43/api/settings

# Check PM2 status
pm2 status

# View logs
pm2 logs silah-backend
```

---

### Step 10: Update Frontend API URL

**In your Flutter app (`lib/core/app_config.dart`):**

```dart
case 'production':
  return 'http://88.222.241.43/api'; // Your VPS IP
```

**Or if you have a domain:**

```dart
case 'production':
  return 'https://api.yourdomain.com/api'; // Your domain
```

---

## 🔒 Optional: Setup SSL (If you have a domain)

If you have a domain pointing to this IP:

```bash
sudo certbot --nginx -d api.yourdomain.com
```

Then update frontend to use `https://api.yourdomain.com/api`

---

## ✅ Verification Checklist

- [ ] Backend is running: `pm2 status`
- [ ] MongoDB is running: `sudo systemctl status mongod`
- [ ] Nginx is running: `sudo systemctl status nginx`
- [ ] API is accessible: `curl http://88.222.241.43/api/settings`
- [ ] Frontend API URL is updated
- [ ] Environment variables are set

---

## 🐛 Troubleshooting

### Backend not starting
```bash
pm2 logs silah-backend --lines 50
```

### Nginx 502 error
```bash
sudo tail -f /var/log/nginx/error.log
pm2 status
```

### Port already in use
```bash
sudo lsof -i :5000
```

---

**Ready to start?** Connect to your VPS and run Step 1!
