import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getSystemHealth,
  getSystemMetrics,
  getRecentErrors,
  getServiceStatus,
} from '../controllers/adminSystemHealth.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/health', getSystemHealth);
router.get('/metrics', getSystemMetrics);
router.get('/errors', getRecentErrors);
router.get('/status', getServiceStatus);

export default router;
