import express from 'express';
import {
  register,
  login,
  googleSignIn,
  getMe,
  forgotPassword,
  resetPassword,
  logout,
  deleteAccount,
} from '../controllers/auth.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

// Public routes
router.post('/register', register);
router.post('/login', login);
router.post('/google', googleSignIn);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

// Protected routes
router.get('/me', auth, getMe);
router.post('/logout', auth, logout);
router.post('/delete-account', auth, deleteAccount);

export default router;
