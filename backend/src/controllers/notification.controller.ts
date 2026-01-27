import { Response } from 'express';
import { Notification } from '../models/Notification.model';
import { FCMToken } from '../models/FCMToken.model';
import { NotificationPreference } from '../models/NotificationPreference.model';
import { AuthRequest } from '../middleware/auth.middleware';

// Register FCM token
export const registerToken = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    // Support both `token` and `fcmToken` from clients
    const { token, fcmToken, deviceType } = req.body as {
      token?: string;
      fcmToken?: string;
      deviceType?: string;
    };
    const resolvedToken = token || fcmToken;

    if (!resolvedToken) {
      res.status(400).json({
        success: false,
        message: 'FCM token is required.',
      });
      return;
    }

    // Remove old token if exists
    await FCMToken.findOneAndDelete({ token: resolvedToken });

    // Create or update token
    await FCMToken.findOneAndUpdate(
      { userId, token: resolvedToken },
      { userId, token: resolvedToken, deviceType },
      { upsert: true, new: true }
    );

    res.json({
      success: true,
      message: 'Token registered successfully.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to register token.',
    });
  }
};

// Get notifications
export const getNotifications = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20 } = req.query;

    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const notifications = await Notification.find({ userId })
      .populate('relatedUserId', 'fullName profilePhoto')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit as string));

    const total = await Notification.countDocuments({ userId });

    res.json({
      success: true,
      notifications,
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total,
        pages: Math.ceil(total / parseInt(limit as string)),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch notifications.',
    });
  }
};

// Get unread counts
export const getUnreadCounts = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    const unreadNotifications = await Notification.countDocuments({
      userId,
      isRead: false,
    });

    // Get unread messages count
    const { Conversation } = await import('../models/Conversation.model');
    const conversations = await Conversation.find({ participants: userId });
    let unreadMessages = 0;
    conversations.forEach((conv) => {
      unreadMessages += conv.unreadCount.get(userId.toString()) || 0;
    });

    // Get unread requests count
    const { ContactRequest } = await import('../models/ContactRequest.model');
    const unreadRequests = await ContactRequest.countDocuments({
      toUserId: userId,
      status: 'pending',
      isRead: false,
    });

    res.json({
      success: true,
      counts: {
        notifications: unreadNotifications,
        messages: unreadMessages,
        requests: unreadRequests,
        matches: 0, // Can be implemented later
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch unread counts.',
    });
  }
};

// Mark notification as read
export const markAsRead = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOne({
      _id: notificationId,
      userId,
    });

    if (!notification) {
      res.status(404).json({
        success: false,
        message: 'Notification not found.',
      });
      return;
    }

    notification.isRead = true;
    notification.readAt = new Date();
    await notification.save();

    res.json({
      success: true,
      message: 'Notification marked as read.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to mark notification as read.',
    });
  }
};

// Mark all as read
export const markAllAsRead = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    await Notification.updateMany(
      { userId, isRead: false },
      { isRead: true, readAt: new Date() }
    );

    res.json({
      success: true,
      message: 'All notifications marked as read.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to mark all as read.',
    });
  }
};

// Delete notification
export const deleteNotification = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOneAndDelete({
      _id: notificationId,
      userId,
    });

    if (!notification) {
      res.status(404).json({
        success: false,
        message: 'Notification not found.',
      });
      return;
    }

    res.json({
      success: true,
      message: 'Notification deleted.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to delete notification.',
    });
  }
};

// Get notification preferences
export const getPreferences = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    let preferences = await NotificationPreference.findOne({ userId });

    if (!preferences) {
      // Create default preferences
      preferences = await NotificationPreference.create({ userId });
    }

    res.json({
      success: true,
      preferences,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch preferences.',
    });
  }
};

// Update notification preferences
export const updatePreferences = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const updateData = req.body;

    let preferences = await NotificationPreference.findOne({ userId });

    if (!preferences) {
      preferences = await NotificationPreference.create({ userId, ...updateData });
    } else {
      Object.assign(preferences, updateData);
      await preferences.save();
    }

    res.json({
      success: true,
      message: 'Preferences updated.',
      preferences,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update preferences.',
    });
  }
};
