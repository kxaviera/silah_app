import express from 'express';
import {
  getConversations,
  getMessages,
  sendMessage,
  markMessageAsRead,
} from '../controllers/message.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

router.use(auth);

router.get('/conversations', getConversations);
router.get('/:conversationId', getMessages);
router.post('/', sendMessage);
router.put('/:messageId/read', markMessageAsRead);

export default router;
