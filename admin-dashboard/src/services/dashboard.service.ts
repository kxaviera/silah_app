import { adminApi } from './api';

export interface DashboardStats {
  totalUsers: number; activeBoosts: number; pendingReports: number;
  todayRevenue: number; totalRevenue: number; newUsersToday: number;
  activeConversations: number; totalRequests: number;
}

export interface ChartDataPoint { date: string; value: number; label?: string; }

export const dashboardService = {
  async getStats(): Promise<DashboardStats> {
    try {
      const { data } = await adminApi.get<{ success: boolean; stats: DashboardStats }>('/dashboard/stats');
      return data.stats || this.getMockStats();
    } catch { return this.getMockStats(); }
  },
  async getRevenueChart(days = 30): Promise<ChartDataPoint[]> {
    try {
      const { data } = await adminApi.get<{ success: boolean; data: ChartDataPoint[] }>(`/dashboard/revenue-chart?days=${days}`);
      return data.data || this.getMockChart('revenue');
    } catch { return this.getMockChart('revenue'); }
  },
  async getUserGrowthChart(days = 30): Promise<ChartDataPoint[]> {
    try {
      const { data } = await adminApi.get<{ success: boolean; data: ChartDataPoint[] }>(`/dashboard/user-growth?days=${days}`);
      return data.data || this.getMockChart('users');
    } catch { return this.getMockChart('users'); }
  },
  getMockStats(): DashboardStats {
    return { totalUsers: 0, activeBoosts: 0, pendingReports: 0, todayRevenue: 0, totalRevenue: 0, newUsersToday: 0, activeConversations: 0, totalRequests: 0 };
  },
  getMockChart(type: 'revenue' | 'users'): ChartDataPoint[] {
    let acc = 0;
    return Array.from({ length: 30 }, (_, i) => {
      const d = new Date(); d.setDate(d.getDate() - (29 - i));
      const date = d.toISOString().split('T')[0];
      const value = type === 'revenue' ? Math.floor(Math.random() * 5000) + 1000 : (acc += Math.floor(Math.random() * 20) + 5);
      return { date, value };
    });
  },
};
