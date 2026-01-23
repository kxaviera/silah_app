#!/bin/bash
# Git post-receive hook for automatic deployment
# Place this file in: /var/www/silah_app/.git/hooks/post-receive
# Make it executable: chmod +x /var/www/silah_app/.git/hooks/post-receive

# This hook runs automatically after git push

PROJECT_DIR="/var/www/silah_app"
DEPLOY_SCRIPT="$PROJECT_DIR/deploy-auto.sh"

# Only deploy if pushing to main branch
while read oldrev newrev refname; do
    branch=$(git rev-parse --symbolic --abbrev-ref $refname)
    if [ "$branch" = "main" ]; then
        echo "🚀 Auto-deploying main branch..."
        bash "$DEPLOY_SCRIPT"
    fi
done
