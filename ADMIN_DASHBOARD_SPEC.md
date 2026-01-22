# Silah Admin Dashboard - Web Application Specification

## Overview
Web-based admin dashboard for managing the Silah matrimony platform. This is a separate web application (not Flutter) that consumes the admin API endpoints.

## Technology Stack Recommendations

### Option 1: React.js (Recommended)
- **Framework:** React 18+ with TypeScript
- **UI Library:** Material-UI (MUI) or Ant Design
- **State Management:** Redux Toolkit or Zustand
- **Charts:** Recharts or Chart.js
- **HTTP Client:** Axios
- **Routing:** React Router v6
- **Build Tool:** Vite or Create React App

### Option 2: Vue.js
- **Framework:** Vue 3 with TypeScript
- **UI Library:** Vuetify or Element Plus
- **State Management:** Pinia
- **Charts:** Chart.js or ApexCharts
- **HTTP Client:** Axios
- **Routing:** Vue Router
- **Build Tool:** Vite

### Option 3: Next.js (Full-stack)
- **Framework:** Next.js 14+ with TypeScript
- **UI Library:** Material-UI or Tailwind CSS + shadcn/ui
- **State Management:** Zustand or React Context
- **Charts:** Recharts
- **HTTP Client:** Built-in fetch or Axios
- **Routing:** Next.js App Router

## Project Structure (React Example)

```
admin-dashboard/
├── src/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── DataTable.tsx
│   │   │   └── StatCard.tsx
│   │   ├── dashboard/
│   │   │   ├── StatsOverview.tsx
│   │   │   ├── RevenueChart.tsx
│   │   │   └── UserGrowthChart.tsx
│   │   ├── users/
│   │   │   ├── UserList.tsx
│   │   │   ├── UserCard.tsx
│   │   │   └── UserFilters.tsx
│   │   └── reports/
│   │       ├── ReportList.tsx
│   │       └── ReportDetail.tsx
│   ├── pages/
│   │   ├── Login.tsx
│   │   ├── Dashboard.tsx
│   │   ├── Users.tsx
│   │   ├── UserDetail.tsx
│   │   ├── Reports.tsx
│   │   ├── ReportDetail.tsx
│   │   ├── Transactions.tsx
│   │   ├── Analytics.tsx
│   │   └── Settings.tsx
│   ├── services/
│   │   ├── api.ts
│   │   ├── auth.service.ts
│   │   ├── users.service.ts
│   │   ├── reports.service.ts
│   │   └── transactions.service.ts
│   ├── store/
│   │   ├── auth.slice.ts
│   │   └── app.slice.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   └── useApi.ts
│   ├── utils/
│   │   ├── formatters.ts
│   │   └── validators.ts
│   └── App.tsx
├── package.json
└── tsconfig.json
```

## Key Features & Pages

### 1. Login Page (`/login`)
- Email and password fields
- "Remember me" checkbox
- Login button
- Error handling
- Redirect to dashboard on success

### 2. Dashboard Home (`/`)
- **Stats Grid:**
  - Total Users (with growth indicator)
  - Active Boosts
  - Pending Reports (with badge)
  - Today's Revenue
  - Total Revenue
  - New Users Today
  - Active Conversations
  - Total Requests
- **Charts:**
  - Revenue Chart (line chart, last 30 days)
  - User Growth Chart (line chart, last 30 days)
- **Quick Actions:**
  - Review Reports (with count badge)
  - View Users
  - View Transactions
  - Settings

### 3. Users Page (`/users`)
- **Search Bar:** Search by name/email
- **Filters:**
  - All / Active / Blocked / Verified / Boosted
  - Sort by: Date, Name, Boost Status
- **User Cards/Table:**
  - Avatar/Initial
  - Name, Email
  - Role (Bride/Groom badge)
  - Status (Active/Blocked)
  - Verification badge
  - Boost status
  - Report count (if > 0)
  - Actions: View Details, Block/Unblock, Verify
- **Pagination**

### 4. User Detail Page (`/users/:id`)
- **User Information:**
  - Full profile details
  - Registration date
  - Last active
  - Verification status
- **Boost History:**
  - Table of all boost transactions
  - Dates, amounts, status
- **Report History:**
  - List of reports (as reporter and reported)
- **Activity Log:**
  - Recent activities
- **Actions:**
  - Block/Unblock
  - Verify/Unverify
  - Delete User (with confirmation)

### 5. Reports Page (`/reports`)
- **Filters:**
  - Status: Pending / Reviewed / Resolved / All
  - Sort by: Date / Count
- **Report Cards/Table:**
  - Reporter name/email
  - Reported user name/email
  - Reason
  - Description
  - Status badge
  - Report count (if multiple)
  - Created date
  - Actions: View Details, Review
- **Pagination**

### 6. Report Detail Page (`/reports/:id`)
- **Report Information:**
  - Full report details
  - Reporter information
  - Reported user information
  - Reason and description
  - Status
- **Related Reports:**
  - Other reports for same user
  - Reporter's report history
- **Actions:**
  - Mark as Reviewed
  - Resolve (with action: Block User / Dismiss)
  - View Reported User Profile
  - Notes field

### 7. Transactions Page (`/transactions`)
- **Filters:**
  - Date range picker
  - Status: All / Completed / Failed / Refunded
  - Payment method
  - Search by invoice number or user email
- **Transactions Table:**
  - Invoice number
  - User name/email
  - Amount (with currency formatting)
  - Payment method
  - Status badge
  - Date
  - Actions: View Details, Refund
