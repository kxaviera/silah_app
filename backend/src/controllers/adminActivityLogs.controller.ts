import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { ActivityLog } from '../models/ActivityLog.model';

// Get activity logs
export const getActivityLogs = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const {
      adminId,
      userId,
      action,
      entityType,
      startDate,
      endDate,
      page = 1,
      limit = 50,
    } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    // Build query
    const query: any = {};

    if (adminId) {
      query.adminId = adminId;
    }
    if (userId) {
      query.userId = userId;
    }
    if (action) {
      query.action = action;
    }
    if (entityType) {
      query.entityType = entityType;
    }

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) {
        query.createdAt.$gte = new Date(startDate as string);
      }
      if (endDate) {
        const end = new Date(endDate as string);
        end.setHours(23, 59, 59, 999);
        query.createdAt.$lte = end;
      }
    }

    // Execute query
    const [logs, total] = await Promise.all([
      ActivityLog.find(query)
        .populate('adminId', 'email fullName')
        .populate('userId', 'fullName email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      ActivityLog.countDocuments(query),
    ]);

    res.status(200).json({
      success: true,
      logs,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        pages: Math.ceil(total / limitNum),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch activity logs',
    });
  }
};

// Get user activity
export const getUserActivity = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 50 } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    const [logs, total] = await Promise.all([
      ActivityLog.find({ userId })
        .populate('adminId', 'email fullName')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      ActivityLog.countDocuments({ userId }),
    ]);

    res.status(200).json({
      success: true,
      logs,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        pages: Math.ceil(total / limitNum),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch user activity',
    });
  }
};

// Export activity logs
export const exportActivityLogs = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { startDate, endDate, action, entityType } = req.query;

    const query: any = {};

    if (action) {
      query.action = action;
    }
    if (entityType) {
      query.entityType = entityType;
    }

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) {
        query.createdAt.$gte = new Date(startDate as string);
      }
      if (endDate) {
        const end = new Date(endDate as string);
        end.setHours(23, 59, 59, 999);
        query.createdAt.$lte = end;
      }
    }

    const logs = await ActivityLog.find(query)
      .populate('adminId', 'email fullName')
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 })
      .lean();

    // Convert to CSV
    const csvHeader = 'Date,Admin,Action,Entity Type,Entity ID,Description,IP Address\n';
    const csvRows = logs.map((log: any) => {
      const date = new Date(log.createdAt).toLocaleString();
      const admin = log.adminId ? (log.adminId as any).email : 'System';
      const userId = log.userId ? (log.userId as any).fullName : '';
      return `${date},${admin},${log.action},${log.entityType},${log.entityId || ''},${log.description},${log.ipAddress || ''}`;
    });

    const csv = csvHeader + csvRows.join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=activity-logs.csv');
    res.send(csv);
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to export activity logs',
    });
  }
};
