import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import mongoose from 'mongoose';

const User = mongoose.models.User || mongoose.model('User', new mongoose.Schema({}, { strict: false }));
const Transaction = mongoose.models.Transaction || mongoose.model('Transaction', new mongoose.Schema({}, { strict: false }));
const Request = mongoose.models.Request || mongoose.model('Request', new mongoose.Schema({}, { strict: false }));
const Conversation = mongoose.models.Conversation || mongoose.model('Conversation', new mongoose.Schema({}, { strict: false }));

// Get engagement metrics
export const getEngagementMetrics = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { days = 30 } = req.query;
    const daysNum = parseInt(days as string);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysNum);

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const lastWeek = new Date(today);
    lastWeek.setDate(lastWeek.getDate() - 7);
    const lastMonth = new Date(today);
    lastMonth.setMonth(lastMonth.getMonth() - 1);

    const [
      totalUsers,
      dailyActiveUsers,
      weeklyActiveUsers,
      monthlyActiveUsers,
      newUsersToday,
      newUsersThisWeek,
      newUsersThisMonth,
      activeBoosts,
      totalRequests,
      totalConversations,
    ] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ lastActiveAt: { $gte: today } }),
      User.countDocuments({ lastActiveAt: { $gte: lastWeek } }),
      User.countDocuments({ lastActiveAt: { $gte: lastMonth } }),
      User.countDocuments({ createdAt: { $gte: today } }),
      User.countDocuments({ createdAt: { $gte: lastWeek } }),
      User.countDocuments({ createdAt: { $gte: lastMonth } }),
      User.countDocuments({
        boostStatus: 'active',
        boostExpiresAt: { $gt: now },
      }),
      Request.countDocuments(),
      Conversation.countDocuments(),
    ]);

    // Calculate retention (users active in last 7 days who were active 30 days ago)
    const retentionUsers = await User.countDocuments({
      lastActiveAt: { $gte: lastWeek, $lte: lastMonth },
    });

    const retentionRate = totalUsers > 0 ? (retentionUsers / totalUsers) * 100 : 0;

    res.status(200).json({
      success: true,
      metrics: {
        totalUsers,
        dailyActiveUsers,
        weeklyActiveUsers,
        monthlyActiveUsers,
        newUsers: {
          today: newUsersToday,
          thisWeek: newUsersThisWeek,
          thisMonth: newUsersThisMonth,
        },
        activeBoosts,
        totalRequests,
        totalConversations,
        retentionRate: Math.round(retentionRate * 10) / 10,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch engagement metrics',
    });
  }
};

// Get conversion funnel
export const getConversionFunnel = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { days = 30 } = req.query;
    const daysNum = parseInt(days as string);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysNum);

    const [
      signups,
      profileCompleted,
      boosted,
      contactRequested,
      contactAccepted,
    ] = await Promise.all([
      User.countDocuments({ createdAt: { $gte: startDate } }),
      User.countDocuments({
        createdAt: { $gte: startDate },
        profileCompleted: true, // Assuming this field exists
      }),
      User.countDocuments({
        createdAt: { $gte: startDate },
        boostStatus: 'active',
      }),
      Request.countDocuments({ createdAt: { $gte: startDate } }),
      Request.countDocuments({
        createdAt: { $gte: startDate },
        status: 'accepted',
      }),
    ]);

    const conversionRates = {
      signupToProfile: signups > 0 ? (profileCompleted / signups) * 100 : 0,
      profileToBoost: profileCompleted > 0 ? (boosted / profileCompleted) * 100 : 0,
      boostToRequest: boosted > 0 ? (contactRequested / boosted) * 100 : 0,
      requestToAccept: contactRequested > 0 ? (contactAccepted / contactRequested) * 100 : 0,
    };

    res.status(200).json({
      success: true,
      funnel: {
        signups,
        profileCompleted,
        boosted,
        contactRequested,
        contactAccepted,
        conversionRates: {
          signupToProfile: Math.round(conversionRates.signupToProfile * 10) / 10,
          profileToBoost: Math.round(conversionRates.profileToBoost * 10) / 10,
          boostToRequest: Math.round(conversionRates.boostToRequest * 10) / 10,
          requestToAccept: Math.round(conversionRates.requestToAccept * 10) / 10,
        },
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch conversion funnel',
    });
  }
};

