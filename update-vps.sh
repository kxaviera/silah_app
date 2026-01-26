#!/bin/bash
# VPS Update Script - Run this on your VPS after git push
# Usage: ./update-vps.sh

set -e  # Exit on error

echo "🚀 Updating Silah App on VPS..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Navigate to project
cd /var/www/silah_app

# Step 1: Pull latest code
echo -e "${YELLOW}📥 Pulling latest code from git...${NC}"
git pull origin main
echo -e "${GREEN}✅ Code pulled${NC}"

# Step 2: Update Backend
echo -e "${YELLOW}📦 Updating backend...${NC}"
cd backend
npm install
npm run build
pm2 restart silah-backend
echo -e "${GREEN}✅ Backend updated and restarted${NC}"

# Step 3: Update Admin Dashboard
echo -e "${YELLOW}📦 Updating admin dashboard...${NC}"
cd ../admin-dashboard
npm install
npm run build
sudo chown -R www-data:www-data dist
sudo systemctl reload nginx
echo -e "${GREEN}✅ Admin dashboard updated${NC}"

# Step 4: Check status
echo -e "${YELLOW}📊 Checking services...${NC}"
pm2 status
echo ""
echo -e "${GREEN}✅ Update complete!${NC}"
echo ""
echo "Verify:"
echo "  - Backend: curl https://api.rewardo.fun/health"
echo "  - Admin: https://admin.rewardo.fun"
