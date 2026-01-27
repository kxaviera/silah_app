import express from 'express';
import {
  getConversations,
  getMessages,
  sendMessage,
  markMessageAsRead,
} from '../controllers/message.controller';
import { auth } from '../middleware/auth.middleware';
import { uploadMessageMedia } from '../middleware/uploadMessage.middleware';

const router = express.Router();

router.use(auth);

router.get('/conversations', getConversations);
router.get('/:conversationId', getMessages);

// Support optional image upload for messages.
// If a file is uploaded as "image", we set `req.body.message` to the file URL
// and `req.body.messageType` to "image" before hitting the controller.
router.post(
  '/',
  (req, res, next) => {
    next();
  },
  uploadMessageMedia.single('image'),
  (req, res, next) => {
    if (req.file) {
      // Express static serves /uploads from backend root
      (req as any).body.message = `/uploads/chat-media/${req.file.filename}`;
      (req as any).body.messageType = 'image';
    }
    next();
  },
  sendMessage
);

router.put('/:messageId/read', markMessageAsRead);

export default router;
