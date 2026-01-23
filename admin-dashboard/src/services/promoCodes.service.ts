import { adminApi } from './api';

export interface PromoCode {
  _id: string;
  code: string;
  description?: string;
  discountType: 'percentage' | 'fixed';
  discountValue: number; // percentage (0-100) or fixed amount in paise
  minAmount?: number; // Minimum transaction amount in paise
  maxDiscount?: number; // Maximum discount in paise (for percentage)
  validFrom: string;
  validUntil: string;
  usageLimit?: number;
  usageCount: number;
  userLimit?: number;
  applicableTo: 'all' | 'bride' | 'groom';
  applicableBoostType?: 'all' | 'standard' | 'featured';
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface PromoCodeUsage {
  totalUsage: number;
  usageLimit?: number;
  remainingUsage?: number;
  totalDiscount: number;
  totalRevenue: number;
  transactions: number;
  recentTransactions: any[];
}

export const promoCodesService = {
  async getPromoCodes(params?: { isActive?: string; search?: string }): Promise<PromoCode[]> {
    const { data } = await adminApi.get<{ success: boolean; promoCodes: PromoCode[] }>('/promo-codes', { params });
    return data.promoCodes || [];
  },

  async getPromoCode(id: string): Promise<PromoCode> {
    const { data } = await adminApi.get<{ success: boolean; promoCode: PromoCode }>(`/promo-codes/${id}`);
    return data.promoCode;
  },

  async getPromoCodeUsage(id: string): Promise<{ promoCode: PromoCode & { usage: PromoCodeUsage; recentTransactions: any[] } }> {
    const { data } = await adminApi.get<{ success: boolean; promoCode: PromoCode & { usage: PromoCodeUsage; recentTransactions: any[] } }>(`/promo-codes/${id}/usage`);
    return data;
  },

  async createPromoCode(promoCode: Partial<PromoCode>): Promise<{ success: boolean; message: string; promoCode: PromoCode }> {
    // Convert amounts from rupees to paise
    const payload: any = { ...promoCode };
    if (payload.discountType === 'fixed' && payload.discountValue) {
      payload.discountValue = payload.discountValue * 100;
    }
    if (payload.minAmount) {
      payload.minAmount = payload.minAmount * 100;
    }
    if (payload.maxDiscount) {
      payload.maxDiscount = payload.maxDiscount * 100;
    }
    
    const { data } = await adminApi.post<{ success: boolean; message: string; promoCode: PromoCode }>('/promo-codes', payload);
    return data;
  },

  async updatePromoCode(id: string, promoCode: Partial<PromoCode>): Promise<{ success: boolean; message: string; promoCode: PromoCode }> {
    // Convert amounts from rupees to paise
    const payload: any = { ...promoCode };
    if (payload.discountType === 'fixed' && payload.discountValue) {
      payload.discountValue = payload.discountValue * 100;
    }
    if (payload.minAmount) {
      payload.minAmount = payload.minAmount * 100;
    }
    if (payload.maxDiscount) {
      payload.maxDiscount = payload.maxDiscount * 100;
    }
    
    const { data } = await adminApi.put<{ success: boolean; message: string; promoCode: PromoCode }>(`/promo-codes/${id}`, payload);
    return data;
  },

  async deletePromoCode(id: string): Promise<{ success: boolean; message: string }> {
    const { data } = await adminApi.delete<{ success: boolean; message: string }>(`/promo-codes/${id}`);
    return data;
  },
};
