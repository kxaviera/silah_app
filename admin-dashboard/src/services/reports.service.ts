import { adminApi } from './api';

export interface Report {
  _id: string; reporterId: string; reportedUserId: string; reason: string;
  description?: string; status: string; createdAt: string;
  reporter?: { fullName: string; email: string };
  reportedUser?: { fullName: string; email: string };
}

export interface ReportsResponse { success: boolean; reports: Report[]; total: number; page: number; limit: number; }

export const reportsService = {
  async getReports(params: { page?: number; limit?: number; status?: string }): Promise<ReportsResponse> {
    const { data } = await adminApi.get<ReportsResponse>('/reports', { params });
    return data;
  },
  async getReport(id: string) { const { data } = await adminApi.get(`/reports/${id}`); return data; },
  async reviewReport(id: string, notes: string) { const { data } = await adminApi.put(`/reports/${id}/review`, { notes }); return data; },
  async resolveReport(id: string, action: string, notes?: string) { 
    const { data } = await adminApi.put(`/reports/${id}/resolve`, { action, notes }); 
    return data; 
  },
  async deleteReport(id: string) { const { data } = await adminApi.delete(`/reports/${id}`); return data; },
};
