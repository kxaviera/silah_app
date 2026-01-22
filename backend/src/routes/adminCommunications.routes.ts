import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  sendEmail,
  sendSMS,
  bulkEmail,
  getTemplates,
  createTemplate,
  updateTemplate,
  getHistory,
} from '../controllers/adminCommunications.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.post('/email', sendEmail);
router.post('/sms', sendSMS);
router.post('/bulk-email', bulkEmail);
router.get('/templates', getTemplates);
router.post('/templates', createTemplate);
router.put('/templates/:id', updateTemplate);
router.get('/history', getHistory);

export default router;
