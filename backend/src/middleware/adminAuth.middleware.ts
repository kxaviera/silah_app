import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AdminUser } from '../models/AdminUser.model';

export interface AdminAuthRequest extends Request {
  admin?: {
    id: string;
    email: string;
    role: string;
  };
}

export const adminAuth = async (
  req: AdminAuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({
        success: false,
        message: 'No token provided, authorization denied',
      });
      return;
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify token
    const decoded = jwt.verify(
      token,
      process.env.ADMIN_JWT_SECRET || 'admin_secret_key'
    ) as {
      id: string;
      email: string;
      role: string;
    };

    // Check if admin exists and is active
    const admin = await AdminUser.findById(decoded.id).select('-password');
    
    if (!admin || !admin.isActive) {
      res.status(401).json({
        success: false,
        message: 'Admin not found or inactive',
      });
      return;
    }

    // Attach admin to request
    req.admin = {
      id: admin._id.toString(),
      email: admin.email,
      role: admin.role,
    };

    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Token is not valid',
    });
  }
};
