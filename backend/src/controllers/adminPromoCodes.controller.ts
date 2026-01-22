import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { PromoCode } from '../models/PromoCode.model';
import { Transaction } from '../models/Transaction.model';
import mongoose from 'mongoose';

// Get all promo codes
export const getPromoCodes = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { isActive, search } = req.query;

    const query: any = {};
    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }
    if (search) {
      query.code = { $regex: search, $options: 'i' };
    }

    const promoCodes = await PromoCode.find(query)
      .sort({ createdAt: -1 })
      .lean();

    res.status(200).json({
      success: true,
      promoCodes,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch promo codes',
    });
  }
};

// Get promo code by ID
export const getPromoCodeById = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const promoCode = await PromoCode.findById(id).lean();

    if (!promoCode) {
      res.status(404).json({
        success: false,
        message: 'Promo code not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      promoCode,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch promo code',
    });
  }
};

// Create promo code
export const createPromoCode = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const {
      code,
      description,
      discountType,
      discountValue,
      minAmount,
      maxDiscount,
      validFrom,
      validUntil,
      usageLimit,
      userLimit,
      applicableTo,
      applicableBoostType,
      isActive,
    } = req.body;

    // Validate required fields
    if (!code || !discountType || !discountValue || !validUntil) {
      res.status(400).json({
        success: false,
        message: 'Missing required fields: code, discountType, discountValue, validUntil',
      });
      return;
    }

    // Validate discount value
    if (discountType === 'percentage' && (discountValue < 0 || discountValue > 100)) {
      res.status(400).json({
        success: false,
        message: 'Percentage discount must be between 0 and 100',
      });
      return;
    }

    // Check if code already exists
    const existingCode = await PromoCode.findOne({ code: code.toUpperCase() });
    if (existingCode) {
      res.status(400).json({
        success: false,
        message: 'Promo code already exists',
      });
      return;
    }

    const promoCode = new PromoCode({
      code: code.toUpperCase(),
      description,
      discountType,
      discountValue,
      minAmount,
      maxDiscount,
      validFrom: validFrom ? new Date(validFrom) : new Date(),
      validUntil: new Date(validUntil),
      usageLimit,
      userLimit,
      applicableTo: applicableTo || 'all',
      applicableBoostType: applicableBoostType || 'all',
      isActive: isActive !== undefined ? isActive : true,
    });

    await promoCode.save();

    res.status(201).json({
      success: true,
      message: 'Promo code created successfully',
      promoCode,
    });
  } catch (error: any) {
    if (error.code === 11000) {
      res.status(400).json({
        success: false,
        message: 'Promo code already exists',
      });
      return;
    }
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create promo code',
    });
  }
};

// Update promo code
export const updatePromoCode = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Convert code to uppercase if provided
    if (updateData.code) {
      updateData.code = updateData.code.toUpperCase();
    }

    // Convert dates if provided
    if (updateData.validFrom) {
      updateData.validFrom = new Date(updateData.validFrom);
    }
    if (updateData.validUntil) {
      updateData.validUntil = new Date(updateData.validUntil);
    }

    const promoCode = await PromoCode.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!promoCode) {
      res.status(404).json({
        success: false,
        message: 'Promo code not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Promo code updated successfully',
      promoCode,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update promo code',
    });
  }
};

// Delete promo code
export const deletePromoCode = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const promoCode = await PromoCode.findByIdAndDelete(id);

    if (!promoCode) {
      res.status(404).json({
        success: false,
        message: 'Promo code not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Promo code deleted successfully',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to delete promo code',
    });
  }
};

// Get promo code usage statistics
export const getPromoCodeUsage = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const promoCode = await PromoCode.findById(id);
    if (!promoCode) {
      res.status(404).json({
        success: false,
        message: 'Promo code not found',
      });
      return;
    }

    // Get transactions using this promo code
    const transactions = await Transaction.find({
      promoCode: promoCode.code,
    })
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 })
      .lean();

    // Calculate statistics
    const totalDiscount = transactions.reduce((sum, t: any) => sum + (t.discount || 0), 0);
    const totalRevenue = transactions.reduce((sum, t: any) => sum + t.totalAmount, 0);

    res.status(200).json({
      success: true,
      promoCode: {
        ...promoCode.toObject(),
        usage: {
          totalUsage: promoCode.usageCount,
          usageLimit: promoCode.usageLimit,
          remainingUsage: promoCode.usageLimit
            ? promoCode.usageLimit - promoCode.usageCount
            : null,
          totalDiscount,
          totalRevenue,
          transactions: transactions.length,
        },
        recentTransactions: transactions.slice(0, 10), // Last 10 transactions
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch promo code usage',
    });
  }
};
