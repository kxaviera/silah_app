import { adminApi } from './api';

export interface AppSettings {
  paymentEnabled: boolean;
  allowFreePosting: boolean;
  boostPricing: {
    standard: { bride: { price: number; enabled: boolean }; groom: { price: number; enabled: boolean }; duration: number };
    featured: { bride: { price: number; enabled: boolean }; groom: { price: number; enabled: boolean }; duration: number };
  };
}

export const settingsService = {
  async getSettings(): Promise<AppSettings> {
    const { data } = await adminApi.get<{ success: boolean; settings: AppSettings }>('/settings');
    return data.settings;
  },
  async updatePricing(pricing: Partial<AppSettings['boostPricing']>) {
    const { data } = await adminApi.put('/settings/pricing', { pricing });
    return data;
  },
  async updatePaymentControls(controls: { paymentEnabled?: boolean; allowFreePosting?: boolean }) {
    const { data } = await adminApi.put('/settings/payment', controls);
    return data;
  },
};
