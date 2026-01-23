# ✅ MongoDB Running - Continue Backend Deployment

## ✅ Completed

- ✅ MongoDB installed successfully
- ✅ MongoDB service is active (running)
- ✅ MongoDB enabled to start on boot

---

## 🚀 Next Steps

### Step 1: Create Uploads Directory

```bash
cd /var/www/silah_app/backend
mkdir -p uploads/profile-photos
chmod -R 755 uploads
```

---

### Step 2: Verify .env File

```bash
# Check if .env has required values (don't show secrets!)
cd /var/www/silah_app/backend
grep -E "^NODE_ENV|^PORT|^MONGODB_URI" .env | head -3
```

**Should show:**
- `NODE_ENV=production`
- `PORT=5000`
- `MONGODB_URI=mongodb://localhost:27017/silah`

---

### Step 3: Start Backend with PM2

```bash
cd /var/www/silah_app/backend

# Start backend
pm2 start dist/server.js --name silah-backend

# Check status
pm2 status

# View logs
pm2 logs silah-backend --lines 50
```

**Expected:**
- Backend should show as `online` in PM2
- Logs should show "Server running on port 5000" or "Connected to MongoDB"

---

### Step 4: Save PM2 Configuration

```bash
# Save PM2 process list
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Copy and run the command it shows you (usually starts with 'sudo env PATH=...')
```

---

### Step 5: Configure Nginx for Backend API

```bash
# Create Nginx config
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

**Enable:**
```bash
sudo ln -s /etc/nginx/sites-available/api.rewardo.fun /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### Step 6: Install SSL Certificate

```bash
sudo certbot --nginx -d api.rewardo.fun

# Follow prompts:
# - Enter email address
# - Agree to terms
# - Choose redirect HTTP to HTTPS (recommended: Yes)
```

---

### Step 7: Verify Backend is Working

```bash
# Test API endpoint
curl https://api.rewardo.fun/api/health

# Or test any endpoint
curl https://api.rewardo.fun/api/auth/health

# Check PM2 status
pm2 status

# Check logs
pm2 logs silah-backend --lines 50
```

---

## ✅ Verification Checklist

- [x] MongoDB installed and running
- [ ] Uploads directory created
- [ ] `.env` file configured
- [ ] Backend started with PM2
- [ ] PM2 configured to start on boot
- [ ] Nginx configured for `api.rewardo.fun`
- [ ] SSL certificate installed
- [ ] Backend accessible via `https://api.rewardo.fun`

---

**Start with Step 1 and work through each step!**
