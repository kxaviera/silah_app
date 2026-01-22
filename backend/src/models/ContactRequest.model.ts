import mongoose, { Document, Schema } from 'mongoose';

export interface IContactRequest extends Document {
  fromUserId: mongoose.Types.ObjectId;
  toUserId: mongoose.Types.ObjectId;
  requestType: 'mobile' | 'photos' | 'both';
  status: 'pending' | 'accepted' | 'rejected';
  isRead: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const ContactRequestSchema = new Schema<IContactRequest>(
  {
    fromUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    toUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    requestType: {
      type: String,
      enum: ['mobile', 'photos', 'both'],
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'rejected'],
      default: 'pending',
    },
    isRead: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
ContactRequestSchema.index({ fromUserId: 1, toUserId: 1 });
ContactRequestSchema.index({ toUserId: 1, status: 1 });
ContactRequestSchema.index({ fromUserId: 1, status: 1 });

export const ContactRequest = mongoose.model<IContactRequest>('ContactRequest', ContactRequestSchema);
