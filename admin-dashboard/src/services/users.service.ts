import { adminApi } from './api';

export interface User {
  _id: string;
  email: string;
  fullName: string;
  role?: 'bride' | 'groom'; // Optional - set during profile completion
  isBlocked: boolean;
  isVerified: boolean;
  boostStatus: string;
  createdAt: string;
  // Complete profile fields
  mobile?: string;
  dateOfBirth?: string;
  age?: number;
  gender?: string;
  currentStatus?: string;
  height?: number;
  complexion?: string;
  physicalStatus?: string;
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
  profileHandledBy?: string;
  // Family details
  fatherName?: string;
  fatherOccupation?: string;
  motherName?: string;
  motherOccupation?: string;
  brothersCount?: string;
  brothersMaritalStatus?: string; // Number of married brothers
  sistersCount?: string;
  sistersMaritalStatus?: string; // Number of married sisters
  isProfileComplete?: boolean;
  verifiedAt?: string;
  verificationNotes?: string;
  /** IP at profile creation (compliance) */
  registrationIp?: string;
}

export interface UserAccessLogEntry {
  _id: string;
  userId: string;
  ipAddress: string;
  userAgent?: string;
  action: 'registration' | 'login' | 'google_login';
  createdAt: string;
}

export interface UserAccessLogsResponse {
  logs: UserAccessLogEntry[];
  total: number;
  page: number;
  limit: number;
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
  async getUserAccessLogs(id: string, params?: { page?: number; limit?: number }): Promise<UserAccessLogsResponse> {
    const { data } = await adminApi.get<{ success: boolean } & UserAccessLogsResponse>(`/users/${id}/access-logs`, { params });
    return { logs: data.logs || [], total: data.total || 0, page: data.page || 1, limit: data.limit || 50 };
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
  async updateUserRole(id: string, role: 'bride' | 'groom'): Promise<{ success: boolean; message: string; user: User }> {
    const { data } = await adminApi.put<{ success: boolean; message: string; user: User }>(`/users/${id}/role`, { role });
    return data;
  },
};
