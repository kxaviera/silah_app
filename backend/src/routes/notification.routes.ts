import express from 'express';
import {
  registerToken,
  getNotifications,
  getUnreadCounts,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getPreferences,
  updatePreferences,
} from '../controllers/notification.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

router.use(auth);

router.post('/register-token', registerToken);
router.get('/', getNotifications);
router.get('/unread-count', getUnreadCounts);
router.put('/:notificationId/read', markAsRead);
router.put('/read-all', markAllAsRead);
router.delete('/:notificationId', deleteNotification);
router.get('/preferences', getPreferences);
router.put('/preferences', updatePreferences);

export default router;
