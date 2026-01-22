import mongoose, { Document, Schema } from 'mongoose';

export interface IFCMToken extends Document {
  userId: mongoose.Types.ObjectId;
  token: string;
  deviceType?: 'android' | 'ios' | 'web';
  createdAt: Date;
  updatedAt: Date;
}

const FCMTokenSchema = new Schema<IFCMToken>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    token: {
      type: String,
      required: true,
      unique: true,
    },
    deviceType: {
      type: String,
      enum: ['android', 'ios', 'web'],
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
FCMTokenSchema.index({ userId: 1 });
FCMTokenSchema.index({ token: 1 });

export const FCMToken = mongoose.model<IFCMToken>('FCMToken', FCMTokenSchema);
