import express from 'express';
import { activateBoost, getBoostStatus } from '../controllers/boost.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

router.use(auth);

router.post('/activate', activateBoost);
router.get('/status', getBoostStatus);

export default router;
