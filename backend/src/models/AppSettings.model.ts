import mongoose, { Document, Schema } from 'mongoose';

export interface IBoostPricing {
  standard: {
    bride: { price: number; duration: number; enabled: boolean };
    groom: { price: number; duration: number; enabled: boolean };
  };
  featured: {
    bride: { price: number; duration: number; enabled: boolean };
    groom: { price: number; duration: number; enabled: boolean };
  };
}

export interface ICompanyDetails {
  name: string;
  gstin: string;
  email: string;
  phone: string;
  address: string;
}

export interface IAppSettings extends Document {
  paymentEnabled: boolean;
  allowFreePosting: boolean;
  boostPricing: IBoostPricing;
  company: ICompanyDetails;
  app: {
    termsUrl: string;
    privacyUrl: string;
  };
  updatedAt: Date;
}

const BoostPricingSchema = new Schema(
  {
    standard: {
      bride: {
        price: { type: Number, required: true },
        duration: { type: Number, required: true },
        enabled: { type: Boolean, default: true },
      },
      groom: {
        price: { type: Number, required: true },
        duration: { type: Number, required: true },
        enabled: { type: Boolean, default: true },
      },
    },
    featured: {
      bride: {
        price: { type: Number, required: true },
        duration: { type: Number, required: true },
        enabled: { type: Boolean, default: true },
      },
      groom: {
        price: { type: Number, required: true },
        duration: { type: Number, required: true },
        enabled: { type: Boolean, default: true },
      },
    },
  },
  { _id: false }
);

const CompanyDetailsSchema = new Schema(
  {
    name: { type: String, required: true },
    gstin: { type: String, required: true },
    email: { type: String, required: true },
    phone: { type: String, required: true },
    address: { type: String, required: true },
  },
  { _id: false }
);

const AppSettingsSchema = new Schema<IAppSettings>(
  {
    paymentEnabled: {
      type: Boolean,
      default: false,
    },
    allowFreePosting: {
      type: Boolean,
      default: true,
    },
    boostPricing: {
      type: BoostPricingSchema,
      required: true,
    },
    company: {
      type: CompanyDetailsSchema,
      required: true,
    },
    app: {
      termsUrl: { type: String, default: '' },
      privacyUrl: { type: String, default: '' },
    },
  },
  {
    timestamps: true,
  }
);

// Ensure only one settings document exists
AppSettingsSchema.index({ _id: 1 }, { unique: true });

export const AppSettings = mongoose.model<IAppSettings>('AppSettings', AppSettingsSchema);
