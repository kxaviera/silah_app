import { Response } from 'express';
import { Conversation } from '../models/Conversation.model';
import { Message } from '../models/Message.model';
import { AuthRequest } from '../middleware/auth.middleware';

// Get conversations
export const getConversations = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user._id;

    const conversations = await Conversation.find({
      participants: userId,
    })
      .populate('participants', 'fullName profilePhoto')
      .populate('lastMessageBy', 'fullName')
      .sort({ lastMessageAt: -1 });

    // Format conversations
    const formattedConversations = conversations.map((conv) => {
      const otherParticipant = conv.participants.find(
        (p: any) => p._id.toString() !== userId.toString()
      );
      const unreadCount = (conv.unreadCount as Map<string, number>).get(userId.toString()) || 0;

      return {
        _id: conv._id,
        participant: otherParticipant,
        lastMessage: conv.lastMessage,
        lastMessageAt: conv.lastMessageAt,
        unreadCount,
      };
    });

    res.json({
      success: true,
      conversations: formattedConversations,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch conversations.',
    });
  }
};

// Get messages
export const getMessages = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { conversationId } = req.params;
    const userId = req.user._id;

    // Verify user is part of conversation
    const conversation = await Conversation.findById(conversationId);
    if (!conversation || !conversation.participants.includes(userId as any)) {
      res.status(403).json({
        success: false,
        message: 'Access denied.',
      });
      return;
    }

    const messages = await Message.find({ conversationId })
      .populate('senderId', 'fullName profilePhoto')
      .sort({ createdAt: 1 });

    // Mark messages as read
    await Message.updateMany(
      {
        conversationId,
        receiverId: userId,
        isRead: false,
      },
      {
        isRead: true,
        readAt: new Date(),
      }
    );

    // Update conversation unread count
    (conversation.unreadCount as Map<string, number>).set(userId.toString(), 0);
    await conversation.save();

    res.json({
      success: true,
      messages,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch messages.',
    });
  }
};

// Send message
export const sendMessage = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const senderId = req.user._id;
    const { receiverId, message, conversationId } = req.body;

    if (!receiverId || !message) {
      res.status(400).json({
        success: false,
        message: 'Receiver ID and message are required.',
      });
      return;
    }

    let convId = conversationId;

    // Find or create conversation
    if (!convId) {
      let conversation = await Conversation.findOne({
        participants: { $all: [senderId, receiverId] },
      });

      if (!conversation) {
        conversation = await Conversation.create({
          participants: [senderId, receiverId],
          unreadCount: new Map(),
        });
      }

      convId = conversation._id;
    }

    // Create message
    const newMessage = await Message.create({
      conversationId: convId,
      senderId,
      receiverId,
      message,
      messageType: 'text',
    });

    // Update conversation
    const conversation = await Conversation.findById(convId);
    if (conversation) {
      conversation.lastMessage = message;
      conversation.lastMessageAt = new Date();
      conversation.lastMessageBy = senderId;

      // Update unread count
      const currentUnread = (conversation.unreadCount as Map<string, number>).get(receiverId.toString()) || 0;
      (conversation.unreadCount as Map<string, number>).set(receiverId.toString(), currentUnread + 1);

      await conversation.save();
    }

    const populatedMessage = await Message.findById(newMessage._id)
      .populate('senderId', 'fullName profilePhoto');

    res.status(201).json({
      success: true,
      message: populatedMessage,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send message.',
    });
  }
};

// Mark message as read
export const markMessageAsRead = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { messageId } = req.params;
    const userId = req.user._id;

    const message = await Message.findById(messageId);
    if (!message) {
      res.status(404).json({
        success: false,
        message: 'Message not found.',
      });
      return;
    }

    if (message.receiverId.toString() !== userId.toString()) {
      res.status(403).json({
        success: false,
        message: 'Access denied.',
      });
      return;
    }

    message.isRead = true;
    message.readAt = new Date();
    await message.save();

    res.json({
      success: true,
      message: 'Message marked as read.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to mark message as read.',
    });
  }
};
