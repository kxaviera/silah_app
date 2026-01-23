import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export interface IUser extends Document {
  email: string;
  mobile?: string;
  password: string;
  googleId?: string;
  role: 'bride' | 'groom';
  fullName: string;
  dateOfBirth: Date;
  
  // Profile details
  profilePhoto?: string;
  age: number;
  gender: 'Male' | 'Female';
  height?: number;
  complexion?: string;
  
  // Location
  country: string;
  livingCountry?: string;
  state?: string;
  city?: string;
  
  // Religion & Community
  religion: string;
  caste?: string;
  
  // Education & Profession
  education?: string;
  profession?: string;
  annualIncome?: string;
  
  // About
  about?: string;
  partnerPreferences?: string;
  
  // Privacy settings
  hideMobile: boolean;
  hidePhotos: boolean;
  
  // Boost status
  boostStatus: 'none' | 'active' | 'expired';
  boostType?: 'standard' | 'featured';
  boostExpiresAt?: Date;
  boostStartedAt?: Date;
  
  // Verification
  emailVerified: boolean;
  mobileVerified: boolean;
  idVerified: boolean;
  
  // Account status
  isActive: boolean;
  isBlocked: boolean;
  isProfileComplete: boolean;
  
  // Password reset
  resetPasswordToken?: string;
  resetPasswordExpire?: Date;
  
  // Methods
  comparePassword(candidatePassword: string): Promise<boolean>;
  generateToken(): string;
  
  // Timestamps
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
    },
    mobile: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
    },
    password: {
      type: String,
      required: function(this: IUser) {
        return !this.googleId;
      },
      minlength: 6,
    },
    googleId: {
      type: String,
      unique: true,
      sparse: true,
    },
    role: {
      type: String,
      required: [true, 'Role is required'],
      enum: ['bride', 'groom'],
    },
    fullName: {
      type: String,
      required: [true, 'Full name is required'],
      trim: true,
    },
    dateOfBirth: {
      type: Date,
      required: [true, 'Date of birth is required'],
    },
    profilePhoto: String,
    age: {
      type: Number,
      required: true,
    },
    gender: {
      type: String,
      enum: ['Male', 'Female'],
      required: true,
    },
    height: Number,
    complexion: String,
    country: {
      type: String,
      required: [true, 'Country is required'],
    },
    livingCountry: String,
    state: String,
    city: {
      type: String,
      required: [true, 'City is required'],
    },
    religion: {
      type: String,
      required: [true, 'Religion is required'],
    },
    caste: String,
    education: String,
    profession: String,
    annualIncome: String,
    about: String,
    partnerPreferences: String,
    hideMobile: {
      type: Boolean,
      default: true,
    },
    hidePhotos: {
      type: Boolean,
      default: false,
    },
    boostStatus: {
      type: String,
      enum: ['none', 'active', 'expired'],
      default: 'none',
    },
    boostType: {
      type: String,
      enum: ['standard', 'featured'],
    },
    boostExpiresAt: Date,
    boostStartedAt: Date,
    emailVerified: {
      type: Boolean,
      default: false,
    },
    mobileVerified: {
      type: Boolean,
      default: false,
    },
    idVerified: {
      type: Boolean,
      default: false,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    isBlocked: {
      type: Boolean,
      default: false,
    },
    isProfileComplete: {
      type: Boolean,
      default: false,
    },
    resetPasswordToken: String,
    resetPasswordExpire: Date,
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Calculate age from date of birth
UserSchema.pre('save', function (next) {
  if (this.dateOfBirth && !this.age) {
    const today = new Date();
    const birthDate = new Date(this.dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    this.age = age;
  }
  next();
});

// Method to compare password
UserSchema.methods.comparePassword = async function (candidatePassword: string): Promise<boolean> {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to generate JWT token
UserSchema.methods.generateToken = function (): string {
  const JWT_SECRET = process.env.JWT_SECRET;
  const JWT_EXPIRE = process.env.JWT_EXPIRE || '7d';
  
  if (!JWT_SECRET) {
    throw new Error('JWT_SECRET is not defined');
  }
  
  return jwt.sign(
    { id: this._id.toString(), role: this.role } as object,
    JWT_SECRET,
    { expiresIn: JWT_EXPIRE } as jwt.SignOptions
  );
};

// Indexes
UserSchema.index({ email: 1 });
UserSchema.index({ role: 1 });
UserSchema.index({ country: 1 });
UserSchema.index({ city: 1 });
UserSchema.index({ religion: 1 });
UserSchema.index({ boostStatus: 1 });
UserSchema.index({ isActive: 1, isBlocked: 1 });

export const User = mongoose.model<IUser>('User', UserSchema);
