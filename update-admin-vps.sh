#!/bin/bash
# Update Admin Dashboard on VPS only
# Run on VPS: ./update-admin-vps.sh

set -e

echo "📦 Updating Admin Dashboard on VPS..."

cd /var/www/silah_app

echo "📥 Pulling latest code..."
git pull origin main

echo "📦 Building admin dashboard..."
cd admin-dashboard
npm install
npm run build

echo "🔒 Setting permissions..."
sudo chown -R www-data:www-data dist

echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

echo "✅ Admin dashboard updated!"
echo ""
echo "Verify: https://admin.rewardo.fun"
