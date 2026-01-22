# Quick Start Guide - Admin Authentication

## Step 1: Setup Environment

1. Create `.env` file in the Backend directory:
   ```bash
   cd D:\Silah\Backend
   copy .env.example .env
   ```

2. Edit `.env` and set:
   ```env
   MONGODB_URI=mongodb://localhost:27017/silah
   ADMIN_JWT_SECRET=your_secret_key_here
   ADMIN_EMAIL=admin@silah.com
   ADMIN_PASSWORD=admin123
   ADMIN_NAME=Admin User
   ```

## Step 2: Create First Admin User

```bash
npm run create-admin
```

This will create an admin user with:
- Email: `admin@silah.com` (or from .env)
- Password: `admin123` (or from .env)
- Role: `super_admin`

## Step 3: Start Backend Server

```bash
npm run dev
```

Server will run on `http://localhost:5000`

## Step 4: Test Login

You can test the login endpoint:

**Using curl:**
```bash
curl -X POST http://localhost:5000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@silah.com","password":"admin123"}'
```

**Using Postman:**
- Method: POST
- URL: `http://localhost:5000/api/admin/auth/login`
- Body (JSON):
  ```json
  {
    "email": "admin@silah.com",
    "password": "admin123"
  }
  ```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "admin": {
    "_id": "...",
    "email": "admin@silah.com",
    "fullName": "Admin User",
    "role": "super_admin"
  }
}
```

## Step 5: Login to Admin Dashboard

1. Make sure admin dashboard is running: `cd D:\Silah\admin-dashboard && npm run dev`
2. Open `http://localhost:3000/login`
3. Login with:
   - Email: `admin@silah.com`
   - Password: `admin123`

## Troubleshooting

### "MongoDB connection error"
- Make sure MongoDB is running
- Check `MONGODB_URI` in `.env`

### "Admin user already exists"
- The admin was already created
- You can login with existing credentials
- Or delete the admin from MongoDB and run `create-admin` again

### "Invalid credentials"
- Check email and password
- Make sure admin user exists in database
- Check if admin is active (`isActive: true`)

### "Token is not valid"
- Token might be expired
- Check `ADMIN_JWT_SECRET` matches between backend and token generation
- Make sure you're sending token in header: `Authorization: Bearer <token>`
