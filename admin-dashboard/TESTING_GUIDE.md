# Admin Dashboard - Local Testing Guide

## 🚀 Quick Start

### Step 1: Navigate to Admin Dashboard

```bash
cd admin-dashboard
```

### Step 2: Install Dependencies (if not done)

```bash
npm install
```

### Step 3: Create Environment File

Create a `.env` file in the `admin-dashboard` folder:

```bash
# For local testing with backend on localhost:5000
VITE_API_URL=http://localhost:5000/api
```

**Or if your backend is on a different port:**
```bash
VITE_API_URL=http://localhost:3000/api
```

**Or if you want to test with the VPS backend:**
```bash
VITE_API_URL=http://88.222.241.43/api
```

### Step 4: Start Development Server

```bash
npm run dev
```

The dashboard will start at: **http://localhost:5173** (or another port if 5173 is busy)

---

## 🧪 Testing Scenarios

### Scenario 1: Test Without Backend (Quick Login)

**What happens:**
- Dashboard will load with mock/empty data
- **Quick Login button available for testing**
- You can see the UI and navigation

**To test:**
1. Open http://localhost:5173
2. You'll see the login page
3. Click **"Quick Login (Test Mode)"** button
   - Or manually enter: `admin@test.com` / `test123`
4. You'll be logged in and can see all pages with mock data
5. All navigation and UI features work without backend

### Scenario 2: Test With Local Backend

**Prerequisites:**
- Backend running on `http://localhost:5000`
- Admin API endpoints implemented
- At least one admin user created in database

**Steps:**
1. Start your backend server:
   ```bash
   # In your backend directory
   npm start
   # or
   node server.js
   ```

2. Ensure `.env` has:
   ```
   VITE_API_URL=http://localhost:5000/api
   ```

3. Start admin dashboard:
   ```bash
   cd admin-dashboard
   npm run dev
   ```

4. Open http://localhost:5173

5. **Login:**
   - Email: `admin@yourdomain.com` (or your admin email)
   - Password: Your admin password
   - Click "Sign In"

6. **Test Pages:**
   - Dashboard: Should show real stats (if backend returns data)
   - Users: Should show real users
   - Reports: Should show real reports
   - Transactions: Should show real transactions
   - Settings: Should show real settings

---

## 🔧 Troubleshooting

### Issue: "Cannot connect to API"

**Solution:**
1. Check if backend is running: `curl http://localhost:5000/api/settings`
2. Check `.env` file has correct URL
3. Restart dev server after changing `.env`

### Issue: "401 Unauthorized" on login

**Solution:**
- Backend admin authentication not implemented yet
- Or admin user doesn't exist
- Check backend logs for errors

### Issue: "CORS error"

**Solution:**
- Backend needs to allow CORS from `http://localhost:5173`
- Add to backend CORS config:
  ```javascript
  cors({
    origin: ['http://localhost:5173', 'http://localhost:3000'],
    credentials: true
  })
  ```

### Issue: "Page shows empty/mock data"

**Solution:**
- This is expected if backend endpoints don't exist yet
- Dashboard will show zeros or mock data
- This is normal - UI is working, just needs backend

---

## 📋 Testing Checklist

### UI Testing (No Backend Required)
- [ ] Login page loads
- [ ] Login form validation works
- [ ] Navigation sidebar appears (after login bypass)
- [ ] All menu items are clickable
- [ ] Dashboard page shows layout
- [ ] Users page shows table structure
- [ ] Reports page shows table structure
- [ ] Transactions page shows table structure
- [ ] Settings page shows controls
- [ ] Analytics page shows chart placeholders
- [ ] Responsive design works (resize browser)

### Backend Integration Testing (Requires Backend)
- [ ] Login with real credentials works
- [ ] Dashboard stats load from API
- [ ] Users list loads from API
- [ ] User search works
- [ ] Block/unblock user works
- [ ] Reports list loads
- [ ] Review/resolve report works
- [ ] Transactions list loads
- [ ] Settings load and save
- [ ] Charts show real data

---

## 🎯 Quick Test Commands

### Test Login Page Only
```bash
npm run dev
# Open http://localhost:5173
# You'll see login page
# Click "Quick Login (Test Mode)" to test without backend
```

### Quick Login Credentials (Test Mode)
- **Email:** `admin@test.com`
- **Password:** `test123`
- **Or:** Click the "Quick Login (Test Mode)" button

This works even without a backend running!

### Test API Connection
```bash
# Test if backend is accessible
curl http://localhost:5000/api/settings

# Test admin endpoint (will fail without auth)
curl http://localhost:5000/api/admin/dashboard/stats
```

---

## 🔍 What to Expect

### Without Backend:
- ✅ All pages load
- ✅ UI is functional
- ✅ Navigation works
- ⚠️ Data shows zeros or mock values
- ❌ Login will fail
- ❌ API calls will fail (but UI handles it gracefully)

### With Backend:
- ✅ Login works
- ✅ Real data loads
- ✅ All features functional
- ✅ Charts show real data
- ✅ Actions (block, verify, etc.) work

---

## 📝 Notes

1. **Environment Variables:**
   - `.env` file is NOT committed to git
   - Create `.env` locally
   - Use `env.example.txt` as reference

2. **Hot Reload:**
   - Changes to code auto-reload
   - Changes to `.env` require restart

3. **Build for Production:**
   ```bash
   VITE_API_URL=http://88.222.241.43/api npm run build
   ```

4. **Port:**
   - Default: `5173`
   - If busy, Vite will use next available port
   - Check terminal output for actual port

---

## 🐛 Common Issues

### "Module not found"
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### "Port already in use"
```bash
# Kill process on port 5173 (Windows)
netstat -ano | findstr :5173
taskkill /PID <PID> /F

# Or use different port
npm run dev -- --port 3001
```

### "TypeScript errors"
```bash
# Check tsconfig.json is correct
# Most errors are type imports - already fixed
```

---

**Ready to test?** Run `npm run dev` and open http://localhost:5173!
