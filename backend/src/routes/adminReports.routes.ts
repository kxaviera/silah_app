import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getReports,
  getReportById,
  reviewReport,
  resolveReport,
  deleteReport,
} from '../controllers/adminReports.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/', getReports);
router.get('/:id', getReportById);
router.put('/:id/review', reviewReport);
router.put('/:id/resolve', resolveReport);
router.delete('/:id', deleteReport);

export default router;
