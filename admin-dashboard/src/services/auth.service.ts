import { adminApi } from './api';

export interface LoginResponse {
  success: boolean;
  token?: string;
  admin?: { _id: string; email: string; role: string };
  message?: string;
}

export const authService = {
  async login(email: string, password: string): Promise<LoginResponse> {
    // Test mode: Quick login for testing without backend
    if (email === 'admin@test.com' && password === 'test123') {
      const mockToken = 'test_token_' + Date.now();
      const mockAdmin = { _id: 'test_admin_1', email: 'admin@test.com', role: 'admin' };
      localStorage.setItem('admin_token', mockToken);
      localStorage.setItem('admin_data', JSON.stringify(mockAdmin));
      return { success: true, token: mockToken, admin: mockAdmin };
    }
    
    try {
      const { data } = await adminApi.post<LoginResponse>('/auth/login', { email, password });
      if (data.success && data.token) localStorage.setItem('admin_token', data.token);
      return data;
    } catch (error: any) {
      // If backend is not available, allow test login
      if (error.code === 'ERR_NETWORK' || error.response?.status >= 500) {
        if (email === 'admin@test.com' && password === 'test123') {
          const mockToken = 'test_token_' + Date.now();
          const mockAdmin = { _id: 'test_admin_1', email: 'admin@test.com', role: 'admin' };
          localStorage.setItem('admin_token', mockToken);
          localStorage.setItem('admin_data', JSON.stringify(mockAdmin));
          return { success: true, token: mockToken, admin: mockAdmin };
        }
      }
      return { success: false, message: error.response?.data?.message || 'Login failed' };
    }
  },
  async logout(): Promise<void> {
    try { await adminApi.post('/auth/logout'); } catch {} 
    finally { 
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_data');
    }
  },
  async getMe() {
    // Test mode: Return mock admin if token exists but backend fails
    const adminData = localStorage.getItem('admin_data');
    if (adminData) {
      try {
        const { data } = await adminApi.get('/auth/me');
        return data;
      } catch {
        // Backend not available, return mock data
        return { success: true, admin: JSON.parse(adminData) };
      }
    }
    const { data } = await adminApi.get('/auth/me');
    return data;
  },
  isAuthenticated(): boolean { return !!localStorage.getItem('admin_token'); },
};
