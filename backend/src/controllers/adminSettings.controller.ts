import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { AppSettings } from '../models/AppSettings.model';

// Get all settings
export const getSettings = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    let settings = await AppSettings.findOne();

    // If no settings exist, create default
    if (!settings) {
      settings = new AppSettings({
        paymentEnabled: false,
        allowFreePosting: true,
        boostPricing: {
          standard: {
            bride: { price: 19900, duration: 3, enabled: true }, // ₹199 in paise
            groom: { price: 29900, duration: 3, enabled: true }, // ₹299 in paise
          },
          featured: {
            bride: { price: 39900, duration: 7, enabled: true }, // ₹399 in paise
            groom: { price: 59900, duration: 7, enabled: true }, // ₹599 in paise
          },
        },
        company: {
          name: 'Silah Matrimony',
          gstin: '',
          email: 'support@silah.com',
          phone: '+91-1234567890',
          address: '',
        },
        app: {
          termsUrl: '',
          privacyUrl: '',
        },
      });
      await settings.save();
    }

    // Convert prices from paise to rupees for frontend
    const formattedSettings = {
      ...settings.toObject(),
      boostPricing: {
        standard: {
          bride: {
            price: Math.round(settings.boostPricing.standard.bride.price / 100),
            enabled: settings.boostPricing.standard.bride.enabled,
            duration: settings.boostPricing.standard.bride.duration,
          },
          groom: {
            price: Math.round(settings.boostPricing.standard.groom.price / 100),
            enabled: settings.boostPricing.standard.groom.enabled,
            duration: settings.boostPricing.standard.groom.duration,
          },
        },
        featured: {
          bride: {
            price: Math.round(settings.boostPricing.featured.bride.price / 100),
            enabled: settings.boostPricing.featured.bride.enabled,
            duration: settings.boostPricing.featured.bride.duration,
          },
          groom: {
            price: Math.round(settings.boostPricing.featured.groom.price / 100),
            enabled: settings.boostPricing.featured.groom.enabled,
            duration: settings.boostPricing.featured.groom.duration,
          },
        },
      },
    };

    res.status(200).json({
      success: true,
      settings: formattedSettings,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch settings',
    });
  }
};

// Update pricing
export const updatePricing = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { pricing } = req.body; // Frontend sends 'pricing' not 'boostPricing'

    if (!pricing) {
      res.status(400).json({
        success: false,
        message: 'Pricing is required',
      });
      return;
    }

    let settings = await AppSettings.findOne();

    // Convert prices from rupees to paise for storage
    const boostPricing = {
      standard: {
        bride: {
          price: (pricing.standard?.bride?.price || 199) * 100, // Convert to paise
          duration: pricing.standard?.duration || settings?.boostPricing?.standard?.bride?.duration || 7,
          enabled: pricing.standard?.bride?.enabled ?? settings?.boostPricing?.standard?.bride?.enabled ?? true,
        },
        groom: {
          price: (pricing.standard?.groom?.price || 299) * 100, // Convert to paise
          duration: pricing.standard?.duration || settings?.boostPricing?.standard?.groom?.duration || 7,
          enabled: pricing.standard?.groom?.enabled ?? settings?.boostPricing?.standard?.groom?.enabled ?? true,
        },
      },
      featured: {
        bride: {
          price: (pricing.featured?.bride?.price || 399) * 100, // Convert to paise
          duration: pricing.featured?.duration || settings?.boostPricing?.featured?.bride?.duration || 7,
          enabled: pricing.featured?.bride?.enabled ?? settings?.boostPricing?.featured?.bride?.enabled ?? true,
        },
        groom: {
          price: (pricing.featured?.groom?.price || 599) * 100, // Convert to paise
          duration: pricing.featured?.duration || settings?.boostPricing?.featured?.groom?.duration || 7,
          enabled: pricing.featured?.groom?.enabled ?? settings?.boostPricing?.featured?.groom?.enabled ?? true,
        },
      },
    };

    if (!settings) {
      // Create new settings if doesn't exist
      settings = new AppSettings({
        paymentEnabled: false,
        allowFreePosting: true,
        boostPricing,
        company: {
          name: 'Silah Matrimony',
          gstin: '',
          email: 'support@silah.com',
          phone: '+91-1234567890',
          address: '',
        },
        app: {
          termsUrl: '',
          privacyUrl: '',
        },
      });
    } else {
      // Update pricing
      if (pricing.standard) {
        if (pricing.standard.bride) {
          settings.boostPricing.standard.bride = {
            ...settings.boostPricing.standard.bride,
            price: pricing.standard.bride.price * 100,
            enabled: pricing.standard.bride.enabled ?? settings.boostPricing.standard.bride.enabled,
          };
        }
        if (pricing.standard.groom) {
          settings.boostPricing.standard.groom = {
            ...settings.boostPricing.standard.groom,
            price: pricing.standard.groom.price * 100,
            enabled: pricing.standard.groom.enabled ?? settings.boostPricing.standard.groom.enabled,
          };
        }
        if (pricing.standard.duration) {
          settings.boostPricing.standard.bride.duration = pricing.standard.duration;
          settings.boostPricing.standard.groom.duration = pricing.standard.duration;
        }
      }
      if (pricing.featured) {
        if (pricing.featured.bride) {
          settings.boostPricing.featured.bride = {
            ...settings.boostPricing.featured.bride,
            price: pricing.featured.bride.price * 100,
            enabled: pricing.featured.bride.enabled ?? settings.boostPricing.featured.bride.enabled,
          };
        }
        if (pricing.featured.groom) {
          settings.boostPricing.featured.groom = {
            ...settings.boostPricing.featured.groom,
            price: pricing.featured.groom.price * 100,
            enabled: pricing.featured.groom.enabled ?? settings.boostPricing.featured.groom.enabled,
          };
        }
        if (pricing.featured.duration) {
          settings.boostPricing.featured.bride.duration = pricing.featured.duration;
          settings.boostPricing.featured.groom.duration = pricing.featured.duration;
        }
      }
    }

    await settings.save();

    // Return formatted settings (convert back to rupees)
    const formattedSettings = {
      ...settings.toObject(),
      boostPricing: {
        standard: {
          bride: {
            price: Math.round(settings.boostPricing.standard.bride.price / 100),
            enabled: settings.boostPricing.standard.bride.enabled,
            duration: settings.boostPricing.standard.bride.duration,
          },
          groom: {
            price: Math.round(settings.boostPricing.standard.groom.price / 100),
            enabled: settings.boostPricing.standard.groom.enabled,
            duration: settings.boostPricing.standard.groom.duration,
          },
        },
        featured: {
          bride: {
            price: Math.round(settings.boostPricing.featured.bride.price / 100),
            enabled: settings.boostPricing.featured.bride.enabled,
            duration: settings.boostPricing.featured.bride.duration,
          },
          groom: {
            price: Math.round(settings.boostPricing.featured.groom.price / 100),
            enabled: settings.boostPricing.featured.groom.enabled,
            duration: settings.boostPricing.featured.groom.duration,
          },
        },
      },
    };

    res.status(200).json({
      success: true,
      message: 'Pricing updated successfully',
      settings: formattedSettings,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update pricing',
    });
  }
};

