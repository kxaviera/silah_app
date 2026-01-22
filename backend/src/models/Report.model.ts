import mongoose, { Document, Schema } from 'mongoose';

export interface IReport extends Document {
  reporterId: mongoose.Types.ObjectId;
  reportedUserId: mongoose.Types.ObjectId;
  reason: string;
  description?: string;
  status: 'pending' | 'reviewed' | 'resolved';
  resolvedBy?: mongoose.Types.ObjectId;
  resolvedAt?: Date;
  resolutionAction?: 'block' | 'dismiss';
  resolutionNotes?: string;
  createdAt: Date;
  updatedAt: Date;
}

const ReportSchema = new Schema<IReport>(
  {
    reporterId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    reportedUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    reason: {
      type: String,
      required: true,
    },
    description: {
      type: String,
    },
    status: {
      type: String,
      enum: ['pending', 'reviewed', 'resolved'],
      default: 'pending',
    },
    resolvedBy: {
      type: Schema.Types.ObjectId,
      ref: 'AdminUser',
    },
    resolvedAt: {
      type: Date,
    },
    resolutionAction: {
      type: String,
      enum: ['block', 'dismiss'],
    },
    resolutionNotes: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
ReportSchema.index({ reporterId: 1 });
ReportSchema.index({ reportedUserId: 1 });
ReportSchema.index({ status: 1 });
ReportSchema.index({ createdAt: -1 });

export const Report = mongoose.model<IReport>('Report', ReportSchema);
