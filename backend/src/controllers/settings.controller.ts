import { Request, Response } from 'express';
import { AppSettings } from '../models/AppSettings.model';

// Get app settings (public endpoint)
export const getAppSettings = async (req: Request, res: Response): Promise<void> => {
  try {
    let settings = await AppSettings.findOne();

    if (!settings) {
      // Return default settings
      settings = await AppSettings.create({
        paymentEnabled: true,
        allowFreePosting: false,
        boostPricing: {
          standard: {
            bride: { price: 19900, duration: 3, enabled: true },
            groom: { price: 29900, duration: 3, enabled: true },
          },
          featured: {
            bride: { price: 39900, duration: 7, enabled: true },
            groom: { price: 59900, duration: 7, enabled: true },
          },
        } as any,
        company: {
          name: 'Silah Matrimony',
          gstin: '',
          email: 'support@silah.com',
          phone: '+91-XXXXXXXXXX',
          address: '',
        },
      });
    }

    res.json({
      success: true,
      settings: {
        paymentEnabled: settings.paymentEnabled,
        allowFreePosting: settings.allowFreePosting,
        boostPricing: settings.boostPricing,
        company: settings.company,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch settings.',
    });
  }
};
