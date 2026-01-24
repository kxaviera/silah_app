import express from 'express';
import { blockUser, unblockUser, getBlockStatus } from '../controllers/block.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

router.use(auth);

router.get('/status/:targetUserId', getBlockStatus);
router.post('/:targetUserId', blockUser);
router.post('/:targetUserId/unblock', unblockUser);

export default router;
