# Backend Deployment - Current Status & Next Steps

## ✅ Current Status

- ✅ PM2 installed (v6.0.14)
- ❌ TypeScript not built (`dist/` missing)
- ❌ Uploads directory missing
- ❌ MongoDB not installed/running
- ❌ Backend not running

---

## 🔧 Step-by-Step Fix

### Step 1: Build TypeScript

```bash
cd /var/www/silah_app/backend
npm run build
```

**Expected:** Creates `dist/` folder with `server.js`

---

### Step 2: Create Uploads Directory

```bash
mkdir -p uploads/profile-photos
chmod -R 755 uploads
```

---

### Step 3: Install MongoDB

```bash
# Install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb

# Start MongoDB
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Verify MongoDB is running
sudo systemctl status mongodb
```

**Alternative:** If MongoDB installation fails, check if it's already installed with a different name:
```bash
# Check if MongoDB is running on default port
sudo netstat -tlnp | grep 27017

# Or check for mongod process
ps aux | grep mongod
```

---

### Step 4: Verify .env File

```bash
# Check if .env has required values (don't show secrets!)
cd /var/www/silah_app/backend
grep -E "^NODE_ENV|^PORT|^MONGODB_URI" .env
```

**Required values:**
- `NODE_ENV=production`
- `PORT=5000`
- `MONGODB_URI=mongodb://localhost:27017/silah`
- `JWT_SECRET=` (should have a value)
- `ADMIN_JWT_SECRET=` (should have a value)

---

### Step 5: Start Backend with PM2

```bash
cd /var/www/silah_app/backend

# Start backend
pm2 start dist/server.js --name silah-backend

# Check status
pm2 status

# View logs
pm2 logs silah-backend --lines 50
```

**Expected:** Backend should show as `online` and logs should show "Server running on port 5000"

---

### Step 6: Save PM2 Configuration

```bash
# Save PM2 process list
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Copy and run the command it shows you (usually starts with 'sudo env PATH=...')
```

---

### Step 7: Configure Nginx for Backend API

```bash
# Create Nginx config
sudo nano /etc/nginx/sites-available/api.rewardo.fun
```

**Paste this:**

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

**Enable:**
```bash
sudo ln -s /etc/nginx/sites-available/api.rewardo.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### Step 8: Install SSL Certificate

```bash
sudo certbot --nginx -d api.rewardo.fun
```

---

## 🚀 Quick Command Sequence

Run these in order:

```bash
# 1. Build TypeScript
cd /var/www/silah_app/backend
npm run build

# 2. Create uploads directory
mkdir -p uploads/profile-photos
chmod -R 755 uploads

# 3. Install MongoDB
sudo apt-get install -y mongodb
sudo systemctl start mongodb
sudo systemctl enable mongodb

# 4. Start backend
pm2 start dist/server.js --name silah-backend
pm2 save
pm2 startup  # Run the command it shows

# 5. Check status
pm2 status
pm2 logs silah-backend
```

---

**Start with Step 1 (build TypeScript) and share any errors!**
