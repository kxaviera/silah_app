# Next Steps After Removing Node.js v18

## ✅ Completed
- ✅ Removed Node.js v18.19.1
- ✅ Removed all Node.js dependencies

---

## 🔄 Next Steps (After Reconnecting to VPS)

### Step 1: Add NodeSource Repository

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
```

**Expected output:**
```
## Installing the NodeSource Node.js 20.x repo...

## Populating apt-get cache...

+ apt-get update
...
```

---

### Step 2: Update apt

```bash
sudo apt-get update
```

---

### Step 3: Install Node.js 20

```bash
sudo apt-get install -y nodejs
```

**Expected output:**
```
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  nodejs
...
Setting up nodejs (20.x.x-1nodesource1) ...
```

---

### Step 4: Verify Installation

```bash
node --version
# Should show: v20.x.x

npm --version
# Should show: 10.x.x
```

---

### Step 5: Build Admin Dashboard

```bash
cd /var/www/silah_app/admin-dashboard
rm -rf node_modules package-lock.json
npm install
npm run build
```

**Expected output:**
```
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

### Step 6: Set Permissions

```bash
sudo chown -R www-data:www-data /var/www/silah_app/admin-dashboard/dist
```

---

### Step 7: Verify Build Output

```bash
ls -la /var/www/silah_app/admin-dashboard/dist/
```

**Should see:**
```
index.html
assets/
```

---

## 🔄 Alternative: If NodeSource Fails, Use NVM

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
npm --version
```

---

## ⚠️ Troubleshooting

**If `curl` command fails:**
```bash
# Install curl if missing
sudo apt-get install -y curl
```

**If NodeSource repo fails:**
- Use NVM method (see above)
- Or manually add repo:
```bash
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install -y nodejs
```

---

**Last Updated:** 2025-01-22
