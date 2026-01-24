# Audit Summary & Git Push Instructions

## ✅ Audit Complete (Block/Unblock + Delete Profile)

### Backend
- **Block/Unblock:** User `blockedUsers`, block controller, `/api/block` routes, message send block check ✅
- **Delete Profile:** User `deletedAt` / `deletionReason` / `deletionOtherReason`, `POST /api/auth/delete-account`, soft-delete ✅
- **Auth:** Login & middleware reject inactive users ✅

### Flutter
- **Block/Unblock:** `BlockApi`, chat screen Block/Unblock menu & UI, `_iBlockedThem` / `_theyBlockedMe` ✅
- **Delete Profile:** `AuthApi.deleteAccount`, `showDeleteProfileDialog` (reasons + Other), Settings & Profile "Delete profile" ✅

### Admin
- Admin block/unblock (account-level) unchanged; separate from user-to-user chat block ✅

---

## Git Push (run locally)

**If `git add` fails with "index.lock exists":**
1. Close Cursor/VS Code, Git GUI, and any other git clients.
2. Delete the lock file:
   ```powershell
   Remove-Item -Force "d:\Silah\SIlah\.git\index.lock" -ErrorAction SilentlyContinue
   ```
3. Retry the commands below.

**Stage, commit, and push:**

```powershell
cd "d:\Silah\SIlah"

git add admin-dashboard/src/pages/Settings.tsx `
  android/app/build.gradle.kts `
  android/RELEASE_SIGNING.md `
  android/key.properties.example `
  backend/src/controllers/auth.controller.ts `
  backend/src/controllers/block.controller.ts `
  backend/src/controllers/message.controller.ts `
  backend/src/controllers/profile.controller.ts `
  backend/src/controllers/request.controller.ts `
  backend/src/models/User.model.ts `
  backend/src/routes/auth.routes.ts `
  backend/src/routes/block.routes.ts `
  backend/src/server.ts `
  lib/core/auth_api.dart `
  lib/core/block_api.dart `
  lib/main.dart `
  lib/ui/screens/ad_detail_screen.dart `
  lib/ui/screens/boost_activity_screen.dart `
  lib/ui/screens/chat_screen.dart `
  lib/ui/screens/complete_profile_screen.dart `
  lib/ui/screens/discover_screen.dart `
  lib/ui/screens/help_screen.dart `
  lib/ui/screens/help_detail_screen.dart `
  lib/ui/screens/login_screen.dart `
  lib/ui/screens/messages_screen.dart `
  lib/ui/screens/notifications_screen.dart `
  lib/ui/screens/profile_screen.dart `
  lib/ui/screens/settings_screen.dart `
  lib/ui/screens/signup_screen.dart `
  lib/ui/screens/splash_screen.dart `
  lib/ui/shell/app_shell.dart `
  lib/utils/boost_dialog.dart `
  lib/utils/delete_profile_dialog.dart `
  pubspec.yaml `
  BLOCK_UNBLOCK_AUDIT.md

git status

git commit -m "feat: block/unblock chat, delete profile with reasons, audit

- Block/unblock: User blockedUsers, /api/block, chat UI Block/Unblock
- Delete profile: soft-delete + reasons (found match Silah/elsewhere, not interested, privacy, break, other)
- Settings & Profile: Delete profile → dialog with reasons → clear token, navigate to Login
- Auth: deleteAccount, POST /auth/delete-account
- Audit doc: block/unblock + delete profile"

git push origin main
```

**Optional (if you want to include more):**
- `assets/icons/app_icon.png` – if you updated the icon
- `VPS_UPDATE_NOW.md` – if you use it for ops
- `website/` – if you’re tracking the landing site in this repo

**Exclude from commit:**
- `website.zip` – build artifact
- `android/c` – accidental file
- `android/key.properties` – secrets (keep local only; already in .gitignore if configured)
