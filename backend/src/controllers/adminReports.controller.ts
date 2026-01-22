import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { Report } from '../models/Report.model';
import mongoose from 'mongoose';

const User = mongoose.models.User || mongoose.model('User', new mongoose.Schema({}, { strict: false }));

// Get all reports with filters
export const getReports = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const {
      status,
      sortBy = 'date',
      page = 1,
      limit = 20,
    } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    // Build query
    const query: any = {};
    if (status && status !== 'all') {
      query.status = status;
    }

    // Sort
    let sort: any = { createdAt: -1 };
    if (sortBy === 'count') {
      // Sort by number of reports for same user (would need aggregation)
      sort = { createdAt: -1 };
    }

    // Execute query with population
    const [reports, total] = await Promise.all([
      Report.find(query)
        .populate('reporterId', 'fullName email')
        .populate('reportedUserId', 'fullName email')
        .sort(sort)
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Report.countDocuments(query),
    ]);

    // Format response
    const formattedReports = reports.map((report: any) => ({
      _id: report._id,
      reporterId: report.reporterId?._id || report.reporterId,
      reportedUserId: report.reportedUserId?._id || report.reportedUserId,
      reporter: report.reporterId
        ? {
            _id: report.reporterId._id,
            fullName: report.reporterId.fullName,
            email: report.reporterId.email,
          }
        : null,
      reportedUser: report.reportedUserId
        ? {
            _id: report.reportedUserId._id,
            fullName: report.reportedUserId.fullName,
            email: report.reportedUserId.email,
          }
        : null,
      reason: report.reason,
      description: report.description,
      status: report.status,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
    }));

    res.status(200).json({
      success: true,
      reports: formattedReports,
      total,
      page: pageNum,
      limit: limitNum,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch reports',
    });
  }
};

// Get report by ID
export const getReportById = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const report = await Report.findById(id)
      .populate('reporterId', 'fullName email')
      .populate('reportedUserId', 'fullName email')
      .lean();

    if (!report) {
      res.status(404).json({
        success: false,
        message: 'Report not found',
      });
      return;
    }

    const formattedReport: any = {
      ...report,
      reporter: report.reporterId
        ? {
            _id: (report.reporterId as any)._id,
            fullName: (report.reporterId as any).fullName,
            email: (report.reporterId as any).email,
          }
        : null,
      reportedUser: report.reportedUserId
        ? {
            _id: (report.reportedUserId as any)._id,
            fullName: (report.reportedUserId as any).fullName,
            email: (report.reportedUserId as any).email,
          }
        : null,
    };

    delete formattedReport.reporterId;
    delete formattedReport.reportedUserId;

    res.status(200).json({
      success: true,
      report: formattedReport,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch report',
    });
  }
};

// Review report
export const reviewReport = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const { notes } = req.body;

    const report = await Report.findByIdAndUpdate(
      id,
      { 
        status: 'reviewed',
        reviewNotes: notes,
        reviewedBy: new mongoose.Types.ObjectId(req.admin?.id || ''),
        reviewedAt: new Date(),
      },
      { new: true }
    );

    if (!report) {
      res.status(404).json({
        success: false,
        message: 'Report not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Report reviewed successfully',
      report,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to review report',
    });
  }
};

// Resolve report
export const resolveReport = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const { action } = req.body; // Frontend sends action as string (e.g., "Warning sent, User blocked")

    // Accept any action string from frontend
    if (!action || typeof action !== 'string') {
      res.status(400).json({
        success: false,
        message: 'Action is required',
      });
      return;
    }

    const report = await Report.findById(id);
    if (!report) {
      res.status(404).json({
        success: false,
        message: 'Report not found',
      });
      return;
    }

    // Update report
    report.status = 'resolved';
    report.resolvedBy = new mongoose.Types.ObjectId(req.admin?.id || '');
    report.resolvedAt = new Date();
    report.resolutionAction = action;
    if (req.body.notes) {
      report.resolutionNotes = req.body.notes;
    }

    await report.save();

    // If action contains 'block', block the reported user
    if (action.toLowerCase().includes('block')) {
      await User.findByIdAndUpdate(report.reportedUserId, {
        isBlocked: true,
        blockedAt: new Date(),
        blockedReason: `Blocked due to report: ${report.reason}`,
        blockedBy: req.admin?.id,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Report resolved successfully',
      report,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to resolve report',
    });
  }
};

// Delete report
export const deleteReport = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;

    const report = await Report.findByIdAndDelete(id);

    if (!report) {
      res.status(404).json({
        success: false,
        message: 'Report not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Report deleted successfully',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to delete report',
    });
  }
};