// Get revenue breakdown
export const getRevenueBreakdown = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { days = 30 } = req.query;
    const daysNum = parseInt(days as string);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysNum);

    const revenueBreakdown = await Transaction.aggregate([
      {
        $match: {
          status: 'completed',
          createdAt: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: {
            role: '$userRole',
            boostType: '$boostType',
          },
          revenue: { $sum: '$totalAmount' },
          count: { $sum: 1 },
        },
      },
    ]);

    // Also get by region if city/country available
    const revenueByRegion = await Transaction.aggregate([
      {
        $match: {
          status: 'completed',
          createdAt: { $gte: startDate },
        },
      },
      {
        $lookup: {
          from: 'users',
          localField: 'userId',
          foreignField: '_id',
          as: 'user',
        },
      },
      {
        $unwind: '$user',
      },
      {
        $group: {
          _id: '$user.city',
          revenue: { $sum: '$totalAmount' },
          count: { $sum: 1 },
        },
      },
      {
        $sort: { revenue: -1 },
      },
      {
        $limit: 10,
      },
    ]);

    res.status(200).json({
      success: true,
      breakdown: {
        byRoleAndType: revenueBreakdown,
        byRegion: revenueByRegion,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch revenue breakdown',
    });
  }
};

// Get demographics
export const getDemographics = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const [
      byRole,
      byReligion,
      byCountry,
      byAgeRange,
    ] = await Promise.all([
      User.aggregate([
        {
          $group: {
            _id: '$role',
            count: { $sum: 1 },
          },
        },
      ]),
      User.aggregate([
        {
          $match: { religion: { $exists: true, $ne: null } },
        },
        {
          $group: {
            _id: '$religion',
            count: { $sum: 1 },
          },
        },
        {
          $sort: { count: -1 },
        },
      ]),
      User.aggregate([
        {
          $match: { country: { $exists: true, $ne: null } },
        },
        {
          $group: {
            _id: '$country',
            count: { $sum: 1 },
          },
        },
        {
          $sort: { count: -1 },
        },
        {
          $limit: 10,
        },
      ]),
      User.aggregate([
        {
          $match: { dateOfBirth: { $exists: true } },
        },
        {
          $project: {
            age: {
              $floor: {
                $divide: [
                  { $subtract: [new Date(), '$dateOfBirth'] },
                  365 * 24 * 60 * 60 * 1000,
                ],
              },
            },
          },
        },
        {
          $bucket: {
            groupBy: '$age',
            boundaries: [18, 25, 30, 35, 40, 45, 50, 100],
            default: '50+',
            output: {
              count: { $sum: 1 },
            },
          },
        },
      ]),
    ]);

    res.status(200).json({
      success: true,
      demographics: {
        byRole,
        byReligion,
        byCountry,
        byAgeRange,
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch demographics',
    });
  }
};

// Get retention rates
export const getRetentionRates = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { days = 90 } = req.query;
    const daysNum = parseInt(days as string);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysNum);

    // Get users by signup date (cohorts)
    const cohorts = await User.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m', date: '$createdAt' },
          },
          users: { $push: '$_id' },
          count: { $sum: 1 },
        },
      },
      {
        $sort: { _id: 1 },
      },
    ]);

    // Calculate retention for each cohort
    const retentionData = await Promise.all(
      cohorts.map(async (cohort) => {
        const cohortDate = new Date(cohort._id);
        const week1 = new Date(cohortDate);
        week1.setDate(week1.getDate() + 7);
        const week2 = new Date(cohortDate);
        week2.setDate(week2.getDate() + 14);
        const week4 = new Date(cohortDate);
        week4.setDate(week4.getDate() + 28);

        const [retentionWeek1, retentionWeek2, retentionWeek4] = await Promise.all([
          User.countDocuments({
            _id: { $in: cohort.users },
            lastActiveAt: { $gte: week1 },
          }),
          User.countDocuments({
            _id: { $in: cohort.users },
            lastActiveAt: { $gte: week2 },
          }),
          User.countDocuments({
            _id: { $in: cohort.users },
            lastActiveAt: { $gte: week4 },
          }),
        ]);

        return {
          cohort: cohort._id,
          totalUsers: cohort.count,
          retention: {
            week1: cohort.count > 0 ? (retentionWeek1 / cohort.count) * 100 : 0,
            week2: cohort.count > 0 ? (retentionWeek2 / cohort.count) * 100 : 0,
            week4: cohort.count > 0 ? (retentionWeek4 / cohort.count) * 100 : 0,
          },
        };
      })
    );

    res.status(200).json({
      success: true,
      retention: retentionData,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch retention rates',
    });
  }
};
