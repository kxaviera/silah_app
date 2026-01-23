import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import { Communication } from '../models/Communication.model';
import { EmailTemplate } from '../models/EmailTemplate.model';
import { ActivityLog } from '../models/ActivityLog.model';
import { emailService } from '../services/email.service';
import { smsService } from '../services/sms.service';
import { User } from '../models/User.model';

// Send email
export const sendEmail = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { recipientId, recipientEmail, subject, message, templateId, variables } = req.body;

    if (!recipientEmail && !recipientId) {
      res.status(400).json({
        success: false,
        message: 'Either recipientId or recipientEmail is required',
      });
      return;
    }

    let email = recipientEmail;
    let userId = recipientId;

    // If recipientId provided, get email from user
    if (recipientId && !recipientEmail) {
      const user = await User.findById(recipientId).select('email');
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found',
        });
        return;
      }
      email = (user as any).email;
      userId = recipientId;
    }

    // If templateId provided, use template
    let finalSubject = subject;
    let finalMessage = message;

    if (templateId) {
      const template = await EmailTemplate.findById(templateId);
      if (!template) {
        res.status(404).json({
          success: false,
          message: 'Template not found',
        });
        return;
      }

      finalSubject = template.subject;
      finalMessage = template.body;

      // Replace variables
      if (variables) {
        Object.keys(variables).forEach((key) => {
          finalSubject = finalSubject.replace(new RegExp(`{{${key}}}`, 'g'), variables[key]);
          finalMessage = finalMessage.replace(new RegExp(`{{${key}}}`, 'g'), variables[key]);
        });
      }
    }

    // Create communication record
    const communication = new Communication({
      type: 'email',
      recipientId: userId,
      recipientEmail: email,
      subject: finalSubject,
      message: finalMessage,
      templateId,
      status: 'pending',
      sentBy: req.admin?.id,
      metadata: { variables },
    });

    await communication.save();

    // Send email using SendGrid
    const emailResult = await emailService.sendEmail({
      to: email,
      subject: finalSubject,
      html: finalMessage,
    });

    if (emailResult.success) {
      communication.status = 'sent';
      communication.sentAt = new Date();
      communication.metadata = {
        ...communication.metadata,
        messageId: emailResult.messageId,
      };
    } else {
      communication.status = 'failed';
      communication.error = emailResult.error;
    }
    await communication.save();

    // Log activity
    await ActivityLog.create({
      adminId: req.admin?.id,
      action: 'communication.email_sent',
      entityType: 'communication',
      entityId: communication._id,
      description: `${req.admin?.email} sent email to ${email}`,
      metadata: { subject: finalSubject },
    });

    if (communication.status === 'failed') {
      res.status(500).json({
        success: false,
        message: 'Failed to send email',
        error: communication.error,
        communication,
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Email sent successfully',
      communication,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send email',
    });
  }
};

// Send SMS
export const sendSMS = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { recipientId, recipientPhone, message } = req.body;

    if (!recipientPhone && !recipientId) {
      res.status(400).json({
        success: false,
        message: 'Either recipientId or recipientPhone is required',
      });
      return;
    }

    let phone = recipientPhone;
    let userId = recipientId;

    // If recipientId provided, get phone from user
    if (recipientId && !recipientPhone) {
      const user = await User.findById(recipientId).select('mobile');
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found',
        });
        return;
      }
      phone = (user as any).mobile;
      userId = recipientId;
    }

    // Create communication record
    const communication = new Communication({
      type: 'sms',
      recipientId: userId,
      recipientPhone: phone,
      message,
      status: 'pending',
      sentBy: req.admin?.id,
    });

    await communication.save();

    // Send SMS using Twilio
    const smsResult = await smsService.sendSMS({
      to: phone,
      message,
    });

    if (smsResult.success) {
      communication.status = 'sent';
      communication.sentAt = new Date();
      communication.metadata = {
        messageId: smsResult.messageId,
      };
    } else {
      communication.status = 'failed';
      communication.error = smsResult.error;
    }
    await communication.save();

    // Log activity
    await ActivityLog.create({
      adminId: req.admin?.id,
      action: 'communication.sms_sent',
      entityType: 'communication',
      entityId: communication._id,
      description: `${req.admin?.email} sent SMS to ${phone}`,
    });

    if (communication.status === 'failed') {
      res.status(500).json({
        success: false,
        message: 'Failed to send SMS',
        error: communication.error,
        communication,
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'SMS sent successfully',
      communication,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send SMS',
    });
  }
};

