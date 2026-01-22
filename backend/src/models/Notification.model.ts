import mongoose, { Document, Schema } from 'mongoose';

export interface INotification extends Document {
  userId: mongoose.Types.ObjectId;
  type: 'new_request' | 'request_accepted' | 'request_rejected' | 'new_message' | 'profile_match' | 'boost_expiring' | 'boost_expired' | 'profile_viewed' | 'system' | 'payment_success';
  title: string;
  message: string;
  relatedUserId?: mongoose.Types.ObjectId;
  relatedRequestId?: mongoose.Types.ObjectId;
  relatedConversationId?: mongoose.Types.ObjectId;
  isRead: boolean;
  readAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const NotificationSchema = new Schema<INotification>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    type: {
      type: String,
      enum: ['new_request', 'request_accepted', 'request_rejected', 'new_message', 'profile_match', 'boost_expiring', 'boost_expired', 'profile_viewed', 'system', 'payment_success'],
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    relatedUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    relatedRequestId: {
      type: Schema.Types.ObjectId,
      ref: 'ContactRequest',
    },
    relatedConversationId: {
      type: Schema.Types.ObjectId,
      ref: 'Conversation',
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    readAt: Date,
  },
  {
    timestamps: true,
  }
);

// Indexes
NotificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });
NotificationSchema.index({ userId: 1, createdAt: -1 });

export const Notification = mongoose.model<INotification>('Notification', NotificationSchema);
