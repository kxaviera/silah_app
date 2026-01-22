import mongoose, { Document, Schema } from 'mongoose';

export interface INotificationPreference extends Document {
  userId: mongoose.Types.ObjectId;
  newRequest: boolean;
  requestAccepted: boolean;
  requestRejected: boolean;
  newMessage: boolean;
  profileMatch: boolean;
  boostExpiring: boolean;
  boostExpired: boolean;
  profileViewed: boolean;
  system: boolean;
  paymentSuccess: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const NotificationPreferenceSchema = new Schema<INotificationPreference>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    newRequest: {
      type: Boolean,
      default: true,
    },
    requestAccepted: {
      type: Boolean,
      default: true,
    },
    requestRejected: {
      type: Boolean,
      default: true,
    },
    newMessage: {
      type: Boolean,
      default: true,
    },
    profileMatch: {
      type: Boolean,
      default: true,
    },
    boostExpiring: {
      type: Boolean,
      default: true,
    },
    boostExpired: {
      type: Boolean,
      default: true,
    },
    profileViewed: {
      type: Boolean,
      default: false,
    },
    system: {
      type: Boolean,
      default: true,
    },
    paymentSuccess: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

NotificationPreferenceSchema.index({ userId: 1 });

export const NotificationPreference = mongoose.model<INotificationPreference>('NotificationPreference', NotificationPreferenceSchema);
