import mongoose, { Document, Schema } from 'mongoose';

export interface IProfileView extends Document {
  profileUserId: mongoose.Types.ObjectId;
  viewerUserId: mongoose.Types.ObjectId;
  viewedAt: Date;
  createdAt: Date;
}

const ProfileViewSchema = new Schema<IProfileView>(
  {
    profileUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    viewerUserId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    viewedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
ProfileViewSchema.index({ profileUserId: 1, viewedAt: -1 });
ProfileViewSchema.index({ viewerUserId: 1 });

export const ProfileView = mongoose.model<IProfileView>('ProfileView', ProfileViewSchema);
