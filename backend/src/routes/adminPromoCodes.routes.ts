import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getPromoCodes,
  getPromoCodeById,
  createPromoCode,
  updatePromoCode,
  deletePromoCode,
  getPromoCodeUsage,
} from '../controllers/adminPromoCodes.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/', getPromoCodes);
router.get('/:id', getPromoCodeById);
router.get('/:id/usage', getPromoCodeUsage);
router.post('/', createPromoCode);
router.put('/:id', updatePromoCode);
router.delete('/:id', deletePromoCode);

export default router;