- **Summary Card:**
  - Total Revenue
  - Total Transactions
  - Average Transaction Value
- **Export Button:** Download CSV/Excel

### 8. Transaction Detail Page (`/transactions/:id`)
- **Transaction Information:**
  - Full transaction details
  - User information
  - Boost type and duration
  - Amount breakdown (subtotal, discount, GST, total)
  - Payment method
  - Status
  - Invoice number
- **Invoice Preview:**
  - Full invoice details
  - Download/Print button
- **Actions:**
  - Refund (with reason and amount)

### 9. Analytics Page (`/analytics`)
- **User Analytics:**
  - User Growth Chart (line chart)
  - User Distribution:
    - By Role (pie chart)
    - By Country (bar chart)
    - By Religion (bar chart)
  - Active vs Inactive Users (donut chart)
- **Revenue Analytics:**
  - Revenue Chart (line/area chart)
  - Revenue by Boost Type (pie chart)
  - Revenue by Payment Method (bar chart)
  - Average Transaction Value
- **Engagement Analytics:**
  - Profile Views
  - Contact Requests
  - Messages Sent
  - Active Conversations
  - Boost Conversion Rate
- **Export Options:** CSV/Excel/PDF

### 10. Settings Page (`/settings`)
- **Boost Pricing:**
  - Standard boost: Price (₹) and Duration (days)
  - Featured boost: Price (₹) and Duration (days)
  - Save button
- **Company Details:**
  - Company name
  - GSTIN
  - Email
  - Phone
  - Address
  - Save button
- **Promo Codes:**
  - List of promo codes
  - Create new promo code form
  - Edit/Delete actions
  - Usage statistics
- **App Settings:**
  - Terms & Conditions URL
  - Privacy Policy URL
  - Save button

## Design Guidelines

### Color Scheme
- **Primary:** Green (#2E7D32) - matches app theme
- **Background:** White (#FFFFFF)
- **Text:** Black (#212121) and Grey (#757575)
- **Borders:** Light Grey (#E0E0E0)
- **Success:** Green (#4CAF50)
- **Warning:** Orange (#FF9800)
- **Error:** Red (#F44336)
- **Info:** Blue (#2196F3)

### Typography
- **Font Family:** Inter, Roboto, or system fonts
- **Headings:** Bold, 16-24px
- **Body:** Regular, 14-16px
- **Small:** Regular, 12-14px

### Components Style
- **Cards:** White background, light grey border, 12-16px border radius
- **Buttons:** Rounded (12px), proper padding
- **Inputs:** Outlined style, 12px border radius
- **Tables:** Clean, minimal design with hover effects
- **Charts:** Professional, color-coded

### Responsive Design
- **Desktop:** Full layout with sidebar
- **Tablet:** Collapsible sidebar
- **Mobile:** Bottom navigation or hamburger menu

## API Integration

### Base Configuration
```typescript
// services/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle token expiration
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

### Example Service
```typescript
// services/users.service.ts
import api from './api';

export const getUsers = async (params: {
  search?: string;
  filter?: string;
  page?: number;
  limit?: number;
}) => {
  const response = await api.get('/admin/users', { params });
  return response.data;
};

export const blockUser = async (userId: string, reason: string) => {
  const response = await api.post(`/admin/users/${userId}/block`, { reason });
  return response.data;
};
```

## Authentication Flow

1. Admin enters email/password on login page
2. Frontend calls `POST /api/admin/auth/login`
3. Backend returns JWT token
4. Frontend stores token in localStorage
5. All subsequent requests include token in Authorization header
6. On 401 error, redirect to login page

## State Management

### Auth State
```typescript
interface AuthState {
  admin: Admin | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
```

### App State
```typescript
interface AppState {
  stats: DashboardStats | null;
  users: User[];
  reports: Report[];
  transactions: Transaction[];
}
```

## Environment Variables

```env
REACT_APP_API_URL=http://localhost:5000/api
REACT_APP_ENV=development
```

## Deployment

### Build
```bash
npm run build
```

### Production
- Deploy to: Vercel, Netlify, or AWS S3 + CloudFront
- Set environment variables
- Configure CORS on backend for admin domain

## Security Considerations

1. **Token Storage:** Use httpOnly cookies (if possible) or secure localStorage
2. **HTTPS:** Always use HTTPS in production
3. **CORS:** Configure backend CORS for admin domain only
4. **Rate Limiting:** Implement on backend
5. **Input Validation:** Validate all inputs
6. **XSS Prevention:** Sanitize user inputs
7. **CSRF Protection:** Use CSRF tokens

## Testing

### Unit Tests
- Component tests (React Testing Library)
- Service tests (Jest)

### Integration Tests
- API integration tests
- E2E tests (Cypress or Playwright)

## Development Checklist

- [ ] Set up project structure
- [ ] Configure routing
- [ ] Set up API client
- [ ] Implement authentication
- [ ] Create dashboard home page
- [ ] Create users management pages
- [ ] Create reports management pages
- [ ] Create transactions pages
- [ ] Create analytics page
- [ ] Create settings page
- [ ] Add charts and visualizations
- [ ] Implement search and filters
- [ ] Add pagination
- [ ] Implement responsive design
- [ ] Add error handling
- [ ] Add loading states
- [ ] Test all features
- [ ] Deploy to production

---

**Last Updated:** 2024-01-15
