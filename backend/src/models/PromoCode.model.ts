import mongoose, { Document, Schema } from 'mongoose';

export interface IPromoCode extends Document {
  code: string;
  description?: string;
  discountType: 'percentage' | 'fixed';
  discountValue: number; // percentage (0-100) or fixed amount in paise
  minAmount?: number; // Minimum transaction amount in paise
  maxDiscount?: number; // Maximum discount in paise (for percentage)
  validFrom: Date;
  validUntil: Date;
  usageLimit?: number; // Total usage limit
  usageCount: number; // Current usage count
  userLimit?: number; // Usage limit per user
  applicableTo: 'all' | 'bride' | 'groom';
  applicableBoostType?: 'all' | 'standard' | 'featured';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const PromoCodeSchema = new Schema<IPromoCode>(
  {
    code: {
      type: String,
      required: [true, 'Promo code is required'],
      unique: true,
      uppercase: true,
      trim: true,
      match: [/^[A-Z0-9]+$/, 'Promo code must contain only uppercase letters and numbers'],
    },
    description: {
      type: String,
    },
    discountType: {
      type: String,
      enum: ['percentage', 'fixed'],
      required: true,
    },
    discountValue: {
      type: Number,
      required: true,
      min: [0, 'Discount value must be positive'],
    },
    minAmount: {
      type: Number,
      min: 0,
    },
    maxDiscount: {
      type: Number,
      min: 0,
    },
    validFrom: {
      type: Date,
      required: true,
      default: Date.now,
    },
    validUntil: {
      type: Date,
      required: true,
    },
    usageLimit: {
      type: Number,
      min: 1,
    },
    usageCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    userLimit: {
      type: Number,
      min: 1,
    },
    applicableTo: {
      type: String,
      enum: ['all', 'bride', 'groom'],
      default: 'all',
    },
    applicableBoostType: {
      type: String,
      enum: ['all', 'standard', 'featured'],
      default: 'all',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
PromoCodeSchema.index({ code: 1 });
PromoCodeSchema.index({ isActive: 1 });
PromoCodeSchema.index({ validFrom: 1, validUntil: 1 });

// Virtual for checking if promo code is valid
PromoCodeSchema.virtual('isValid').get(function () {
  const now = new Date();
  return (
    this.isActive &&
    this.validFrom <= now &&
    this.validUntil >= now &&
    (!this.usageLimit || this.usageCount < this.usageLimit)
  );
});

export const PromoCode = mongoose.model<IPromoCode>('PromoCode', PromoCodeSchema);
