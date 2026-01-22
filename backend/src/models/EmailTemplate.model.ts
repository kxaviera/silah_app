import mongoose, { Document, Schema } from 'mongoose';

export interface IEmailTemplate extends Document {
  name: string;
  subject: string;
  body: string; // HTML body
  variables?: string[]; // Available variables like {{name}}, {{email}}
  category: 'welcome' | 'boost' | 'reminder' | 'notification' | 'custom';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const EmailTemplateSchema = new Schema<IEmailTemplate>(
  {
    name: {
      type: String,
      required: true,
      unique: true,
    },
    subject: {
      type: String,
      required: true,
    },
    body: {
      type: String,
      required: true,
    },
    variables: [{
      type: String,
    }],
    category: {
      type: String,
      enum: ['welcome', 'boost', 'reminder', 'notification', 'custom'],
      default: 'custom',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

export const EmailTemplate = mongoose.model<IEmailTemplate>('EmailTemplate', EmailTemplateSchema);
