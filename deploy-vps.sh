#!/bin/bash

# Silah Backend - Quick VPS Deployment Script
# Run this script on your VPS server

set -e  # Exit on error

echo "🚀 Starting Silah Backend Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Update system
echo -e "${YELLOW}📦 Updating system packages...${NC}"
apt update && apt upgrade -y

# Install Node.js 18.x
echo -e "${YELLOW}📦 Installing Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Verify Node.js installation
NODE_VERSION=$(node --version)
echo -e "${GREEN}✅ Node.js installed: $NODE_VERSION${NC}"

# Install MongoDB
echo -e "${YELLOW}📦 Installing MongoDB...${NC}"
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt update
apt install -y mongodb-org

# Start MongoDB
systemctl start mongod
systemctl enable mongod
echo -e "${GREEN}✅ MongoDB installed and started${NC}"

# Install PM2
echo -e "${YELLOW}📦 Installing PM2...${NC}"
npm install -g pm2
echo -e "${GREEN}✅ PM2 installed${NC}"

# Install Nginx
echo -e "${YELLOW}📦 Installing Nginx...${NC}"
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo -e "${GREEN}✅ Nginx installed and started${NC}"

# Install Certbot for SSL
echo -e "${YELLOW}📦 Installing Certbot...${NC}"
apt install -y certbot python3-certbot-nginx
echo -e "${GREEN}✅ Certbot installed${NC}"

# Configure Firewall
echo -e "${YELLOW}🔥 Configuring firewall...${NC}"
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
echo -e "${GREEN}✅ Firewall configured${NC}"

echo -e "${GREEN}✅ Basic setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Clone your backend repository:"
echo "   cd ~ && git clone <your-repo-url> silah-backend"
echo ""
echo "2. Navigate to backend directory:"
echo "   cd silah-backend"
echo ""
echo "3. Install dependencies:"
echo "   npm install"
echo ""
echo "4. Create .env file with your configuration"
echo ""
echo "5. Build the project (if TypeScript):"
echo "   npm run build"
echo ""
echo "6. Start with PM2:"
echo "   pm2 start dist/server.js --name silah-backend"
echo "   pm2 save"
echo "   pm2 startup"
echo ""
echo "7. Configure Nginx (see VPS_DEPLOYMENT_GUIDE.md)"
echo ""
echo "8. Install SSL certificate:"
echo "   certbot --nginx -d api.yourdomain.com"
echo ""
