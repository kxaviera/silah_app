import { Response } from 'express';
import { ContactRequest } from '../models/ContactRequest.model';
import { User } from '../models/User.model';
import { Notification } from '../models/Notification.model';
import { AuthRequest } from '../middleware/auth.middleware';
import { sendPushToUser } from '../services/fcm.service';

// Send contact request
export const sendRequest = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const fromUserId = req.user._id;
    // Support both `toUserId` and legacy `userId` from mobile app
    const { toUserId, userId, requestType } = req.body as {
      toUserId?: string;
      userId?: string;
      requestType?: string;
    };
    const targetUserId = toUserId || userId;

    if (!targetUserId || !requestType) {
      res.status(400).json({
        success: false,
        message: 'User ID and request type are required.',
      });
      return;
    }

    if (!['mobile', 'photos', 'both'].includes(requestType)) {
      res.status(400).json({
        success: false,
        message: 'Invalid request type.',
      });
      return;
    }

    // Check if current user is verified
    const currentUser = await User.findById(fromUserId);
    if (!currentUser) {
      res.status(404).json({
        success: false,
        message: 'User not found.',
      });
      return;
    }

    if (!currentUser.isVerified) {
      res.status(403).json({
        success: false,
        message: 'Your profile must be verified before you can send contact requests. Please wait for admin approval.',
      });
      return;
    }

    // Check if current user has active boost (only boosted members can send requests)
    const isBoosted = currentUser.boostStatus === 'active' && 
                      currentUser.boostExpiresAt && 
                      new Date(currentUser.boostExpiresAt) > new Date();
    
    if (!isBoosted) {
      res.status(403).json({
        success: false,
        message: 'Only boosted members can send contact requests. Please boost your profile to connect with others.',
      });
      return;
    }

    // Check if target user is verified (only verified users can receive requests)
    const targetUser = await User.findById(targetUserId);
    if (!targetUser || !targetUser.isVerified) {
      res.status(403).json({
        success: false,
        message: 'This profile is not verified yet.',
      });
      return;
    }

    // Check if request already exists
    const existingRequest = await ContactRequest.findOne({
      fromUserId,
      toUserId: targetUserId,
      status: 'pending',
    });

    if (existingRequest) {
      res.status(400).json({
        success: false,
        message: 'Request already sent.',
      });
      return;
    }

    // Create request
    const request = await ContactRequest.create({
      fromUserId,
      toUserId,
      requestType,
      status: 'pending',
    });

    // Create notification for recipient
    const fromUser = await User.findById(fromUserId).select('fullName');
    const notifMessage = `${fromUser?.fullName || 'Someone'} sent you a contact request.`;
    await Notification.create({
      userId: targetUserId,
      type: 'new_request',
      title: 'New Contact Request',
      message: notifMessage,
      relatedUserId: fromUserId,
      relatedRequestId: request._id,
    });
    sendPushToUser(targetUserId, {
      title: 'New Contact Request',
      body: notifMessage,
      data: { type: 'new_request', requestId: request._id.toString() },
    }).catch(() => {});

    res.status(201).json({
      success: true,
      message: 'Request sent successfully.',
      request,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send request.',
    });
  }
};

// Get received requests
export const getReceivedRequests = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    const requests = await ContactRequest.find({ toUserId: userId })
      .populate('fromUserId', 'fullName age city country profilePhoto')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      requests,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch requests.',
    });
  }
};

// Get sent requests
export const getSentRequests = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    const requests = await ContactRequest.find({ fromUserId: userId })
      .populate('toUserId', 'fullName age city country profilePhoto')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      requests,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch requests.',
    });
  }
};

// Accept request
export const acceptRequest = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { requestId } = req.params;
    const userId = req.user._id;

    const request = await ContactRequest.findOne({
      _id: requestId,
      toUserId: userId,
      status: 'pending',
    });

    if (!request) {
      res.status(404).json({
        success: false,
        message: 'Request not found.',
      });
      return;
    }

    request.status = 'accepted';
    await request.save();

    // Create notification for sender
    const toUser = await User.findById(userId).select('fullName');
    const notifMessage = `${toUser?.fullName || 'Someone'} accepted your contact request.`;
    await Notification.create({
      userId: request.fromUserId,
      type: 'request_accepted',
      title: 'Request Accepted',
      message: notifMessage,
      relatedUserId: userId,
      relatedRequestId: request._id,
    });
    sendPushToUser(request.fromUserId, {
      title: 'Request Accepted',
      body: notifMessage,
      data: { type: 'request_accepted', requestId: request._id.toString() },
    }).catch(() => {});

    res.json({
      success: true,
      message: 'Request accepted.',
      request,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to accept request.',
    });
  }
};

// Reject request
export const rejectRequest = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { requestId } = req.params;
    const userId = req.user._id;

    const request = await ContactRequest.findOne({
      _id: requestId,
      toUserId: userId,
      status: 'pending',
    });

    if (!request) {
      res.status(404).json({
        success: false,
        message: 'Request not found.',
      });
      return;
    }

    request.status = 'rejected';
    await request.save();

    // Create notification for sender
    const toUser = await User.findById(userId).select('fullName');
    const notifMessage = `${toUser?.fullName || 'Someone'} rejected your contact request.`;
    await Notification.create({
      userId: request.fromUserId,
      type: 'request_rejected',
      title: 'Request Rejected',
      message: notifMessage,
      relatedUserId: userId,
      relatedRequestId: request._id,
    });
    sendPushToUser(request.fromUserId, {
      title: 'Request Rejected',
      body: notifMessage,
      data: { type: 'request_rejected', requestId: request._id.toString() },
    }).catch(() => {});

    res.json({
      success: true,
      message: 'Request rejected.',
      request,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to reject request.',
    });
  }
};

// Check request status
export const checkRequestStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { userId: otherUserId } = req.params;
    const currentUserId = req.user._id;

    // Check if there's an accepted contact request between users (for sharing mobile/photos)
    const request = await ContactRequest.findOne({
      $or: [
        { fromUserId: currentUserId, toUserId: otherUserId },
        { fromUserId: otherUserId, toUserId: currentUserId },
      ],
      status: 'accepted',
    });

    // Chat permission: allow boosted & verified users to chat even if contact
    // details (mobile/photos) have not been shared yet.
    const currentUser = await User.findById(currentUserId).select(
      'isVerified boostStatus boostExpiresAt'
    );
    let canChat = false;
    if (currentUser) {
      const isBoostActive =
        currentUser.boostStatus === 'active' &&
        currentUser.boostExpiresAt &&
        new Date(currentUser.boostExpiresAt) > new Date();
      canChat = currentUser.isVerified && !!isBoostActive;
    }

    res.json({
      success: true,
      // Legacy field: true only when contact request has been accepted
      approved: !!request,
      // New explicit flag: whether user is allowed to chat
      canChat,
      requestStatus: request ? 'accepted' : 'none',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to check request status.',
    });
  }
};
