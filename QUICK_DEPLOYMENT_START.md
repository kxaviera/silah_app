# Quick Start: Backend Deployment

## 🚀 Fast Track Deployment

### Prerequisites Checklist

Before we start, please confirm:

- [ ] **VPS Server:** Do you have a VPS server? (IP address: ___________)
- [ ] **Domain Name:** Do you have a domain? (e.g., api.yourdomain.com)
- [ ] **SSH Access:** Can you SSH into your VPS? (`ssh root@your-vps-ip`)
- [ ] **Backend Code:** Is backend code ready? (Repository URL: ___________)
- [ ] **Environment Variables:** Do you have API keys ready? (JWT secret, Stripe, etc.)

---

## Option A: Automated Deployment (Recommended)

### Step 1: Upload Deployment Script

```bash
# From your local machine
scp deploy-vps.sh root@your-vps-ip:/root/
scp VPS_DEPLOYMENT_GUIDE.md root@your-vps-ip:/root/
```

### Step 2: SSH into VPS

```bash
ssh root@your-vps-ip
```

### Step 3: Run Deployment Script

```bash
chmod +x deploy-vps.sh
sudo ./deploy-vps.sh
```

### Step 4: Clone Backend Repository

```bash
cd ~
git clone <your-backend-repo-url> silah-backend
cd silah-backend
npm install
```

### Step 5: Configure Environment

```bash
# Create .env file
nano .env
# (Add your environment variables - see guide)
```

### Step 6: Start Backend

```bash
# Build (if TypeScript)
npm run build

# Start with PM2
pm2 start dist/server.js --name silah-backend
pm2 save
pm2 startup
```

---

## Option B: Manual Step-by-Step

Follow the detailed guide in `VPS_DEPLOYMENT_GUIDE.md`

---

## 🔧 Quick Configuration Template

### .env File Template

```env
# Server
NODE_ENV=production
PORT=5000
API_URL=https://api.yourdomain.com

# MongoDB
MONGODB_URI=mongodb://localhost:27017/silah

# JWT (Generate random strings)
JWT_SECRET=<generate-random-64-char-string>
JWT_EXPIRES_IN=7d

# Google OAuth
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

# CORS
CORS_ORIGIN=https://yourdomain.com

# Admin
ADMIN_JWT_SECRET=<generate-random-64-char-string>
ADMIN_DEFAULT_EMAIL=admin@yourdomain.com
ADMIN_DEFAULT_PASSWORD=<secure-password>
```

---

## 📞 Need Help?

**Tell me:**
1. Do you have a VPS server? (Yes/No)
2. What's your VPS IP address?
3. Do you have a domain name?
4. Is your backend code ready?

**I'll guide you through each step!**
