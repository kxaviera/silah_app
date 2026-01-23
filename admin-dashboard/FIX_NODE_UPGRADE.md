# Fix Node.js Upgrade - NodeSource Repository Not Added

## 🔧 Problem

- Node.js is still v18.19.1
- System says "nodejs is already the newest version"
- NodeSource repository wasn't added properly
- MongoDB repo error blocking updates

---

## ✅ Solution: Fix MongoDB Repo First, Then Add NodeSource

### Step 1: Fix MongoDB Repository Error

```bash
# Remove problematic MongoDB repo
sudo rm /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update apt (should work now)
sudo apt-get update
```

---

### Step 2: Remove Old Node.js

```bash
# Remove Ubuntu's default Node.js
sudo apt-get remove -y nodejs npm

# Clean up
sudo apt-get autoremove -y
```

---

### Step 3: Add NodeSource Repository Properly

```bash
# Download and add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# If above fails, try this:
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# Update apt
sudo apt-get update
```

---

### Step 4: Install Node.js 20

```bash
# Install Node.js 20
sudo apt-get install -y nodejs

# Verify
node --version
# Should show: v20.x.x

npm --version
# Should show: 10.x.x
```

---

## 🔄 Alternative: Use NVM (Easier Method)

If NodeSource keeps failing, use NVM:

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
source ~/.bashrc

# Install Node.js 20
nvm install 20
nvm use 20
nvm alias default 20

# Verify
node --version
# Should show: v20.x.x

# Make sure it's in PATH
which node
# Should show: /root/.nvm/versions/node/v20.x.x/bin/node
```

---

## 📋 Complete Fix Commands

**Option 1: Fix NodeSource (Recommended)**

```bash
# 1. Fix MongoDB repo
sudo rm /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update

# 2. Remove old Node.js
sudo apt-get remove -y nodejs npm
sudo apt-get autoremove -y

# 3. Add NodeSource repo
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# 4. Install Node.js 20
sudo apt-get install -y nodejs

# 5. Verify
node --version
npm --version
```

**Option 2: Use NVM (If NodeSource fails)**

```bash
# 1. Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

# 2. Install Node.js 20
nvm install 20
nvm use 20
nvm alias default 20

# 3. Verify
node --version
npm --version
```

---

## 🚀 After Node.js 20 is Installed

```bash
# Build admin dashboard
cd /var/www/silah_app/admin-dashboard
rm -rf node_modules package-lock.json
npm install
npm run build

# Set permissions
sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist

# Verify
ls -la /var/www/silah_app/admin-dashboard/dist/
```

---

## ⚠️ Important Notes

1. **MongoDB repo error** - Remove it first, it's blocking apt updates
2. **NodeSource vs NVM** - NVM is easier and doesn't require sudo
3. **Current npm install** - It's running but will have warnings. You can let it finish, but rebuild after upgrading Node.js for best results.

---

**Last Updated:** 2025-01-22
