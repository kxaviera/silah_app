# Admin Dashboard - Complete API Documentation

This document lists all backend API endpoints required for the admin dashboard to function properly.

## Base URL

All admin endpoints are prefixed with `/api/admin`

**Example:** `http://localhost:5000/api/admin/auth/login`

---

## Authentication Endpoints

### 1. Admin Login
```
POST /api/admin/auth/login
```

**Request Body:**
```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "admin": {
    "_id": "admin_id",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

### 2. Get Current Admin
```
GET /api/admin/auth/me
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "admin": {
    "_id": "admin_id",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

### 3. Admin Logout
```
POST /api/admin/auth/logout
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## Dashboard Endpoints

### 4. Get Dashboard Statistics
```
GET /api/admin/dashboard/stats
```

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalUsers": 1250,
    "activeBoosts": 45,
    "pendingReports": 12,
    "todayRevenue": 15000,
    "totalRevenue": 500000,
    "newUsersToday": 8,
    "activeConversations": 120,
    "totalRequests": 350
  }
}
```

### 5. Get Revenue Chart Data
```
GET /api/admin/dashboard/revenue-chart?days=30
```

**Query Parameters:**
- `days` (optional): Number of days (default: 30)

**Response:**
```json
{
  "success": true,
  "data": [
    { "date": "2024-01-01", "value": 5000 },
    { "date": "2024-01-02", "value": 7500 },
    ...
  ]
}
```

### 6. Get User Growth Chart Data
```
GET /api/admin/dashboard/user-growth?days=30
```

**Query Parameters:**
- `days` (optional): Number of days (default: 30)

**Response:**
```json
{
  "success": true,
  "data": [
    { "date": "2024-01-01", "value": 100 },
    { "date": "2024-01-02", "value": 105 },
    ...
  ]
}
```

---

## User Management Endpoints

### 7. List Users
```
GET /api/admin/users?page=1&limit=10&search=john&status=active&sort=createdAt
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `search` (optional): Search by name or email
- `status` (optional): Filter by status (active, blocked, verified, boosted)
- `sort` (optional): Sort field (default: createdAt)

**Response:**
```json
{
  "success": true,
  "users": [
    {
      "_id": "user_id",
      "fullName": "John Doe",
      "email": "john@example.com",
      "role": "groom",
      "isBlocked": false,
      "isVerified": true,
      "boostStatus": "active",
      "boostExpiresAt": "2024-02-01T00:00:00.000Z",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "reportCount": 0
    }
  ],
  "total": 1250,
  "page": 1,
  "limit": 10
}
```

### 8. Get User Details
```
GET /api/admin/users/:id
```

**Response:**
```json
{
  "success": true,
  "user": {
    "_id": "user_id",
    "fullName": "John Doe",
    "email": "john@example.com",
    "role": "groom",
    "isBlocked": false,
    "isVerified": true,
    "boostStatus": "active",
    "boostExpiresAt": "2024-02-01T00:00:00.000Z",
    "createdAt": "2024-01-01T00:00:00.000Z",
    // ... other user fields
  }
}
```

### 9. Block User
```
POST /api/admin/users/:id/block
```

**Response:**
```json
{
  "success": true,
  "message": "User blocked successfully"
}
```

### 10. Unblock User
```
POST /api/admin/users/:id/unblock
```

**Response:**
```json
{
  "success": true,
  "message": "User unblocked successfully"
}
```

### 11. Verify User
```
POST /api/admin/users/:id/verify
```

**Response:**
```json
{
  "success": true,
  "message": "User verified successfully"
}
```

### 12. Delete User
```
DELETE /api/admin/users/:id
```

**Response:**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

---

## Reports Management Endpoints

### 13. List Reports
```
GET /api/admin/reports?page=1&limit=10&status=pending
```

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page
- `status` (optional): Filter by status (pending, reviewed, resolved)

**Response:**
```json
{
  "success": true,
  "reports": [
    {
      "_id": "report_id",
      "reporterId": "user_id_1",
      "reportedUserId": "user_id_2",
      "reason": "Inappropriate content",
      "description": "User posted inappropriate images",
      "status": "pending",
      "createdAt": "2024-01-15T00:00:00.000Z",
      "reporter": {
        "fullName": "Reporter Name",
        "email": "reporter@example.com"
      },
      "reportedUser": {
        "fullName": "Reported User Name",
        "email": "reported@example.com"
      }
    }
  ],
  "total": 50,
  "page": 1,
  "limit": 10
}
```

### 14. Get Report Details
```
GET /api/admin/reports/:id
```

**Response:**
```json
{
  "success": true,
  "report": {
    "_id": "report_id",
    "reporterId": "user_id_1",
    "reportedUserId": "user_id_2",
    "reason": "Inappropriate content",
    "description": "Detailed description...",
    "status": "pending",
    "createdAt": "2024-01-15T00:00:00.000Z",
    "reporter": { ... },
    "reportedUser": { ... }
  }
}
```

### 15. Review Report
```
PUT /api/admin/reports/:id/review
```

**Request Body:**
```json
{
  "notes": "Reviewed the report. User content seems appropriate."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Report reviewed successfully"
}
```

### 16. Resolve Report
```
PUT /api/admin/reports/:id/resolve
```

**Request Body:**
```json
{
  "action": "Warning sent to user"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Report resolved successfully"
}
```

### 17. Delete Report
```
DELETE /api/admin/reports/:id
```

**Response:**
```json
{
  "success": true,
  "message": "Report deleted successfully"
}
```

---

## Transactions Endpoints

### 18. List Transactions
```
GET /api/admin/transactions?page=1&limit=10&status=completed&startDate=2024-01-01&endDate=2024-01-31
```

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page
- `status` (optional): Filter by status (completed, pending, failed, refunded)
- `startDate` (optional): Start date (YYYY-MM-DD)
- `endDate` (optional): End date (YYYY-MM-DD)

**Response:**
```json
{
  "success": true,
  "transactions": [
    {
      "_id": "transaction_id",
      "userId": "user_id",
      "amount": 599,
      "type": "boost",
      "status": "completed",
      "boostType": "featured",
      "paymentMethod": "google_pay",
      "createdAt": "2024-01-15T00:00:00.000Z",
      "user": {
        "fullName": "User Name",
        "email": "user@example.com"
      }
    }
  ],
  "total": 500,
  "page": 1,
  "limit": 10
}
```

### 19. Get Transaction Details
```
GET /api/admin/transactions/:id
```

**Response:**
```json
{
  "success": true,
  "transaction": {
    "_id": "transaction_id",
    "userId": "user_id",
    "amount": 599,
    "type": "boost",
    "status": "completed",
    "boostType": "featured",
    "paymentMethod": "google_pay",
    "createdAt": "2024-01-15T00:00:00.000Z",
    "user": { ... }
  }
}
```

### 20. Process Refund
```
POST /api/admin/transactions/:id/refund
```

**Request Body:**
```json
{
  "reason": "Customer requested refund"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Refund processed successfully"
}
```

### 21. Export Transactions
```
GET /api/admin/transactions/export?startDate=2024-01-01&endDate=2024-01-31
```

**Response:** CSV file download

---

## Settings Endpoints

### 22. Get Settings
```
GET /api/admin/settings
```

**Response:**
```json
{
  "success": true,
  "settings": {
    "paymentEnabled": true,
    "allowFreePosting": false,
    "boostPricing": {
      "standard": {
        "bride": { "price": 199, "enabled": true },
        "groom": { "price": 299, "enabled": true },
        "duration": 7
      },
      "featured": {
        "bride": { "price": 399, "enabled": true },
        "groom": { "price": 599, "enabled": true },
        "duration": 7
      }
    }
  }
}
```

### 23. Update Pricing
```
PUT /api/admin/settings/pricing
```

**Request Body:**
```json
{
  "pricing": {
    "standard": {
      "bride": { "price": 199, "enabled": true },
      "groom": { "price": 299, "enabled": true },
      "duration": 7
    },
    "featured": {
      "bride": { "price": 399, "enabled": true },
      "groom": { "price": 599, "enabled": true },
      "duration": 7
    }
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Pricing updated successfully"
}
```

### 24. Update Payment Controls
```
PUT /api/admin/settings/payment
```

**Request Body:**
```json
{
  "paymentEnabled": true,
  "allowFreePosting": false
}
```

**Response:**
```json
{
  "success": true,
  "message": "Payment controls updated successfully"
}
```

---

## Error Responses

All endpoints return errors in this format:

```json
{
  "success": false,
  "message": "Error message here"
}
```

**HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Server Error

---

## Authentication

All endpoints (except login) require authentication via JWT token in the Authorization header:

```
Authorization: Bearer {token}
```

If the token is missing or invalid, the API should return:
- Status: `401 Unauthorized`
- Response: `{ "success": false, "message": "Unauthorized" }`

---

## Notes

1. All dates should be in ISO 8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)
2. All amounts are in INR (₹)
3. Pagination uses 1-based page numbers
4. All endpoints should handle CORS for the admin dashboard domain
5. Rate limiting should be implemented for security

---

## Implementation Checklist

- [ ] Admin authentication endpoints
- [ ] Dashboard statistics endpoints
- [ ] User management endpoints
- [ ] Reports management endpoints
- [ ] Transactions endpoints
- [ ] Settings endpoints
- [ ] Error handling
- [ ] CORS configuration
- [ ] Rate limiting
- [ ] Input validation
- [ ] Admin authorization middleware
