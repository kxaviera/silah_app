import mongoose, { Document, Schema } from 'mongoose';

export interface ITransaction extends Document {
  userId: mongoose.Types.ObjectId;
  type: 'boost' | 'repost';
  boostType: 'standard' | 'featured';
  userRole: 'bride' | 'groom';
  amount: number; // in paise
  currency: string;
  discount?: number;
  gstAmount: number;
  totalAmount: number;
  promoCode?: string;
  paymentMethod: string;
  paymentIntentId?: string;
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  invoiceNumber: string;
  invoiceDate: Date;
  refundedAt?: Date;
  refundAmount?: number;
  refundReason?: string;
  createdAt: Date;
  updatedAt: Date;
}

const TransactionSchema = new Schema<ITransaction>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    type: {
      type: String,
      enum: ['boost', 'repost'],
      required: true,
    },
    boostType: {
      type: String,
      enum: ['standard', 'featured'],
      required: true,
    },
    userRole: {
      type: String,
      enum: ['bride', 'groom'],
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      default: 'INR',
    },
    discount: {
      type: Number,
      default: 0,
    },
    gstAmount: {
      type: Number,
      required: true,
    },
    totalAmount: {
      type: Number,
      required: true,
    },
    promoCode: {
      type: String,
    },
    paymentMethod: {
      type: String,
      required: true,
    },
    paymentIntentId: {
      type: String,
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded'],
      default: 'pending',
    },
    invoiceNumber: {
      type: String,
      required: true,
      unique: true,
    },
    invoiceDate: {
      type: Date,
      default: Date.now,
    },
    refundedAt: {
      type: Date,
    },
    refundAmount: {
      type: Number,
    },
    refundReason: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
TransactionSchema.index({ userId: 1 });
TransactionSchema.index({ status: 1 });
TransactionSchema.index({ createdAt: -1 });
TransactionSchema.index({ invoiceNumber: 1 });

export const Transaction = mongoose.model<ITransaction>('Transaction', TransactionSchema);
