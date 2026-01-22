# Silah Admin Dashboard

Web-based admin dashboard for the Silah matrimony platform.

## Setup

```bash
npm install
```

## Environment

Create a `.env` file:

```
VITE_API_URL=http://localhost:5000/api
```

For production (e.g. VPS at 88.222.241.43):

```
VITE_API_URL=http://88.222.241.43/api
```

## Run

```bash
npm run dev
```

## Quick Test Login

For testing without backend:
- Click **"Quick Login (Test Mode)"** button on login page
- Or use: `admin@test.com` / `test123`

## Build

```bash
npm run build
```

Output in `dist/`. Deploy to any static host or serve via Nginx.

## Pages

- **Login** – Admin sign in
- **Dashboard** – Stats, revenue chart, user growth
- **Users** – List, search, block, verify
- **User Detail** – View user, block/unblock, verify
- **Reports** – List, filter by status
- **Report Detail** – Review, resolve
- **Transactions** – List, filter, view
- **Transaction Detail** – View, refund
- **Analytics** – Revenue and user growth charts
- **Settings** – Payment controls, pricing (read-only)

## Backend

The dashboard expects these admin API bases:

- `POST /api/admin/auth/login`
- `GET /api/admin/auth/me`
- `POST /api/admin/auth/logout`
- `GET /api/admin/dashboard/stats`
- `GET /api/admin/dashboard/revenue-chart`
- `GET /api/admin/dashboard/user-growth`
- `GET /api/admin/users`, `GET /api/admin/users/:id`, `POST /api/admin/users/:id/block`, etc.
- `GET /api/admin/reports`, `GET /api/admin/reports/:id`, `PUT /api/admin/reports/:id/review`, etc.
- `GET /api/admin/transactions`, `GET /api/admin/transactions/:id`, `POST /api/admin/transactions/:id/refund`
- `GET /api/admin/settings`, `PUT /api/admin/settings/pricing`, `PUT /api/admin/settings/payment`

Ensure the backend implements these before using the dashboard.
