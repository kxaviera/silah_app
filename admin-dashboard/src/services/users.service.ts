import { adminApi } from './api';

export interface User {
  _id: string;
  email: string;
  fullName: string;
  role: 'bride' | 'groom';
  isBlocked: boolean;
  isVerified: boolean;
  boostStatus: string;
  createdAt: string;
  // Complete profile fields
  mobile?: string;
  dateOfBirth?: string;
  age?: number;
  gender?: string;
  height?: number;
  complexion?: string;
  country?: string;
  livingCountry?: string;
  state?: string;
  city?: string;
  religion?: string;
  caste?: string;
  education?: string;
  profession?: string;
  annualIncome?: string;
  about?: string;
  partnerPreferences?: string;
  profilePhoto?: string;
  hideMobile?: boolean;
  hidePhotos?: boolean;
  isProfileComplete?: boolean;
  verifiedAt?: string;
  verificationNotes?: string;
}

export interface UsersResponse {
  users: User[];
  total: number;
  page: number;
  limit: number;
}

export const usersService = {
  async getUsers(params?: { status?: string; sort?: string; page?: number; limit?: number; search?: string }): Promise<UsersResponse> {
    const { data } = await adminApi.get<{ success: boolean } & UsersResponse>('/users', { params });
    return { users: data.users || [], total: data.total || 0, page: data.page || 1, limit: data.limit || 20 };
  },
  async getUser(id: string): Promise<{ success: boolean; user: User }> {
    const { data } = await adminApi.get<{ success: boolean; user: User }>(`/users/${id}`);
    return data;
  },
  async blockUser(id: string): Promise<{ success: boolean; message: string }> {
    const { data } = await adminApi.post<{ success: boolean; message: string }>(`/users/${id}/block`);
    return data;
  },
  async unblockUser(id: string): Promise<{ success: boolean; message: string }> {
    const { data } = await adminApi.post<{ success: boolean; message: string }>(`/users/${id}/unblock`);
    return data;
  },
  async verifyUser(id: string, notes?: string): Promise<{ success: boolean; message: string; user: User }> {
    const { data } = await adminApi.post<{ success: boolean; message: string; user: User }>(`/users/${id}/verify`, { notes });
    return data;
  },
  async rejectUser(id: string, notes: string): Promise<{ success: boolean; message: string; user: User }> {
    const { data } = await adminApi.post<{ success: boolean; message: string; user: User }>(`/users/${id}/reject`, { notes });
    return data;
  },
};
