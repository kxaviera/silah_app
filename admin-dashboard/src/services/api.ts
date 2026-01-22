import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';
// Admin base: e.g. http://localhost:5000/api/admin or http://88.222.241.43/api/admin
const ADMIN_BASE = API_URL.replace(/\/api\/?$/, '') + '/api/admin';

export const api = axios.create({
  baseURL: API_URL,
  headers: { 'Content-Type': 'application/json' },
});

export const adminApi = axios.create({
  baseURL: ADMIN_BASE,
  headers: { 'Content-Type': 'application/json' },
});

adminApi.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

adminApi.interceptors.response.use(
  (r) => r,
  (e) => {
    if (e.response?.status === 401) {
      // Don't redirect if in test mode (has admin_data)
      const adminData = localStorage.getItem('admin_data');
      if (!adminData) {
        localStorage.removeItem('admin_token');
        window.location.href = '/login';
      }
    }
    return Promise.reject(e);
  }
);
