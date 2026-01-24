# Git Push - Stage all updated code (backend, admin, Flutter, assets), commit, push.
# Run in PowerShell. Close Cursor/VS Code first if you get "index.lock" errors.

cd "d:\Silah\SIlah"

if (Test-Path .git/index.lock) {
    Remove-Item -Force .git/index.lock
    Write-Host "Removed index.lock"
}

git add -A
Write-Host "`nStaged:"
git status --short

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host "`nNothing to commit."
    exit 0
}

Write-Host "`nCommitting..."
git commit -m "chore: push all updated code (backend, admin, Flutter, assets)

- Backend, admin dashboard, Flutter app updates
- Assets (app icon), docs, scripts"

Write-Host "`nPushing to origin/main..."
git push origin main
Write-Host "`nDone!"
