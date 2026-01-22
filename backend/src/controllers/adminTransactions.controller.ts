import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { Transaction } from '../models/Transaction.model';
import mongoose from 'mongoose';

const User = mongoose.models.User || mongoose.model('User', new mongoose.Schema({}, { strict: false }));

// Get all transactions with filters
export const getTransactions = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const {
      startDate,
      endDate,
      status,
      paymentMethod,
      search,
      page = 1,
      limit = 20,
    } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    // Build query
    const query: any = {};

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) {
        query.createdAt.$gte = new Date(startDate as string);
      }
      if (endDate) {
        const end = new Date(endDate as string);
        end.setHours(23, 59, 59, 999);
        query.createdAt.$lte = end;
      }
    }

    if (status && status !== 'all') {
      query.status = status;
    }

    if (paymentMethod) {
      query.paymentMethod = paymentMethod;
    }

    // Search by invoice number or user
    if (search) {
      const users = await User.find({
        $or: [
          { fullName: { $regex: search, $options: 'i' } },
          { email: { $regex: search, $options: 'i' } },
        ],
      }).select('_id');

      const userIds = users.map((u) => u._id);

      query.$or = [
        { invoiceNumber: { $regex: search, $options: 'i' } },
        { userId: { $in: userIds } },
      ];
    }

    // Execute query
    const [transactions, total] = await Promise.all([
      Transaction.find(query)
        .populate('userId', 'fullName email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Transaction.countDocuments(query),
    ]);

    // Calculate summary
    const summary = await Transaction.aggregate([
      {
        $match: {
          ...query,
          status: 'completed',
        },
      },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$totalAmount' },
          totalTransactions: { $sum: 1 },
        },
      },
    ]);

    const summaryData = summary[0] || {
      totalRevenue: 0,
      totalTransactions: 0,
    };

    const averageTransactionValue =
      summaryData.totalTransactions > 0
        ? summaryData.totalRevenue / summaryData.totalTransactions
        : 0;

    // Format response
    const formattedTransactions = transactions.map((transaction: any) => ({
      ...transaction,
      user: transaction.userId
        ? {
            _id: transaction.userId._id,
            fullName: transaction.userId.fullName,
            email: transaction.userId.email,
          }
        : null,
    }));

    // Format transactions - convert amount from paise to rupees and ensure proper field names
    const finalTransactions = formattedTransactions.map((t: any) => ({
      ...t,
      amount: Math.round((t.totalAmount || t.amount || 0) / 100), // Convert paise to rupees
      type: t.type || 'boost',
      boostType: t.boostType || t.type || '-',
      paymentMethod: t.paymentMethod || '-',
    }));

    res.status(200).json({
      success: true,
      transactions: finalTransactions,
      total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch transactions',
    });
  }
};

// Get transaction by ID
export const getTransactionById = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const transaction = await Transaction.findById(id)
      .populate('userId', 'fullName email')
      .lean();

    if (!transaction) {
      res.status(404).json({
        success: false,
        message: 'Transaction not found',
      });
      return;
    }

    const formattedTransaction: any = {
      ...transaction,
      user: transaction.userId
        ? {
            _id: (transaction.userId as any)._id,
            fullName: (transaction.userId as any).fullName,
            email: (transaction.userId as any).email,
          }
        : null,
    };

    res.status(200).json({
      success: true,
      transaction: formattedTransaction,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch transaction',
    });
  }
};

// Refund transaction
export const refundTransaction = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const { reason, amount } = req.body;

    const transaction = await Transaction.findById(id);

    if (!transaction) {
      res.status(404).json({
        success: false,
        message: 'Transaction not found',
      });
      return;
    }

    if (transaction.status !== 'completed') {
      res.status(400).json({
        success: false,
        message: 'Only completed transactions can be refunded',
      });
      return;
    }

    const refundAmount = amount || transaction.totalAmount;

    // Update transaction
    transaction.status = 'refunded';
    transaction.refundedAt = new Date();
    transaction.refundAmount = refundAmount;
    transaction.refundReason = reason || 'Refunded by admin';

    await transaction.save();

    // TODO: Process actual refund through payment gateway (Stripe, etc.)

    res.status(200).json({
      success: true,
      message: 'Transaction refunded successfully',
      transaction,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to refund transaction',
    });
  }
};

// Export transactions
export const exportTransactions = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { startDate, endDate, status } = req.query;

    const query: any = {};

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) {
        query.createdAt.$gte = new Date(startDate as string);
      }
      if (endDate) {
        const end = new Date(endDate as string);
        end.setHours(23, 59, 59, 999);
        query.createdAt.$lte = end;
      }
    }

    if (status && status !== 'all') {
      query.status = status;
    }

    const transactions = await Transaction.find(query)
      .populate('userId', 'fullName email')
      .sort({ createdAt: -1 })
      .lean();

    // Convert to CSV format
    const csvHeader = 'Invoice Number,Date,User,Type,Amount,Status,Payment Method\n';
    const csvRows = transactions.map((t: any) => {
      const user = t.userId ? (t.userId as any).fullName || (t.userId as any).email : 'Unknown';
      const date = new Date(t.createdAt).toLocaleDateString();
      const amount = (t.totalAmount / 100).toFixed(2);
      return `${t.invoiceNumber},${date},${user},${t.boostType},${amount},${t.status},${t.paymentMethod}`;
    });

    const csv = csvHeader + csvRows.join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=transactions.csv');
    res.send(csv);
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to export transactions',
    });
  }
};
