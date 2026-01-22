# Repository Structure - silah_app

**GitHub Repository:** `https://github.com/kxaviera/silah_app.git`

---

## 📁 Repository Structure

```
silah_app/
├── admin-dashboard/          ← Admin Dashboard (React/TypeScript)
│   ├── src/
│   │   ├── components/
│   │   ├── context/
│   │   ├── pages/
│   │   └── services/
│   ├── package.json
│   ├── vite.config.ts
│   └── README.md
│
├── lib/                      ← Flutter App (Dart/Flutter)
│   ├── core/
│   │   ├── api_client.dart
│   │   ├── app_config.dart
│   │   └── ...
│   ├── ui/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── shell/
│   └── main.dart
│
├── android/                  ← Flutter Android platform
├── ios/                      ← Flutter iOS platform
├── web/                      ← Flutter Web platform
├── windows/                  ← Flutter Windows platform
├── linux/                    ← Flutter Linux platform
├── macos/                    ← Flutter macOS platform
│
├── assets/                   ← App assets (icons, logos, images)
├── pubspec.yaml              ← Flutter dependencies
├── README.md                 ← Main README
└── [various .md files]       ← Documentation files
```

---

## 📍 Component Locations

### 1. **Admin Dashboard**
**Location:** `silah_app/admin-dashboard/`

**Type:** React + TypeScript + Vite + Material-UI

**Key Files:**
- `admin-dashboard/src/services/api.ts` - API configuration
- `admin-dashboard/src/pages/` - All admin pages
- `admin-dashboard/package.json` - Dependencies
- `admin-dashboard/vite.config.ts` - Vite configuration

**Deployment:**
- Build: `cd admin-dashboard && npm run build`
- Output: `admin-dashboard/dist/`
- Deploy to: `admin.rewardo.fun`

---

### 2. **Flutter App**
**Location:** `silah_app/lib/`

**Type:** Flutter (Dart)

**Key Files:**
- `lib/core/app_config.dart` - Environment configuration
- `lib/core/api_client.dart` - API client
- `lib/ui/screens/` - All app screens
- `lib/core/*_api.dart` - API service files

**Deployment:**
- Build: `flutter build apk --release --dart-define=ENV=production`
- Output: `build/app/outputs/flutter-apk/app-release.apk`

---

### 3. **Backend**
**Location:** `D:\Silah\Backend` (NOT in this repository)

**Type:** Node.js + Express + TypeScript

**Note:** The backend is in a **separate directory** and should be in its own repository or deployed separately.

**If you want to include backend in this repo, structure would be:**
```
silah_app/
├── backend/                  ← Backend (if added to repo)
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   └── server.ts
│   ├── package.json
│   └── .env
│
├── admin-dashboard/
└── lib/
```

---

## 🔍 Current Structure Summary

| Component | Location in Repo | Type | Status |
|-----------|------------------|------|--------|
| **Admin Dashboard** | `silah_app/admin-dashboard/` | React/TS | ✅ In repo |
| **Flutter App** | `silah_app/lib/` | Flutter/Dart | ✅ In repo |
| **Backend** | `D:\Silah\Backend` | Node.js/TS | ❌ Separate location |

---

## 📦 What's in the Repository

### ✅ Included:
- ✅ Admin Dashboard (complete React app)
- ✅ Flutter App (complete mobile app)
- ✅ Flutter platform folders (android, ios, web, etc.)
- ✅ Assets (icons, logos, images)
- ✅ Documentation files

### ❌ Not Included:
- ❌ Backend code (in separate `D:\Silah\Backend` directory)
- ❌ `.env` files (should not be committed)
- ❌ `node_modules/` (excluded by .gitignore)
- ❌ `build/` folders (excluded by .gitignore)

---

## 🚀 Deployment Paths

### Admin Dashboard
```bash
# On VPS
cd /var/www
git clone https://github.com/kxaviera/silah_app.git
cd silah_app/admin-dashboard
npm install
npm run build
# Deploy dist/ to admin.rewardo.fun
```

### Flutter App
```bash
# On local machine
git clone https://github.com/kxaviera/silah_app.git
cd silah_app
flutter build apk --release --dart-define=ENV=production
# Install APK on devices
```

### Backend
```bash
# Backend is separate - deploy from D:\Silah\Backend
# Or create separate backend repository
```

---

## 📝 Recommendations

### Option 1: Keep Backend Separate (Current)
- ✅ Backend in separate directory/repo
- ✅ Frontend and admin dashboard in this repo
- ✅ Easier to manage separately

### Option 2: Add Backend to This Repo
If you want everything in one repo:
```
silah_app/
├── backend/          ← Add backend here
├── admin-dashboard/
└── lib/
```

**To add backend:**
```bash
cd D:\Silah\SIlah
mkdir backend
# Copy D:\Silah\Backend contents to backend/
git add backend/
git commit -m "Add backend to repository"
git push
```

---

## 🔗 Quick Reference

**Admin Dashboard Path:** `silah_app/admin-dashboard/`  
**Flutter App Path:** `silah_app/lib/`  
**Backend Path:** `D:\Silah\Backend` (separate)  
**GitHub Repo:** `https://github.com/kxaviera/silah_app.git`

---

**Last Updated:** 2025-01-22
