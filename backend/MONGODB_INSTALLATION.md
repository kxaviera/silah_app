# MongoDB Installation Guide for Ubuntu

## 🔧 Install MongoDB Community Edition

MongoDB is not in default Ubuntu repos. We need to install from MongoDB's official repository.

---

## Step 1: Import MongoDB Public GPG Key

```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
```

---

## Step 2: Add MongoDB Repository

```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

**Note:** If you're on Ubuntu 24.04 (Noble), use this instead:
```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

---

## Step 3: Update apt

```bash
sudo apt-get update
```

---

## Step 4: Install MongoDB

```bash
sudo apt-get install -y mongodb-org
```

---

## Step 5: Start MongoDB

```bash
# Start MongoDB
sudo systemctl start mongod

# Enable MongoDB to start on boot
sudo systemctl enable mongod

# Check status
sudo systemctl status mongod
```

**Note:** The service name is `mongod` (not `mongodb`)

---

## Step 6: Verify MongoDB is Running

```bash
# Check if MongoDB is listening on port 27017
sudo netstat -tlnp | grep 27017

# Or test MongoDB connection
mongosh --eval "db.version()"
```

---

## 🔄 Alternative: Quick Install Script

Run all commands at once:

```bash
# Import GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

# Add repository (for Ubuntu 24.04 Noble)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update and install
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

---

## ⚠️ Troubleshooting

### If repository error occurs:

**Check your Ubuntu version:**
```bash
lsb_release -a
```

**For Ubuntu 22.04 (Jammy):**
```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

**For Ubuntu 24.04 (Noble):**
```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

---

## ✅ After MongoDB is Installed

Continue with backend deployment:

```bash
cd /var/www/silah_app/backend
pm2 start dist/server.js --name silah-backend
pm2 save
pm2 startup
```

---

**Last Updated:** 2025-01-23
