import mongoose, { Document, Schema } from 'mongoose';

export interface IActivityLog extends Document {
  adminId?: mongoose.Types.ObjectId;
  userId?: mongoose.Types.ObjectId;
  action: string; // e.g., 'user.blocked', 'user.verified', 'report.resolved'
  entityType: string; // e.g., 'user', 'report', 'transaction', 'settings'
  entityId?: mongoose.Types.ObjectId;
  description: string;
  metadata?: Record<string, any>; // Additional data
  ipAddress?: string;
  userAgent?: string;
  createdAt: Date;
}

const ActivityLogSchema = new Schema<IActivityLog>(
  {
    adminId: {
      type: Schema.Types.ObjectId,
      ref: 'AdminUser',
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    action: {
      type: String,
      required: true,
      index: true,
    },
    entityType: {
      type: String,
      required: true,
      index: true,
    },
    entityId: {
      type: Schema.Types.ObjectId,
    },
    description: {
      type: String,
      required: true,
    },
    metadata: {
      type: Schema.Types.Mixed,
    },
    ipAddress: {
      type: String,
    },
    userAgent: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
ActivityLogSchema.index({ adminId: 1, createdAt: -1 });
ActivityLogSchema.index({ userId: 1, createdAt: -1 });
ActivityLogSchema.index({ action: 1, createdAt: -1 });
ActivityLogSchema.index({ entityType: 1, entityId: 1 });
ActivityLogSchema.index({ createdAt: -1 });

export const ActivityLog = mongoose.model<IActivityLog>('ActivityLog', ActivityLogSchema);
