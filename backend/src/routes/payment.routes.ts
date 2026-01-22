import express from 'express';
import {
  createPaymentIntent,
  verifyPayment,
  getInvoice,
  validatePromoCode,
} from '../controllers/payment.controller';
import { auth } from '../middleware/auth.middleware';

const router = express.Router();

router.post('/create-intent', auth, createPaymentIntent);
router.post('/verify', auth, verifyPayment);
router.get('/invoice/:invoiceNumber', auth, getInvoice);
router.post('/validate-promo', validatePromoCode); // Public endpoint

export default router;
