import express from 'express';
import {
  completeProfile,
  uploadPhoto,
  searchProfiles,
  getProfile,
  getAnalytics,
  upload,
} from '../controllers/profile.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

// All routes require authentication
router.use(auth);

router.put('/complete', completeProfile);
router.post('/photo', upload.single('photo'), uploadPhoto);
router.get('/search', searchProfiles);
router.get('/analytics', getAnalytics);
router.get('/:userId', getProfile);

export default router;
