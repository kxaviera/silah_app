# Silah Backend API

Backend API for Silah Matrimony Platform.

## Setup

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Configure Environment**
   Copy `.env.example` to `.env` and update the values:
   ```bash
   cp .env.example .env
   ```

3. **Create First Admin User**
   ```bash
   npm run create-admin
   ```
   
   Or set environment variables:
   ```bash
   ADMIN_EMAIL=admin@silah.com ADMIN_PASSWORD=your_password npm run create-admin
   ```

4. **Start Development Server**
   ```bash
   npm run dev
   ```

   Server will run on `http://localhost:5000`

## Admin Authentication

### Create Admin User

```bash
npm run create-admin
```

Default credentials (if not set in .env):
- Email: `admin@silah.com`
- Password: `admin123`

⚠️ **Change the password after first login!**

### Login

**POST** `/api/admin/auth/login`

Request:
```json
{
  "email": "admin@silah.com",
  "password": "admin123"
}
```

Response:
```json
{
  "success": true,
  "token": "jwt_token_here",
  "admin": {
    "_id": "...",
    "email": "admin@silah.com",
    "fullName": "Admin User",
    "role": "super_admin"
  }
}
```

### Get Current Admin

**GET** `/api/admin/auth/me`

Headers:
```
Authorization: Bearer <token>
```

### Logout

**POST** `/api/admin/auth/logout`

Headers:
```
Authorization: Bearer <token>
```

## Project Structure

```
Backend/
├── src/
│   ├── config/
│   │   └── database.ts
│   ├── controllers/
│   │   └── adminAuth.controller.ts
│   ├── middleware/
│   │   └── adminAuth.middleware.ts
│   ├── models/
│   │   └── AdminUser.model.ts
│   ├── routes/
│   │   └── adminAuth.routes.ts
│   └── server.ts
├── scripts/
│   └── create-admin.ts
├── .env.example
├── package.json
└── tsconfig.json
```

## Next Steps

1. ✅ Admin Authentication - **DONE**
2. ⏳ User Management Endpoints
3. ⏳ Reports Management Endpoints
4. ⏳ Transactions Endpoints
5. ⏳ Analytics Endpoints
6. ⏳ Settings Endpoints
