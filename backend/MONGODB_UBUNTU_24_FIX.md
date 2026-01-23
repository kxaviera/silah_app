# MongoDB Installation - Ubuntu 24.04 Fix

## ⚠️ Issue

MongoDB 7.0 doesn't have official support for Ubuntu 24.04 (Noble) yet. We'll use Ubuntu 22.04 (Jammy) repository or MongoDB 6.0.

---

## ✅ Solution 1: Use Ubuntu 22.04 (Jammy) Repository

```bash
# Remove the problematic repository
sudo rm /etc/apt/sources.list.d/mongodb-org-7.0.list

# Add Ubuntu 22.04 (Jammy) repository (works on Ubuntu 24.04)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update apt
sudo apt-get update

# Install MongoDB
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

---

## ✅ Solution 2: Use MongoDB 6.0 (Recommended for Ubuntu 24.04)

```bash
# Remove the problematic repository
sudo rm /etc/apt/sources.list.d/mongodb-org-7.0.list

# Import MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor

# Add MongoDB 6.0 repository (using Jammy)
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Update apt
sudo apt-get update

# Install MongoDB 6.0
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

---

## ✅ Solution 3: Use Docker (Easiest)

If repository issues persist, use Docker:

```bash
# Install Docker (if not installed)
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Run MongoDB in Docker
sudo docker run -d \
  --name mongodb \
  --restart always \
  -p 27017:27017 \
  -v /var/lib/mongodb:/data/db \
  mongo:7.0

# Verify MongoDB is running
sudo docker ps | grep mongodb
```

**Update .env file:**
```env
MONGODB_URI=mongodb://localhost:27017/silah
```

---

## 🔍 Verify MongoDB Installation

```bash
# Check if MongoDB is running
sudo systemctl status mongod

# Or if using Docker
sudo docker ps | grep mongodb

# Test MongoDB connection
mongosh --eval "db.version()"

# Or if mongosh not installed
mongo --eval "db.version()"
```

---

## 📋 Quick Fix Commands (Try Solution 1 First)

```bash
# Remove problematic repo
sudo rm /etc/apt/sources.list.d/mongodb-org-7.0.list

# Add Jammy repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update and install
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
sudo systemctl status mongod
```

---

**Try Solution 1 first (using Jammy repository). If that doesn't work, try Solution 2 (MongoDB 6.0) or Solution 3 (Docker).**
