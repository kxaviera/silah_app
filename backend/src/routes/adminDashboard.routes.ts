import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getDashboardStats,
  getRevenueChart,
  getUserGrowthChart,
} from '../controllers/adminDashboard.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/stats', getDashboardStats);
router.get('/revenue-chart', getRevenueChart);
router.get('/user-growth', getUserGrowthChart);

export default router;
