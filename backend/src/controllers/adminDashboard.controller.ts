import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import mongoose from 'mongoose';

// Import models (you'll need to create these or import from existing files)
// For now, using mongoose directly - update when you have actual models
const User = mongoose.models.User || mongoose.model('User', new mongoose.Schema({}, { strict: false }));
const Transaction = mongoose.models.Transaction || mongoose.model('Transaction', new mongoose.Schema({}, { strict: false }));
const Report = mongoose.models.Report || mongoose.model('Report', new mongoose.Schema({}, { strict: false }));
const Conversation = mongoose.models.Conversation || mongoose.model('Conversation', new mongoose.Schema({}, { strict: false }));
const Request = mongoose.models.Request || mongoose.model('Request', new mongoose.Schema({}, { strict: false }));

// Get dashboard statistics
export const getDashboardStats = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      totalUsers,
      activeBoosts,
      pendingReports,
      todayRevenue,
      totalRevenue,
      newUsersToday,
      activeConversations,
      totalRequests,
      usersYesterday,
    ] = await Promise.all([
      // Total users
      User.countDocuments(),
      
      // Active boosts (users with active boost)
      User.countDocuments({
        boostStatus: 'active',
        boostExpiresAt: { $gt: new Date() },
      }),
      
      // Pending reports
      Report.countDocuments({ status: 'pending' }),
      
      // Today's revenue (convert from paise to rupees)
      Transaction.aggregate([
        {
          $match: {
            status: 'completed',
            createdAt: { $gte: today },
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$totalAmount' },
          },
        },
      ]).then((result) => Math.round((result[0]?.total || 0) / 100)),
      
      // Total revenue (convert from paise to rupees)
      Transaction.aggregate([
        {
          $match: { status: 'completed' },
        },
        {
          $group: {
            _id: null,
            total: { $sum: '$totalAmount' },
          },
        },
      ]).then((result) => Math.round((result[0]?.total || 0) / 100)),
      
      // New users today
      User.countDocuments({ createdAt: { $gte: today } }),
      
      // Active conversations (conversations with messages in last 24 hours)
      Conversation.countDocuments({
        updatedAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
      }),
      
      // Total requests
      Request.countDocuments(),
      
      // Users yesterday (for growth calculation)
      User.countDocuments({
        createdAt: {
          $gte: new Date(today.getTime() - 24 * 60 * 60 * 1000),
          $lt: today,
        },
      }),
    ]);

    // Calculate user growth percentage
    const userGrowth = usersYesterday > 0
      ? ((newUsersToday - usersYesterday) / usersYesterday) * 100
      : newUsersToday > 0 ? 100 : 0;

    res.status(200).json({
      success: true,
      stats: {
        totalUsers,
        activeBoosts,
        pendingReports,
        todayRevenue: todayRevenue || 0,
        totalRevenue: totalRevenue || 0,
        newUsersToday,
        activeConversations,
        totalRequests,
        userGrowth: Math.round(userGrowth * 10) / 10, // Round to 1 decimal
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch dashboard stats',
    });
  }
};

// Get revenue chart data
export const getRevenueChart = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const days = parseInt(req.query.days as string) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const revenueData = await Transaction.aggregate([
      {
        $match: {
          status: 'completed',
          createdAt: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          revenue: { $sum: { $divide: ['$totalAmount', 100] } }, // Convert paise to rupees
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);

    const formattedData = revenueData.map((item) => ({
      date: item._id,
      value: item.revenue,
    }));

    res.status(200).json({
      success: true,
      data: formattedData,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch revenue chart data',
    });
  }
};

// Get user growth chart data
export const getUserGrowthChart = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const days = parseInt(req.query.days as string) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const growthData = await User.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          users: { $sum: 1 },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);

    // Calculate cumulative user count
    let cumulative = 0;
    const formattedData = growthData.map((item) => {
      cumulative += item.users;
      return {
        date: item._id,
        value: cumulative,
      };
    });

    res.status(200).json({
      success: true,
      data: formattedData,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch user growth data',
    });
  }
};
