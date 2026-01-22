import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  bulkBlockUsers,
  bulkUnblockUsers,
  bulkVerifyUsers,
  bulkDeleteUsers,
  bulkExportUsers,
} from '../controllers/adminBulkOperations.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.post('/users/block', bulkBlockUsers);
router.post('/users/unblock', bulkUnblockUsers);
router.post('/users/verify', bulkVerifyUsers);
router.post('/users/delete', bulkDeleteUsers);
router.post('/users/export', bulkExportUsers);

export default router;
