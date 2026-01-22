import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getEngagementMetrics,
  getConversionFunnel,
  getRevenueBreakdown,
  getDemographics,
  getRetentionRates,
} from '../controllers/adminAnalytics.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/engagement', getEngagementMetrics);
router.get('/conversion', getConversionFunnel);
router.get('/revenue-breakdown', getRevenueBreakdown);
router.get('/demographics', getDemographics);
router.get('/retention', getRetentionRates);

export default router;
