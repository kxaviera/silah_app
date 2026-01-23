# Update Admin Dashboard on VPS

## Quick Update Commands

Run these commands on your VPS to update the admin dashboard with the latest changes:

```bash
# 1. Navigate to project directory
cd /var/www/silah_app

# 2. Pull latest code from Git
git pull origin main

# 3. Navigate to admin dashboard
cd admin-dashboard

# 4. Install any new dependencies (if needed)
npm install

# 5. Build the admin dashboard
npm run build

# 6. Set correct permissions
sudo chown -R www-data:www-data dist

# 7. Reload Nginx to serve the new build
sudo systemctl reload nginx

# 8. Verify the build was successful
ls -la dist/
```

## One-Line Command (Copy & Paste)

```bash
cd /var/www/silah_app && git pull origin main && cd admin-dashboard && npm install && npm run build && sudo chown -R www-data:www-data dist && sudo systemctl reload nginx && echo "✅ Admin dashboard updated successfully!"
```

## Verify Update

After running the commands, check:
1. Visit `https://admin.rewardo.fun` in your browser
2. Check if the new fields are visible (Current Status, Physical Status, Family Details section)
3. View a user detail page to see the Family Details section

## Troubleshooting

If you encounter any errors:

```bash
# Check Node.js version (should be 20.x)
node --version

# If Node.js is outdated, upgrade it:
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Check if build directory exists
ls -la /var/www/silah_app/admin-dashboard/dist/

# Check Nginx status
sudo systemctl status nginx

# Check Nginx error logs
sudo tail -f /var/log/nginx/admin.rewardo.fun.error.log
```
