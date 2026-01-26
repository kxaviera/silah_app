import { Request, Response } from 'express';
import { User } from '../models/User.model';
import { UserAccessLog } from '../models/UserAccessLog.model';
import { OAuth2Client } from 'google-auth-library';
import crypto from 'crypto';
import { emailService } from '../services/email.service';
import { AuthRequest } from '../middleware/auth.middleware';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/** Get client IP (behind proxy: x-forwarded-for first segment, else req.ip) */
function getClientIp(req: Request): string {
  const forwarded = req.headers['x-forwarded-for'];
  if (forwarded) {
    const first = typeof forwarded === 'string' ? forwarded.split(',')[0] : forwarded[0];
    if (first) return first.trim();
  }
  return req.ip || req.socket?.remoteAddress || '';
}

// Register (basic signup - only email, password - fullName and role will be set in complete profile)
export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const { fullName, email, password, role, mobile } = req.body;

    // Validation - fullName and role are now optional (will be set in complete profile)
    if (!email || !password) {
      res.status(400).json({
        success: false,
        message: 'Please provide all required fields: email and password.',
      });
      return;
    }

    // Check if user exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      res.status(400).json({
        success: false,
        message: 'User already exists with this email.',
      });
      return;
    }

    // Check mobile if provided
    if (mobile) {
      const existingMobile = await User.findOne({ mobile });
      if (existingMobile) {
        res.status(400).json({
          success: false,
          message: 'User already exists with this mobile number.',
        });
        return;
      }
    }

    const clientIp = getClientIp(req);
    const userAgent = (req.headers['user-agent'] as string) || undefined;

    // Create user with basic info only (fullName and role will be set in complete profile if not provided)
    const user = await User.create({
      fullName: fullName || 'User', // Temporary name, will be updated in complete profile
      email: email.toLowerCase(),
      password,
      role: role || 'groom', // Default to 'groom' if not provided, will be updated in complete profile
      mobile: mobile || undefined,
      isProfileComplete: false,
      registrationIp: clientIp || undefined,
    });

    await UserAccessLog.create({
      userId: user._id,
      ipAddress: clientIp || 'unknown',
      userAgent,
      action: 'registration',
    });

    const token = user.generateToken();

    res.status(201).json({
      success: true,
      message: 'Registration successful.',
      token,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        fullName: user.fullName,
        isProfileComplete: user.isProfileComplete,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Registration failed.',
    });
  }
};

// Login
export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { emailOrMobile, password } = req.body;

    if (!emailOrMobile || !password) {
      res.status(400).json({
        success: false,
        message: 'Please provide email/mobile and password.',
      });
      return;
    }

    // Find user by email or mobile
    const user = await User.findOne({
      $or: [
        { email: emailOrMobile.toLowerCase() },
        { mobile: emailOrMobile },
      ],
    });

    if (!user) {
      res.status(401).json({
        success: false,
        message: 'Invalid credentials.',
      });
      return;
    }

    if (!user.password) {
      res.status(401).json({
        success: false,
        message: 'Please login with Google Sign-In.',
      });
      return;
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      res.status(401).json({
        success: false,
        message: 'Invalid credentials.',
      });
      return;
    }

    if (!user.isActive || user.isBlocked) {
      res.status(401).json({
        success: false,
        message: 'Account is inactive or blocked.',
      });
      return;
    }

    const clientIp = getClientIp(req);
    const userAgent = (req.headers['user-agent'] as string) || undefined;
    await UserAccessLog.create({
      userId: user._id,
      ipAddress: clientIp || 'unknown',
      userAgent,
      action: 'login',
    });

    const token = user.generateToken();

    res.json({
      success: true,
      message: 'Login successful.',
      token,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        fullName: user.fullName,
        isProfileComplete: user.isProfileComplete,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Login failed.',
    });
  }
};

