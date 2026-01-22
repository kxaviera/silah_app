import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getSettings,
  updatePricing,
  updatePayment,
  updateCompany,
} from '../controllers/adminSettings.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/', getSettings);
router.put('/pricing', updatePricing);
router.put('/payment', updatePayment);
router.put('/company', updateCompany);

export default router;
