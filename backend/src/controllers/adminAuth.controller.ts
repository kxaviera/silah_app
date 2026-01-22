import { Request, Response } from 'express';
import { AdminUser } from '../models/AdminUser.model';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';

// Login
export const adminLogin = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      res.status(400).json({
        success: false,
        message: 'Please provide email and password',
      });
      return;
    }

    // Find admin and include password
    const admin = await AdminUser.findOne({ email }).select('+password');

    if (!admin) {
      res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
      return;
    }

    // Check if admin is active
    if (!admin.isActive) {
      res.status(401).json({
        success: false,
        message: 'Admin account is inactive',
      });
      return;
    }

    // Check password
    const isPasswordValid = await admin.comparePassword(password);

    if (!isPasswordValid) {
      res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
      return;
    }

    // Generate token
    const token = admin.generateToken();

    // Return admin data (without password)
    res.status(200).json({
      success: true,
      token,
      admin: {
        _id: admin._id,
        email: admin.email,
        fullName: admin.fullName,
        role: admin.role,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
};

// Get current admin
export const getAdmin = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const admin = await AdminUser.findById(req.admin?.id).select('-password');

    if (!admin) {
      res.status(404).json({
        success: false,
        message: 'Admin not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      admin: {
        _id: admin._id,
        email: admin.email,
        fullName: admin.fullName,
        role: admin.role,
        isActive: admin.isActive,
        createdAt: admin.createdAt,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
};

// Logout (client-side token removal, but we can log it)
export const adminLogout = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    // In a stateless JWT system, logout is handled client-side
    // But we can log the logout event or add token to blacklist if needed
    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
};