// Update payment settings
export const updatePayment = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { paymentEnabled, allowFreePosting } = req.body;

    let settings = await AppSettings.findOne();

    // If no settings exist, create default settings first
    if (!settings) {
      settings = new AppSettings({
        paymentEnabled: paymentEnabled ?? false,
        allowFreePosting: allowFreePosting ?? true,
        boostPricing: {
          standard: {
            bride: { price: 19900, duration: 3, enabled: true },
            groom: { price: 29900, duration: 3, enabled: true },
          },
          featured: {
            bride: { price: 39900, duration: 7, enabled: true },
            groom: { price: 59900, duration: 7, enabled: true },
          },
        },
        company: {
          name: 'Silah Matrimony',
          gstin: '',
          email: 'support@silah.com',
          phone: '+91-1234567890',
          address: '',
        },
        app: {
          termsUrl: '',
          privacyUrl: '',
        },
      });
    } else {
      // Update existing settings
      if (paymentEnabled !== undefined) {
        settings.paymentEnabled = paymentEnabled;
      }
      if (allowFreePosting !== undefined) {
        settings.allowFreePosting = allowFreePosting;
      }
    }

    await settings.save();

    // Return formatted settings (convert prices to rupees)
    const formattedSettings = {
      ...settings.toObject(),
      boostPricing: {
        standard: {
          bride: {
            price: Math.round(settings.boostPricing.standard.bride.price / 100),
            enabled: settings.boostPricing.standard.bride.enabled,
            duration: settings.boostPricing.standard.bride.duration,
          },
          groom: {
            price: Math.round(settings.boostPricing.standard.groom.price / 100),
            enabled: settings.boostPricing.standard.groom.enabled,
            duration: settings.boostPricing.standard.groom.duration,
          },
        },
        featured: {
          bride: {
            price: Math.round(settings.boostPricing.featured.bride.price / 100),
            enabled: settings.boostPricing.featured.bride.enabled,
            duration: settings.boostPricing.featured.bride.duration,
          },
          groom: {
            price: Math.round(settings.boostPricing.featured.groom.price / 100),
            enabled: settings.boostPricing.featured.groom.enabled,
            duration: settings.boostPricing.featured.groom.duration,
          },
        },
      },
    };

    res.status(200).json({
      success: true,
      message: 'Payment settings updated successfully',
      settings: formattedSettings,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update payment settings',
    });
  }
};

// Update company details
export const updateCompany = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { company } = req.body;

    if (!company) {
      res.status(400).json({
        success: false,
        message: 'Company details are required',
      });
      return;
    }

    let settings = await AppSettings.findOne();

    if (!settings) {
      res.status(404).json({
        success: false,
        message: 'Settings not found. Please create settings first.',
      });
      return;
    }

    settings.company = { ...settings.company, ...company };
    await settings.save();

    res.status(200).json({
      success: true,
      message: 'Company details updated successfully',
      settings,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update company details',
    });
  }
};
