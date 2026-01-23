# Automatic Deployment Setup Guide

## Option 1: Git Hook (Recommended - Automatic on every push)

### Step 1: Make deployment script executable
```bash
cd /var/www/silah_app
chmod +x deploy-auto.sh
```

### Step 2: Initialize git repository on VPS (if not already done)
```bash
cd /var/www/silah_app
git init
git remote add origin https://github.com/kxaviera/silah_app.git
git fetch origin
git checkout -b main origin/main
```

### Step 3: Set up post-receive hook
```bash
cd /var/www/silah_app
mkdir -p .git/hooks
cp git-hook-post-receive.sh .git/hooks/post-receive
chmod +x .git/hooks/post-receive
```

### Step 4: Configure git to use this directory as working tree
```bash
cd /var/www/silah_app
git config core.worktree /var/www/silah_app
git config core.bare false
```

**Now every time you push to main branch, it will automatically deploy!**

---

## Option 2: GitHub Webhook (Alternative)

### Step 1: Install webhook receiver on VPS
```bash
# Install webhook package (if not installed)
sudo apt-get update
sudo apt-get install -y webhook

# Create webhook config
sudo nano /etc/webhook.conf
```

### Step 2: Create webhook configuration
```bash
# Add to /etc/webhook.conf
[
  {
    "id": "silah-deploy",
    "execute-command": "/var/www/silah_app/deploy-auto.sh",
    "command-working-directory": "/var/www/silah_app",
    "response-message": "Deployment started"
  }
]
```

### Step 3: Start webhook service
```bash
sudo systemctl enable webhook
sudo systemctl start webhook
```

### Step 4: Configure GitHub Webhook
1. Go to: https://github.com/kxaviera/silah_app/settings/hooks
2. Add webhook:
   - Payload URL: `http://88.222.241.43:9000/hooks/silah-deploy`
   - Content type: `application/json`
   - Events: `Just the push event`
   - Active: ✅

---

## Option 3: Cron Job (Simple - Checks every 5 minutes)

```bash
# Edit crontab
crontab -e

# Add this line (checks git every 5 minutes and deploys if changes found)
*/5 * * * * cd /var/www/silah_app && git fetch origin && [ $(git rev-parse HEAD) != $(git rev-parse origin/main) ] && git pull origin main && cd backend && npm install --production && npm run build && pm2 restart silah-backend && cd ../admin-dashboard && npm install && npm run build && sudo chown -R www-data:www-data dist && sudo systemctl reload nginx
```

---

## Recommended: Option 1 (Git Hook)

This is the simplest and most reliable. After setup:

1. **Push code from your local machine:**
   ```bash
   git push origin main
   ```

2. **VPS automatically:**
   - Pulls latest code
   - Updates backend
   - Updates admin dashboard
   - Restarts services

**No manual VPS commands needed!**

---

## Testing Auto-Deployment

After setup, test it:

```bash
# Make a small change locally
echo "// Test" >> lib/main.dart

# Commit and push
git add .
git commit -m "Test auto-deployment"
git push origin main

# Watch VPS logs (in another terminal)
ssh root@88.222.241.43
tail -f /var/log/deploy.log  # If you add logging to deploy script
```

---

## Troubleshooting

### Git hook not working:
```bash
# Check hook exists and is executable
ls -la /var/www/silah_app/.git/hooks/post-receive
chmod +x /var/www/silah_app/.git/hooks/post-receive

# Test hook manually
cd /var/www/silah_app
bash .git/hooks/post-receive
```

### Permission issues:
```bash
# Make sure deploy script is executable
chmod +x /var/www/silah_app/deploy-auto.sh

# Check PM2 permissions
pm2 status
```

### Git pull fails:
```bash
# Make sure git is configured correctly
cd /var/www/silah_app
git remote -v
git status
```
