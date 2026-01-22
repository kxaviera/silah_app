import express from 'express';
import { getAppSettings } from '../controllers/settings.controller';

const router = express.Router();

// Public route - no auth required
router.get('/', getAppSettings);

export default router;
