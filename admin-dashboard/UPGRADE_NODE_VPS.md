# Upgrade Node.js on VPS for Admin Dashboard Build

## 🔧 Problem

- **Current Node.js:** v18.19.1
- **Required:** Node.js ^20.19.0 or >=22.12.0 (for Vite 7, React Router 7)

---

## ✅ Solution: Upgrade Node.js to v20

### Step 1: Remove Old Node.js (Optional)

```bash
# Check current version
node --version
# v18.19.1

# Remove old NodeSource repo if exists
sudo rm -f /etc/apt/sources.list.d/nodesource.list
```

---

### Step 2: Install Node.js 20 via NodeSource

```bash
# Download and run NodeSource setup script for Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js 20
sudo apt-get install -y nodejs

# Verify installation
node --version
# Should show: v20.x.x

npm --version
# Should show: 10.x.x or similar
```

---

### Step 3: Build Admin Dashboard

```bash
cd /var/www/silah_app/admin-dashboard

# Clean previous install (if any)
rm -rf node_modules package-lock.json

# Install dependencies
npm install

# Build
npm run build
```

---

### Step 4: Verify Build

```bash
ls -la /var/www/silah_app/admin-dashboard/dist/
```

Should show `index.html` and `assets/` folder.

---

## 🔄 Alternative: Using NVM (Node Version Manager)

If you prefer NVM to manage Node versions:

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

# Install Node.js 20
nvm install 20
nvm use 20

# Verify
node --version
# v20.x.x

# Then build
cd /var/www/silah_app/admin-dashboard
rm -rf node_modules
npm install
npm run build
```

---

## 📋 Quick Copy-Paste Commands

```bash
# 1. Upgrade Node.js to 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Verify
node --version
npm --version

# 3. Build admin dashboard
cd /var/www/silah_app/admin-dashboard
rm -rf node_modules
npm install
npm run build

# 4. Set permissions
sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist

# 5. Verify build
ls -la /var/www/silah_app/admin-dashboard/dist/
```

---

## ⚠️ If SSH Connection Drops During npm install

**Use `screen` or `tmux` to keep the session alive:**

```bash
# Install screen
sudo apt-get install -y screen

# Start screen session
screen -S build

# Run commands (if SSH drops, reconnect and run: screen -r build)
cd /var/www/silah_app/admin-dashboard
npm install
npm run build

# Detach from screen: Ctrl+A, then D
# Reattach: screen -r build
```

**Or use `nohup`:**

```bash
cd /var/www/silah_app/admin-dashboard
nohup npm install > npm_install.log 2>&1 &
nohup npm run build > npm_build.log 2>&1 &

# Check progress
tail -f npm_install.log
tail -f npm_build.log
```

---

## 🔍 Troubleshooting

### "E: Unable to locate package nodejs" after NodeSource setup

```bash
sudo apt-get update
sudo apt-get install -y nodejs
```

### Permission errors during npm install

```bash
# Run as root (you're already root) - should be fine
# Or fix npm cache permissions:
sudo chown -R $USER:$(id -gn $USER) ~/.npm
```

### Build fails with memory error

```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build
```

---

## ✅ Expected Output After Upgrade

```bash
$ node --version
v20.18.0

$ npm --version
10.8.2

$ npm run build
> admin-dashboard@0.0.0 build
> tsc -b && vite build
...
✓ built in 45s
```

---

**Last Updated:** 2025-01-22
