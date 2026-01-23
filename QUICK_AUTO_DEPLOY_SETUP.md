# 🚀 Automatic Deployment Setup - Quick Guide

## One-Time Setup on VPS

Run these commands **once** on your VPS to enable automatic deployment:

```bash
# 1. Navigate to project
cd /var/www/silah_app

# 2. Pull latest code (includes deploy script)
git pull origin main

# 3. Make deployment script executable
chmod +x deploy-auto.sh

# 4. Set up git hook for automatic deployment
mkdir -p .git/hooks
cat > .git/hooks/post-receive << 'EOF'
#!/bin/bash
cd /var/www/silah_app
git pull origin main
bash deploy-auto.sh
EOF

chmod +x .git/hooks/post-receive

# 5. Configure git
git config core.worktree /var/www/silah_app
git config core.bare false

# 6. Test the deployment script
bash deploy-auto.sh
```

## How It Works

**After setup, every time you push to git:**

```bash
# On your local machine
git add .
git commit -m "Your changes"
git push origin main
```

**VPS automatically:**
1. ✅ Pulls latest code
2. ✅ Updates backend (npm install, build, restart)
3. ✅ Updates admin dashboard (npm install, build, reload nginx)
4. ✅ Verifies everything is working

**No need to SSH into VPS anymore!** 🎉

## View Deployment Logs

```bash
# On VPS
tail -f /var/log/silah-deploy.log
```

## Manual Deployment (if needed)

If you need to deploy manually:

```bash
cd /var/www/silah_app
bash deploy-auto.sh
```

## Troubleshooting

### If auto-deployment doesn't work:

```bash
# Check if hook exists
ls -la /var/www/silah_app/.git/hooks/post-receive

# Make sure it's executable
chmod +x /var/www/silah_app/.git/hooks/post-receive

# Test manually
cd /var/www/silah_app
bash deploy-auto.sh
```

### If git pull fails:

```bash
# Make sure you're on main branch
cd /var/www/silah_app
git checkout main
git pull origin main
```

---

**That's it!** After one-time setup, all future `git push` commands will automatically deploy to your VPS! 🚀