// Google Sign-In
export const googleSignIn = async (req: Request, res: Response): Promise<void> => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      res.status(400).json({
        success: false,
        message: 'Google ID token is required.',
      });
      return;
    }

    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    if (!payload) {
      res.status(400).json({
        success: false,
        message: 'Invalid Google token.',
      });
      return;
    }

    const { email, name, sub: googleId, picture } = payload;

    if (!email) {
      res.status(400).json({
        success: false,
        message: 'Email not provided by Google.',
      });
      return;
    }

    // Find or create user
    let user = await User.findOne({ email: email.toLowerCase() });

    if (user) {
      // Update Google ID if not set
      if (!user.googleId) {
        user.googleId = googleId;
        if (picture) user.profilePhoto = picture;
        await user.save();
      }
    } else {
      const clientIp = getClientIp(req);
      user = await User.create({
        email: email.toLowerCase(),
        googleId,
        fullName: name || 'User',
        role: 'groom', // Default, user will need to set this
        dateOfBirth: new Date('1990-01-01'), // Placeholder, user will need to set
        age: 30, // Placeholder
        gender: 'Male', // Placeholder
        country: 'India', // Default
        city: 'Mumbai', // Default
        religion: 'Hindu', // Default
        profilePhoto: picture,
        isProfileComplete: false,
        registrationIp: clientIp || undefined,
      });
    }

    if (!user.isActive || user.isBlocked) {
      res.status(401).json({
        success: false,
        message: 'Account is inactive or blocked.',
      });
      return;
    }

    const clientIp = getClientIp(req);
    const userAgent = (req.headers['user-agent'] as string) || undefined;
    await UserAccessLog.create({
      userId: user._id,
      ipAddress: clientIp || 'unknown',
      userAgent,
      action: 'google_login',
    });

    const token = user.generateToken();

    res.json({
      success: true,
      message: 'Google Sign-In successful.',
      token,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        fullName: user.fullName,
        isProfileComplete: user.isProfileComplete,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Google Sign-In failed.',
    });
  }
};

// Get current user
export const getMe = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const user = await User.findById(req.user._id).select('-password');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    res.json({
      success: true,
      user,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch user.',
    });
  }
};

// Forgot password
export const forgotPassword = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email } = req.body;

    if (!email) {
      res.status(400).json({
        success: false,
        message: 'Email is required.',
      });
      return;
    }

    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      // Don't reveal if user exists
      res.json({
        success: true,
        message: 'If an account exists with this email, a password reset link has been sent.',
      });
      return;
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    user.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
    user.resetPasswordExpire = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await user.save();

    // Send email (implement email service)
    const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
    
    try {
      const emailResult = await emailService.sendEmail({
        to: user.email,
        subject: 'Password Reset Request',
        html: `
          <h2>Password Reset Request</h2>
          <p>You requested a password reset. Click the link below to reset your password:</p>
          <a href="${resetUrl}">${resetUrl}</a>
          <p>This link will expire in 10 minutes.</p>
          <p>If you didn't request this, please ignore this email.</p>
        `,
      });

      if (!emailResult.success) {
        throw new Error(emailResult.error || 'Failed to send email');
      }

      res.json({
        success: true,
        message: 'Password reset email sent.',
      });
    } catch (emailError: any) {
      user.resetPasswordToken = undefined;
      user.resetPasswordExpire = undefined;
      await user.save();

      res.status(500).json({
        success: false,
        message: emailError.message || 'Failed to send email. Please try again later.',
      });
    }
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to process request.',
    });
  }
};

// Reset password
export const resetPassword = async (req: Request, res: Response): Promise<void> => {
  try {
    const { token, password } = req.body;

    if (!token || !password) {
      res.status(400).json({
        success: false,
        message: 'Token and password are required.',
      });
      return;
    }

    // Hash token
    const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

    // Find user with valid token
    const user = await User.findOne({
      resetPasswordToken: hashedToken,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      res.status(400).json({
        success: false,
        message: 'Invalid or expired token.',
      });
      return;
    }

    // Update password
    user.password = password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    res.json({
      success: true,
      message: 'Password reset successful.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to reset password.',
    });
  }
};

// Logout
export const logout = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    // In a stateless JWT system, logout is handled client-side by removing the token
    // But we can add token blacklisting here if needed

    res.json({
      success: true,
      message: 'Logout successful.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Logout failed.',
    });
  }
};

/** Valid deletion reasons (user-initiated profile delete) */
const VALID_DELETION_REASONS = [
  'found_match_silah',
  'found_match_elsewhere',
  'not_interested',
  'privacy_concerns',
  'taking_break',
  'other',
] as const;

// Delete account (soft delete, with reason)
export const deleteAccount = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const { reason, otherReason } = req.body;

    if (!reason || typeof reason !== 'string' || !reason.trim()) {
      res.status(400).json({
        success: false,
        message: 'Please select a reason for deleting your profile.',
      });
      return;
    }

    const r = reason.trim();
    if (!VALID_DELETION_REASONS.includes(r as any)) {
      res.status(400).json({
        success: false,
        message: 'Invalid reason. Please select a valid option.',
      });
      return;
    }

    const user = await User.findById(userId);
    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    const updateData: any = {
      isActive: false,
      deletedAt: new Date(),
      deletionReason: r,
    };
    if (r === 'other' && otherReason != null && typeof otherReason === 'string' && otherReason.trim()) {
      updateData.deletionOtherReason = otherReason.trim();
    }

    await User.findByIdAndUpdate(userId, updateData);

    res.json({
      success: true,
      message: 'Your profile has been deleted. You can sign up again anytime.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to delete account.',
    });
  }
};
