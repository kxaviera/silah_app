import express, { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppSettings } from '../models/AppSettings.model';
import { Transaction } from '../models/Transaction.model';
import { PromoCode } from '../models/PromoCode.model';

// Create payment intent (simplified - integrate Stripe later)
export const createPaymentIntent = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const { boostType, promoCode } = req.body;

    if (!boostType || !['standard', 'featured'].includes(boostType)) {
      res.status(400).json({
        success: false,
        message: 'Invalid boost type.',
      });
      return;
    }

    const user = await import('../models/User.model').then(m => m.User.findById(userId));
    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    const settings = await AppSettings.findOne();
    if (!settings) {
      res.status(500).json({
        success: false,
        message: 'App settings not configured.',
      });
      return;
    }

    const rolePricing = settings.boostPricing[boostType as 'standard' | 'featured'][user.role as 'bride' | 'groom'];
    let amount = rolePricing.price; // in paise
    let discount = 0;
    let promoCodeUsed = null;

    // Validate promo code if provided
    if (promoCode) {
      const promo = await PromoCode.findOne({
        code: promoCode.toUpperCase(),
        isActive: true,
        validFrom: { $lte: new Date() },
        validUntil: { $gte: new Date() },
        $expr: { $lt: ['$usedCount', { $ifNull: ['$usageLimit', 999999] }] },
      });

      if (promo) {
        promoCodeUsed = promo.code;
        if (promo.discountType === 'percentage') {
          discount = Math.floor((amount * promo.discountValue) / 100);
          if (promo.maxDiscount) {
            discount = Math.min(discount, promo.maxDiscount);
          }
        } else {
          discount = promo.discountValue;
        }
        amount -= discount;
      }
    }

    // Calculate GST (18%)
    const gstAmount = Math.floor((amount * 18) / 100);
    const totalAmount = amount + gstAmount;

    // Generate invoice number
    const invoiceNumber = `INV-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;

    // Create transaction record
    const transaction = await Transaction.create({
      userId,
      type: 'boost',
      boostType,
      userRole: user.role,
      amount: totalAmount - gstAmount - discount, // Base amount before GST and discount
      currency: 'INR',
      discount: discount,
      gstAmount: gstAmount,
      totalAmount: totalAmount,
      promoCode: promoCodeUsed || undefined,
      paymentMethod: 'stripe', // Will be updated after payment
      status: 'pending',
      invoiceNumber: invoiceNumber,
    });

    // In production, create Stripe payment intent here
    // For now, return transaction details
    res.json({
      success: true,
      transactionId: transaction._id,
      amount: totalAmount,
      invoiceNumber,
      // In production, include: clientSecret, paymentIntentId
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create payment intent.',
    });
  }
};

// Verify payment (simplified - integrate Stripe webhook later)
export const verifyPayment = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { transactionId, paymentIntentId } = req.body;

    const transaction = await Transaction.findById(transactionId);
    if (!transaction) {
      res.status(404).json({
        success: false,
        message: 'Transaction not found.',
      });
      return;
    }

    // In production, verify with Stripe
    // For now, mark as completed
    transaction.status = 'completed';
    transaction.paymentIntentId = paymentIntentId;
    await transaction.save();

    // Activate boost
    const { activateBoost } = await import('./boost.controller');
    req.body = { boostType: transaction.boostType, paymentId: transactionId, isFree: false };
    // Note: This is a simplified approach. In production, handle boost activation separately.

    res.json({
      success: true,
      message: 'Payment verified successfully.',
      transaction,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to verify payment.',
    });
  }
};

// Get invoice
export const getInvoice = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { invoiceNumber } = req.params;
    const userId = req.user._id;

    const transaction = await Transaction.findOne({
      invoiceNumber: invoiceNumber,
      userId,
    });

    if (!transaction) {
      res.status(404).json({
        success: false,
        message: 'Invoice not found.',
      });
      return;
    }

    const settings = await AppSettings.findOne();
    const user = await import('../models/User.model').then(m => m.User.findById(userId));

    res.json({
      success: true,
      invoice: {
        invoiceNumber: transaction.invoiceNumber,
        invoiceDate: transaction.createdAt,
        user: {
          name: user?.fullName,
          email: user?.email,
        },
        item: {
          description: `${transaction.boostType} Boost`,
          quantity: 1,
          amount: transaction.amount - transaction.gstAmount - (transaction.discount || 0),
        },
        discount: transaction.discount || 0,
        gstAmount: transaction.gstAmount,
        totalAmount: transaction.amount,
        company: settings?.company,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch invoice.',
    });
  }
};

// Validate promo code
export const validatePromoCode = async (req: express.Request, res: Response): Promise<void> => {
  try {
    const { code, amount } = req.body;

    if (!code) {
      res.status(400).json({
        success: false,
        message: 'Promo code is required.',
      });
      return;
    }

    const promo = await PromoCode.findOne({
      code: code.toUpperCase(),
      isActive: true,
      validFrom: { $lte: new Date() },
      validUntil: { $gte: new Date() },
      $expr: { $lt: ['$usedCount', { $ifNull: ['$usageLimit', 999999] }] },
    });

    if (!promo) {
      res.status(400).json({
        success: false,
        message: 'Invalid or expired promo code.',
      });
      return;
    }

    // Check minimum amount if specified
    if (promo.minAmount && amount < promo.minAmount) {
      res.status(400).json({
        success: false,
        message: `Minimum purchase amount is ₹${promo.minAmount / 100}.`,
      });
      return;
    }

    let discount = 0;
    if (promo.discountType === 'percentage') {
      discount = Math.floor((amount * promo.discountValue) / 100);
      if (promo.maxDiscount) {
        discount = Math.min(discount, promo.maxDiscount);
      }
    } else {
      discount = promo.discountValue;
    }

    res.json({
      success: true,
      discount,
      discountType: promo.discountType,
      discountValue: promo.discountValue,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to validate promo code.',
    });
  }
};
