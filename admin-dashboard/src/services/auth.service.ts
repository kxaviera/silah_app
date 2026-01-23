import { adminApi } from './api';

export interface LoginResponse {
  success: boolean;
  token?: string;
  admin?: { _id: string; email: string; role: string };
  message?: string;
}

export const authService = {
  async login(email: string, password: string): Promise<LoginResponse> {
    try {
      const { data } = await adminApi.post<LoginResponse>('/auth/login', { email, password });
      if (data.success && data.token) {
        localStorage.setItem('admin_token', data.token);
      }
      return data;
    } catch (error: any) {
      return { 
        success: false, 
        message: error.response?.data?.message || 'Login failed. Please check your credentials.' 
      };
    }
  },
  async logout(): Promise<void> {
    try { 
      await adminApi.post('/auth/logout'); 
    } catch {} 
    finally { 
      localStorage.removeItem('admin_token');
    }
  },
  async getMe() {
    const { data } = await adminApi.get('/auth/me');
    return data;
  },
  isAuthenticated(): boolean { return !!localStorage.getItem('admin_token'); },
};
