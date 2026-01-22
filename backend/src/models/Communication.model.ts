import mongoose, { Document, Schema } from 'mongoose';

export interface ICommunication extends Document {
  type: 'email' | 'sms' | 'push';
  recipientId?: mongoose.Types.ObjectId;
  recipientEmail?: string;
  recipientPhone?: string;
  subject?: string;
  message: string;
  templateId?: mongoose.Types.ObjectId;
  status: 'pending' | 'sent' | 'delivered' | 'failed';
  sentAt?: Date;
  deliveredAt?: Date;
  error?: string;
  metadata?: Record<string, any>;
  sentBy?: mongoose.Types.ObjectId; // Admin who sent it
  createdAt: Date;
}

const CommunicationSchema = new Schema<ICommunication>(
  {
    type: {
      type: String,
      enum: ['email', 'sms', 'push'],
      required: true,
    },
    recipientId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    recipientEmail: {
      type: String,
    },
    recipientPhone: {
      type: String,
    },
    subject: {
      type: String,
    },
    message: {
      type: String,
      required: true,
    },
    templateId: {
      type: Schema.Types.ObjectId,
      ref: 'EmailTemplate',
    },
    status: {
      type: String,
      enum: ['pending', 'sent', 'delivered', 'failed'],
      default: 'pending',
    },
    sentAt: {
      type: Date,
    },
    deliveredAt: {
      type: Date,
    },
    error: {
      type: String,
    },
    metadata: {
      type: Schema.Types.Mixed,
    },
    sentBy: {
      type: Schema.Types.ObjectId,
      ref: 'AdminUser',
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
CommunicationSchema.index({ recipientId: 1, createdAt: -1 });
CommunicationSchema.index({ status: 1 });
CommunicationSchema.index({ type: 1, createdAt: -1 });
CommunicationSchema.index({ sentBy: 1 });

export const Communication = mongoose.model<ICommunication>('Communication', CommunicationSchema);
