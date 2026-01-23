# Node.js Upgrade - Troubleshooting Guide

## 🔍 Current Status

The NodeSource setup script is running. The MongoDB repo error (404) is not critical - it won't affect Node.js installation.

---

## ✅ Continue with Installation

After the setup script completes, run:

```bash
# Install Node.js 20
sudo apt-get install -y nodejs

# Verify
node --version
npm --version
```

---

## ⚠️ If MongoDB Repo Error Causes Issues

**Fix MongoDB repo (optional - only if causing problems):**

```bash
# Remove problematic MongoDB repo
sudo rm /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update apt
sudo apt-get update
```

---

## 📋 Complete Commands (After Setup Script Finishes)

```bash
# 1. Install Node.js 20
sudo apt-get install -y nodejs

# 2. Verify installation
node --version
# Expected: v20.x.x

npm --version
# Expected: 10.x.x

# 3. Clean and build admin dashboard
cd /var/www/silah_app/admin-dashboard
rm -rf node_modules package-lock.json
npm install
npm run build

# 4. Set permissions
sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist

# 5. Verify build
ls -la /var/www/silah_app/admin-dashboard/dist/
```

---

## 🔄 If Node.js Installation Fails

**Try alternative method:**

```bash
# Remove NodeSource repo
sudo rm -f /etc/apt/sources.list.d/nodesource.list

# Use NVM instead
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
nvm alias default 20

# Verify
node --version
```

---

## 📝 Expected Output

**After successful Node.js 20 installation:**

```bash
$ node --version
v20.18.0

$ npm --version
10.8.2
```

**After successful build:**

```bash
$ npm run build
> admin-dashboard@0.0.0 build
> tsc -b && vite build

vite v7.3.1 building for production...
✓ 123 modules transformed.
dist/index.html                   0.45 kB
dist/assets/index-abc123.js       245.67 kB
dist/assets/index-def456.css      12.34 kB
✓ built in 45s
```

---

**Last Updated:** 2025-01-22
