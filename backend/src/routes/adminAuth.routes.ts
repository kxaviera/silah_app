import express from 'express';
import { adminLogin, getAdmin, adminLogout } from '../controllers/adminAuth.controller';
import { adminAuth } from '../middleware/adminAuth.middleware';

const router = express.Router();

// Public routes
router.post('/login', adminLogin);

// Protected routes
router.get('/me', adminAuth, getAdmin);
router.post('/logout', adminAuth, adminLogout);

export default router;