// Bulk email
export const bulkEmail = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { userIds, subject, message, templateId, variables } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      res.status(400).json({
        success: false,
        message: 'User IDs array is required',
      });
      return;
    }

    const users = await User.find({ _id: { $in: userIds } }).select('email');

    const communications = users.map((user: any) => ({
      type: 'email',
      recipientId: user._id,
      recipientEmail: user.email,
      subject,
      message,
      templateId,
      status: 'pending',
      sentBy: req.admin?.id,
      metadata: { variables },
    }));

    const created = await Communication.insertMany(communications);

    // Prepare emails for bulk send
    const emailList = users.map((user: any, index: number) => ({
      to: user.email,
      subject,
      html: message,
    }));

    // Send bulk emails
    const bulkResult = await emailService.sendBulkEmails(emailList);

    // Update communication statuses
    if (bulkResult.success) {
      await Communication.updateMany(
        { _id: { $in: created.map((c) => c._id) } },
        { status: 'sent', sentAt: new Date() }
      );
    } else {
      // Update based on results (in a real scenario, you'd track which ones succeeded)
      // For simplicity, mark all as sent if any succeeded
      if (bulkResult.sent > 0) {
        await Communication.updateMany(
          { _id: { $in: created.slice(0, bulkResult.sent).map((c) => c._id) } },
          { status: 'sent', sentAt: new Date() }
        );
        if (bulkResult.failed > 0) {
          await Communication.updateMany(
            { _id: { $in: created.slice(bulkResult.sent).map((c) => c._id) } },
            { status: 'failed', error: 'Bulk send partially failed' }
          );
        }
      } else {
        await Communication.updateMany(
          { _id: { $in: created.map((c) => c._id) } },
          { status: 'failed', error: 'Bulk send failed' }
        );
      }
    }

    // Log activity
    await ActivityLog.create({
      adminId: req.admin?.id,
      action: 'communication.bulk_email_sent',
      entityType: 'communication',
      description: `${req.admin?.email} sent bulk email to ${users.length} users`,
      metadata: { count: users.length },
    });

    res.status(bulkResult.success ? 200 : 207).json({
      success: bulkResult.success,
      message: `Bulk email: ${bulkResult.sent} sent, ${bulkResult.failed} failed`,
      sent: bulkResult.sent,
      failed: bulkResult.failed,
      errors: bulkResult.errors,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send bulk email',
    });
  }
};

// Get email templates
export const getTemplates = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { category, isActive } = req.query;

    const query: any = {};
    if (category) {
      query.category = category;
    }
    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    const templates = await EmailTemplate.find(query).sort({ createdAt: -1 }).lean();

    res.status(200).json({
      success: true,
      templates,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch templates',
    });
  }
};

// Create email template
export const createTemplate = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { name, subject, body, variables, category, isActive } = req.body;

    if (!name || !subject || !body) {
      res.status(400).json({
        success: false,
        message: 'Name, subject, and body are required',
      });
      return;
    }

    const template = new EmailTemplate({
      name,
      subject,
      body,
      variables,
      category: category || 'custom',
      isActive: isActive !== undefined ? isActive : true,
    });

    await template.save();

    res.status(201).json({
      success: true,
      message: 'Template created successfully',
      template,
    });
  } catch (error: any) {
    if (error.code === 11000) {
      res.status(400).json({
        success: false,
        message: 'Template name already exists',
      });
      return;
    }
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to create template',
    });
  }
};

// Update email template
export const updateTemplate = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const template = await EmailTemplate.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!template) {
      res.status(404).json({
        success: false,
        message: 'Template not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      message: 'Template updated successfully',
      template,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update template',
    });
  }
};

// Get communication history
export const getHistory = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const {
      type,
      status,
      recipientId,
      startDate,
      endDate,
      page = 1,
      limit = 50,
    } = req.query;

    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    const query: any = {};

    if (type) {
      query.type = type;
    }
    if (status) {
      query.status = status;
    }
    if (recipientId) {
      query.recipientId = recipientId;
    }

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

    const [communications, total] = await Promise.all([
      Communication.find(query)
        .populate('recipientId', 'fullName email')
        .populate('sentBy', 'email fullName')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .lean(),
      Communication.countDocuments(query),
    ]);

    res.status(200).json({
      success: true,
      communications,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        pages: Math.ceil(total / limitNum),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch communication history',
    });
  }
};
