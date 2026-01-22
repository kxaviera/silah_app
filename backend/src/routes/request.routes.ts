import express from 'express';
import {
  sendRequest,
  getReceivedRequests,
  getSentRequests,
  acceptRequest,
  rejectRequest,
  checkRequestStatus,
} from '../controllers/request.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

router.use(auth);

router.post('/', sendRequest);
router.get('/received', getReceivedRequests);
router.get('/sent', getSentRequests);
router.post('/:requestId/accept', acceptRequest);
router.post('/:requestId/reject', rejectRequest);
router.get('/status/:userId', checkRequestStatus);

export default router;
