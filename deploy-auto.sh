#!/bin/bash
# Auto-deployment script for Silah App
# This script will be triggered automatically when code is pushed to git

set -e  # Exit on error

echo "🚀 Starting automatic deployment..."
echo "📅 $(date)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="/var/www/silah_app"
cd "$PROJECT_DIR" || exit 1

# Pull latest code
echo -e "${YELLOW}📥 Pulling latest code from git...${NC}"
git pull origin main || {
    echo -e "${RED}❌ Git pull failed${NC}"
    exit 1
}

# Update Backend
echo -e "${YELLOW}🔧 Updating Backend...${NC}"
cd "$PROJECT_DIR/backend" || exit 1
npm install --production
npm run build

# Restart backend with PM2
echo -e "${YELLOW}🔄 Restarting backend...${NC}"
pm2 restart silah-backend || pm2 start dist/server.js --name silah-backend

# Update Admin Dashboard
echo -e "${YELLOW}🎨 Updating Admin Dashboard...${NC}"
cd "$PROJECT_DIR/admin-dashboard" || exit 1
npm install
npm run build
sudo chown -R www-data:www-data dist

# Reload Nginx
echo -e "${YELLOW}🔄 Reloading Nginx...${NC}"
sudo systemctl reload nginx

# Verify services
echo -e "${YELLOW}✅ Verifying services...${NC}"
pm2 status
curl -f https://api.rewardo.fun/health > /dev/null && echo -e "${GREEN}✅ Backend is healthy${NC}" || echo -e "${RED}❌ Backend health check failed${NC}"

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo "📅 $(date)"
