import express from 'express';
import { adminAuth } from '../middleware/adminAuth.middleware';
import {
  getUsers,
  getUserById,
  blockUser,
  unblockUser,
  verifyUser,
  rejectUser,
  deleteUser,
  updateUserRole,
} from '../controllers/adminUsers.controller';

const router = express.Router();

// All routes require admin authentication
router.use(adminAuth);

router.get('/', getUsers);
router.get('/:id', getUserById);
router.post('/:id/block', blockUser);
router.post('/:id/unblock', unblockUser);
router.post('/:id/verify', verifyUser);
router.post('/:id/reject', rejectUser);
router.put('/:id/role', updateUserRole);
router.delete('/:id', deleteUser);

export default router;
