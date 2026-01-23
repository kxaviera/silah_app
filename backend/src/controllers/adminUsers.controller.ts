import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { User } from '../models/User.model';
import { Notification } from '../models/Notification.model';

// Get all users with filters
export const getUsers = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const {
      search,
      status, // Frontend uses 'status' instead of 'filter'
      filter, // Keep for backward compatibility
      sort, // Frontend uses 'sort' instead of 'sortBy'
      sortBy = 'date',
      page = 1,
      limit = 20,
    } = req.query;
    
    const actualFilter = status || filter;
    const actualSort = sort || sortBy;

    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    // Build query
    const query: any = {};

    // Search by name or email
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    // Filter
    if (actualFilter === 'active') {
      query.isBlocked = false;
    } else if (actualFilter === 'blocked') {
      query.isBlocked = true;
    } else if (actualFilter === 'verified') {
      query.isVerified = true; // Use isVerified instead of emailVerified
    } else if (actualFilter === 'unverified') {
      query.isVerified = false;
    } else if (actualFilter === 'boosted') {
      query.boostStatus = 'active';
      query.boostExpiresAt = { $gt: new Date() };
    }

    // Sort
    let sortObj: any = { createdAt: -1 }; // Default: newest first
    if (actualSort === 'name') {
      sortObj = { fullName: 1 };
    } else if (actualSort === 'boost') {
      sortObj = { boostExpiresAt: -1 };
    }

    // Execute query
    const [users, total] = await Promise.all([
      User.find(query)
        .select('-password')
        .sort(sortObj)
        .skip(skip)
        .limit(limitNum)
        .lean(),
      User.countDocuments(query),
    ]);

    res.status(200).json({
      success: true,
      users,
      total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch users',
    });
  }
};

// Get user by ID
export const getUserById = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const user = await User.findById(id).select('-password').lean();

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      user,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch user',
    });
  }
};

// Block user
export const blockUser = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const user = await User.findByIdAndUpdate(
      id,
      {
        isBlocked: true,
        blockedAt: new Date(),
        blockedReason: reason || 'Blocked by admin',
        blockedBy: req.admin?.id,
      },
      { new: true }
    ).select('-password');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    // Send notification to user
    await Notification.create({
      userId: user._id,
      type: 'profile_blocked',
      title: 'Account Blocked',
      message: reason || 'Your account has been blocked by admin. Please contact support for more information.',
      isRead: false,
    });

    res.status(200).json({
      success: true,
      message: 'User blocked successfully',
      user,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to block user',
    });
  }
};

// Unblock user
export const unblockUser = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const user = await User.findByIdAndUpdate(
      id,
      {
        isBlocked: false,
        $unset: { blockedAt: 1, blockedReason: 1, blockedBy: 1 },
      },
      { new: true }
    ).select('-password');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'User unblocked successfully',
      user,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to unblock user',
    });
  }
};

// Verify user (with notes)
export const verifyUser = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const { notes } = req.body; // Optional verification notes

    const user = await User.findByIdAndUpdate(
      id,
      {
        isVerified: true,
        verifiedAt: new Date(),
        verifiedBy: req.admin?.id,
        verificationNotes: notes,
      },
      { new: true }
    ).select('-password');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    // Send notification to user
    await Notification.create({
      userId: user._id,
      type: 'profile_verified',
      title: 'Profile Verified',
      message: notes ? `Your profile has been verified! ${notes}` : 'Congratulations! Your profile has been verified by admin. You can now boost your profile and send contact requests.',
      isRead: false,
    });

    res.status(200).json({
      success: true,
      message: 'User verified successfully',
      user,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to verify user',
    });
  }
};

// Reject user verification
export const rejectUser = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const { notes } = req.body; // Required rejection reason

    if (!notes || notes.trim().length === 0) {
      res.status(400).json({
        success: false,
        message: 'Rejection reason is required',
      });
      return;
    }

    const user = await User.findByIdAndUpdate(
      id,
      {
        isVerified: false,
        verifiedAt: undefined,
        verifiedBy: undefined,
        verificationNotes: notes,
      },
      { new: true }
    ).select('-password');

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    // Send notification to user
    await Notification.create({
      userId: user._id,
      type: 'profile_rejected',
      title: 'Profile Verification Rejected',
      message: `Your profile verification has been rejected. Reason: ${notes}. Please update your profile and try again.`,
      isRead: false,
    });

    res.status(200).json({
      success: true,
      message: 'User verification rejected',
      user,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to reject user',
    });
  }
};

// Delete user
export const deleteUser = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const user = await User.findByIdAndDelete(id);

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to delete user',
    });
  }
};
