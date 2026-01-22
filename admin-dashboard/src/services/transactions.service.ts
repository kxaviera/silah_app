import { adminApi } from './api';

export interface Transaction {
  _id: string; userId: string; amount: number; type: string; status: string;
  boostType?: string; paymentMethod?: string; createdAt: string;
  user?: { fullName: string; email: string };
}

export interface TransactionsResponse { success: boolean; transactions: Transaction[]; total: number; page: number; limit: number; }

export const transactionsService = {
  async getTransactions(params: { page?: number; limit?: number; status?: string; startDate?: string; endDate?: string }): Promise<TransactionsResponse> {
    const { data } = await adminApi.get<TransactionsResponse>('/transactions', { params });
    return data;
  },
  async getTransaction(id: string) { const { data } = await adminApi.get(`/transactions/${id}`); return data; },
  async refundTransaction(id: string, reason?: string) { const { data } = await adminApi.post(`/transactions/${id}/refund`, { reason }); return data; },
};
