import { adminApi } from './api';

export interface User {
  _id: string; fullName: string; email: string; role: string;
  isBlocked?: boolean; isVerified?: boolean; boostStatus?: string;
  boostExpiresAt?: string; createdAt: string; reportCount?: number;
}

export interface UsersResponse { success: boolean; users: User[]; total: number; page: number; limit: number; }

export const usersService = {
  async getUsers(params: { page?: number; limit?: number; search?: string; status?: string; sort?: string }): Promise<UsersResponse> {
    const { data } = await adminApi.get<UsersResponse>('/users', { params });
    return data;
  },
  async getUser(id: string) { const { data } = await adminApi.get(`/users/${id}`); return data; },
  async blockUser(id: string) { const { data } = await adminApi.post(`/users/${id}/block`); return data; },
  async unblockUser(id: string) { const { data } = await adminApi.post(`/users/${id}/unblock`); return data; },
  async verifyUser(id: string) { const { data } = await adminApi.post(`/users/${id}/verify`); return data; },
  async deleteUser(id: string) { const { data } = await adminApi.delete(`/users/${id}`); return data; },
};
