import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { ActivityLog } from '../models/ActivityLog.model';
import mongoose from 'mongoose';

const User = mongoose.models.User || mongoose.model('User', new mongoose.Schema({}, { strict: false }));

// Bulk block users
export const bulkBlockUsers = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { userIds, reason } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({
        success: false,
        message: 'User IDs array is required',
      });
      return;
    }

    const result = await User.updateMany(
      { _id: { $in: userIds } },
      {
        isBlocked: true,
        blockedAt: new Date(),
        blockedReason: reason || 'Bulk blocked by admin',
        blockedBy: req.admin?.id,
      }
    );

    // Log activity
    await ActivityLog.create({
      adminId: req.admin?.id,
      action: 'users.bulk_blocked',
      entityType: 'user',
      description: `${req.admin?.email} bulk blocked ${result.modifiedCount} users`,
      metadata: {
        userIds,
        reason,
        count: result.modifiedCount,
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    res.status(200).json({
      success: true,
      message: `${result.modifiedCount} users blocked successfully`,
      count: result.modifiedCount,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to bulk block users',
    });
  }
};

// Bulk unblock users
export const bulkUnblockUsers = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { userIds } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({
        success: false,
        message: 'User IDs array is required',
      });
      return;
    }

    const result = await User.updateMany(
      { _id: { $in: userIds } },
      {
        isBlocked: false,
        $unset: { blockedAt: 1, blockedReason: 1, blockedBy: 1 },
      }
    );

    // Log activity
    await ActivityLog.create({
      adminId: req.admin?.id,
      action: 'users.bulk_unblocked',
      entityType: 'user',
      description: `${req.admin?.email} bulk unblocked ${result.modifiedCount} users`,
      metadata: {
        userIds,
        count: result.modifiedCount,
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    res.status(200).json({
      success: true,
      message: `${result.modifiedCount} users unblocked successfully`,
      count: result.modifiedCount,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to bulk unblock users',
    });
  }
};

// Bulk verify users
export const bulkVerifyUsers = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { userIds } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({
        success: false,
        message: 'User IDs array is required',
      });
      return;
    }

    const result = await User.updateMany(
      { _id: { $in: userIds } },
      {
        emailVerified: true,
        verifiedAt: new Date(),
      }
    );

    // Log activity
    await ActivityLog.create({
      adminId: req.admin?.id,
      action: 'users.bulk_verified',
      entityType: 'user',
      description: `${req.admin?.email} bulk verified ${result.modifiedCount} users`,
      metadata: {
        userIds,
        count: result.modifiedCount,
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    res.status(200).json({
      success: true,
      message: `${result.modifiedCount} users verified successfully`,
      count: result.modifiedCount,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to bulk verify users',
    });
  }
};

// Bulk delete users
export const bulkDeleteUsers = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { userIds } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({
        success: false,
        message: 'User IDs array is required',
      });
      return;
    }

    const result = await User.deleteMany({ _id: { $in: userIds } });

    // Log activity
    await ActivityLog.create({
      adminId: req.admin?.id,
      action: 'users.bulk_deleted',
      entityType: 'user',
      description: `${req.admin?.email} bulk deleted ${result.deletedCount} users`,
      metadata: {
        userIds,
        count: result.deletedCount,
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'],
    });

    res.status(200).json({
      success: true,
      message: `${result.deletedCount} users deleted successfully`,
      count: result.deletedCount,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to bulk delete users',
    });
  }
};

// Bulk export users
export const bulkExportUsers = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { userIds, format = 'csv' } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({
        success: false,
        message: 'User IDs array is required',
      });
      return;
    }

    const users = await User.find({ _id: { $in: userIds } })
      .select('-password')
      .lean();

    if (format === 'csv') {
      // CSV format
      const csvHeader = 'ID,Name,Email,Role,Status,Verified,City,Country,Religion,Created At\n';
      const csvRows = users.map((user: any) => {
        return `${user._id},${user.fullName || ''},${user.email || ''},${user.role || ''},${user.isBlocked ? 'Blocked' : 'Active'},${user.emailVerified ? 'Yes' : 'No'},${user.city || ''},${user.country || ''},${user.religion || ''},${new Date(user.createdAt).toLocaleDateString()}`;
      });

      const csv = csvHeader + csvRows.join('\n');

      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', 'attachment; filename=users-export.csv');
      res.send(csv);
    } else {
      // JSON format
      res.status(200).json({
        success: true,
        users,
        count: users.length,
      });
    }
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to export users',
    });
  }
};
