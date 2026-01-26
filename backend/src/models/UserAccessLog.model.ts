import mongoose, { Document, Schema } from 'mongoose';

/**
 * User access log for compliance: IP + timestamp per login/access.
 * Retain for minimum one year from account deactivation (deletedAt).
 */
export interface IUserAccessLog extends Document {
  userId: mongoose.Types.ObjectId;
  ipAddress: string;
  userAgent?: string;
  action: 'registration' | 'login' | 'google_login';
  createdAt: Date;
}

const UserAccessLogSchema = new Schema<IUserAccessLog>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    ipAddress: {
      type: String,
      required: true,
    },
    userAgent: {
      type: String,
    },
    action: {
      type: String,
      enum: ['registration', 'login', 'google_login'],
      required: true,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

UserAccessLogSchema.index({ userId: 1, createdAt: -1 });
UserAccessLogSchema.index({ createdAt: -1 });

export const UserAccessLog = mongoose.model<IUserAccessLog>('UserAccessLog', UserAccessLogSchema);
