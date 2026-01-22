import { Response } from 'express';
import { User } from '../models/User.model';
import { AppSettings } from '../models/AppSettings.model';
import { Transaction } from '../models/Transaction.model';
import { AuthRequest } from '../middleware/auth.middleware';

// Activate boost
export const activateBoost = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const { boostType, paymentId, isFree } = req.body;

    if (!boostType || !['standard', 'featured'].includes(boostType)) {
      res.status(400).json({
        success: false,
        message: 'Invalid boost type.',
      });
      return;
    }

    // Get app settings
    const settings = await AppSettings.findOne();
    if (!settings) {
      res.status(500).json({
        success: false,
        message: 'App settings not configured.',
      });
      return;
    }

    const user = await User.findById(userId);
    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    // Check if payment is required
    const rolePricing = settings.boostPricing[boostType as 'standard' | 'featured'][user.role as 'bride' | 'groom'];
    const requiresPayment = settings.paymentEnabled && !settings.allowFreePosting && rolePricing.price > 0;

    if (requiresPayment && !isFree && !paymentId) {
      res.status(400).json({
        success: false,
        message: 'Payment required to activate boost.',
      });
      return;
    }

    // If payment required, verify payment
    if (paymentId && !isFree) {
      const transaction = await Transaction.findOne({ 
        _id: paymentId,
        userId,
        status: 'completed',
      });

      if (!transaction) {
        res.status(400).json({
          success: false,
          message: 'Invalid or incomplete payment.',
        });
        return;
      }
    }

    // Calculate expiration date
    const duration = rolePricing.duration; // days
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + duration);

    // Update user boost status
    user.boostStatus = 'active';
    user.boostType = boostType;
    user.boostExpiresAt = expiresAt;
    user.boostStartedAt = new Date();
    await user.save();

    const daysLeft = Math.ceil((expiresAt.getTime() - Date.now()) / (1000 * 60 * 60 * 24));

    res.json({
      success: true,
      message: 'Boost activated successfully.',
      boost: {
        status: 'active',
        type: boostType,
        expiresAt,
        daysLeft,
        startedAt: user.boostStartedAt,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to activate boost.',
    });
  }
};

// Get boost status
export const getBoostStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    const user = await User.findById(userId).select('boostStatus boostType boostExpiresAt boostStartedAt');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    // Check if boost is expired
    if (user.boostStatus === 'active' && user.boostExpiresAt && user.boostExpiresAt < new Date()) {
      user.boostStatus = 'expired';
      await user.save();
    }

    let daysLeft = 0;
    if (user.boostExpiresAt && user.boostStatus === 'active') {
      daysLeft = Math.ceil((user.boostExpiresAt.getTime() - Date.now()) / (1000 * 60 * 60 * 24));
    }

    res.json({
      success: true,
      boostStatus: user.boostStatus,
      boostType: user.boostType,
      expiresAt: user.boostExpiresAt,
      daysLeft,
      startedAt: user.boostStartedAt,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch boost status.',
    });
  }
};
