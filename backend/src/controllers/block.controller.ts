import { Response } from 'express';
import { User } from '../models/User.model';
import { AuthRequest } from '../middleware/auth.middleware';
import mongoose from 'mongoose';

// Block user (chat)
export const blockUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const { targetUserId } = req.params;

    if (!targetUserId) {
      res.status(400).json({
        success: false,
        message: 'User ID is required.',
      });
      return;
    }

    if (targetUserId === userId.toString()) {
      res.status(400).json({
        success: false,
        message: 'You cannot block yourself.',
      });
      return;
    }

    const targetId = new mongoose.Types.ObjectId(targetUserId);
    const user = await User.findById(userId);

    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    const blocked = (user as any).blockedUsers || [];
    if (blocked.some((id: mongoose.Types.ObjectId) => id.toString() === targetUserId)) {
      res.status(400).json({
        success: false,
        message: 'User is already blocked.',
      });
      return;
    }

    await User.findByIdAndUpdate(userId, {
      $addToSet: { blockedUsers: targetId },
    });

    res.json({
      success: true,
      message: 'User blocked. You will not receive messages from them.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to block user.',
    });
  }
};

// Unblock user (chat)
export const unblockUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const { targetUserId } = req.params;

    if (!targetUserId) {
      res.status(400).json({
        success: false,
        message: 'User ID is required.',
      });
      return;
    }

    const targetId = new mongoose.Types.ObjectId(targetUserId);
    await User.findByIdAndUpdate(userId, {
      $pull: { blockedUsers: targetId },
    });

    res.json({
      success: true,
      message: 'User unblocked. You can chat again.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to unblock user.',
    });
  }
};

// Get block status (iBlockedThem, theyBlockedMe)
export const getBlockStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;
    const { targetUserId } = req.params;

    if (!targetUserId) {
      res.status(400).json({
        success: false,
        message: 'User ID is required.',
      });
      return;
    }

    const [me, them] = await Promise.all([
      User.findById(userId).select('blockedUsers').lean(),
      User.findById(targetUserId).select('blockedUsers').lean(),
    ]);

    const myBlocked = (me as any)?.blockedUsers || [];
    const theirBlocked = (them as any)?.blockedUsers || [];
    const targetId = targetUserId.toString();

    const iBlockedThem = myBlocked.some((id: any) => id?.toString() === targetId);
    const theyBlockedMe = theirBlocked.some((id: any) => id?.toString() === userId.toString());

    res.json({
      success: true,
      iBlockedThem,
      theyBlockedMe,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to get block status.',
    });
  }
};
