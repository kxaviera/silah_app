#!/bin/bash
# Auto-deployment script for Silah App
# This script will be triggered automatically when code is pushed to git

set -e  # Exit on error

# Log file
LOG_FILE="/var/log/silah-deploy.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "🚀 Starting automatic deployment..."
echo "📅 $(date)"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="/var/www/silah_app"
cd "$PROJECT_DIR" || {
    echo -e "${RED}❌ Cannot access project directory${NC}"
    exit 1
}

# Pull latest code
echo -e "${YELLOW}📥 Pulling latest code from git...${NC}"
git pull origin main || {
    echo -e "${RED}❌ Git pull failed${NC}"
    exit 1
}
echo -e "${GREEN}✅ Code pulled successfully${NC}"

# Update Backend
echo -e "${YELLOW}🔧 Updating Backend...${NC}"
cd "$PROJECT_DIR/backend" || exit 1

echo "Installing dependencies (including dev dependencies for TypeScript build)..."
npm install || {
    echo -e "${RED}❌ Backend npm install failed${NC}"
    exit 1
}

echo "Building TypeScript..."
npm run build || {
    echo -e "${RED}❌ Backend build failed${NC}"
    exit 1
}

# Restart backend with PM2
echo -e "${YELLOW}🔄 Restarting backend...${NC}"
if pm2 list | grep -q "silah-backend"; then
    pm2 restart silah-backend
else
    pm2 start dist/server.js --name silah-backend
    pm2 save
fi
echo -e "${GREEN}✅ Backend restarted${NC}"

# Update Admin Dashboard
echo -e "${YELLOW}🎨 Updating Admin Dashboard...${NC}"
cd "$PROJECT_DIR/admin-dashboard" || exit 1

echo "Installing dependencies..."
npm install || {
    echo -e "${RED}❌ Admin dashboard npm install failed${NC}"
    exit 1
}

echo "Building admin dashboard..."
npm run build || {
    echo -e "${RED}❌ Admin dashboard build failed${NC}"
    exit 1
}

echo "Setting permissions..."
sudo chown -R www-data:www-data dist
echo -e "${GREEN}✅ Admin dashboard updated${NC}"

# Reload Nginx
echo -e "${YELLOW}🔄 Reloading Nginx...${NC}"
sudo systemctl reload nginx || {
    echo -e "${RED}❌ Nginx reload failed${NC}"
    exit 1
}
echo -e "${GREEN}✅ Nginx reloaded${NC}"

# Verify services
echo -e "${YELLOW}✅ Verifying services...${NC}"
pm2 status

# Health check
if curl -f https://api.rewardo.fun/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is healthy${NC}"
else
    echo -e "${YELLOW}⚠️  Backend health check failed (may need a moment to start)${NC}"
fi

echo "=========================================="
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo "📅 $(date)"
echo "=========================================="
