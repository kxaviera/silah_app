import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getActivityLogs,
  getUserActivity,
  exportActivityLogs,
} from '../controllers/adminActivityLogs.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/', getActivityLogs);
router.get('/export', exportActivityLogs);
router.get('/user/:userId', getUserActivity);

export default router;
