import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getTransactions,
  getTransactionById,
  refundTransaction,
  exportTransactions,
} from '../controllers/adminTransactions.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/', getTransactions);
router.get('/export', exportTransactions);
router.get('/:id', getTransactionById);
router.post('/:id/refund', refundTransaction);

export default router;
