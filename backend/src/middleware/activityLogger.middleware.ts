import { Request, Response, NextFunction } from 'express';
import { ActivityLog } from '../models/ActivityLog.model';
import { AdminAuthRequest } from './adminAuth.middleware';

export const logActivity = async (
  req: AdminAuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  // Store original json method
  const originalJson = res.json.bind(res);

  // Override json method to log after response
  res.json = function (body: any) {
    // Log activity asynchronously (don't block response)
    logActivityAsync(req, res, body).catch(console.error);
    return originalJson(body);
  };

  next();
};

const logActivityAsync = async (
  req: AdminAuthRequest,
  res: Response,
  body: any
): Promise<void> => {
  try {
    // Only log successful admin actions
    if (!req.admin || !body.success) {
      return;
    }

    const action = getActionFromRoute(req.method, req.path);
    if (!action) {
      return; // Don't log if action not recognized
    }

    const entityType = getEntityTypeFromPath(req.path);
    const entityId = req.params.id || req.params.userId || req.params.reportId || req.params.transactionId;

    const description = generateDescription(req, body);

    await ActivityLog.create({
      adminId: req.admin.id,
      action,
      entityType,
      entityId: entityId ? entityId : undefined,
      description,
      metadata: {
        method: req.method,
        path: req.path,
        body: sanitizeBody(req.body),
        response: sanitizeResponse(body),
      },
      ipAddress: req.ip || req.headers['x-forwarded-for'] as string,
      userAgent: req.headers['user-agent'],
    });
  } catch (error) {
    // Don't throw - logging should never break the request
    console.error('Activity logging error:', error);
  }
};

const getActionFromRoute = (method: string, path: string): string | null => {
  // Map routes to actions
  if (path.includes('/users/') && path.includes('/block')) return 'user.blocked';
  if (path.includes('/users/') && path.includes('/unblock')) return 'user.unblocked';
  if (path.includes('/users/') && path.includes('/verify')) return 'user.verified';
  if (path.includes('/users/') && method === 'DELETE') return 'user.deleted';
  if (path.includes('/reports/') && path.includes('/review')) return 'report.reviewed';
  if (path.includes('/reports/') && path.includes('/resolve')) return 'report.resolved';
  if (path.includes('/reports/') && method === 'DELETE') return 'report.deleted';
  if (path.includes('/transactions/') && path.includes('/refund')) return 'transaction.refunded';
  if (path.includes('/settings/pricing')) return 'settings.pricing_updated';
  if (path.includes('/settings/payment')) return 'settings.payment_updated';
  if (path.includes('/settings/company')) return 'settings.company_updated';
  if (path.includes('/promo-codes') && method === 'POST') return 'promo_code.created';
  if (path.includes('/promo-codes/') && method === 'PUT') return 'promo_code.updated';
  if (path.includes('/promo-codes/') && method === 'DELETE') return 'promo_code.deleted';
  if (path.includes('/users/bulk')) return 'users.bulk_action';
  
  return null;
};

const getEntityTypeFromPath = (path: string): string => {
  if (path.includes('/users')) return 'user';
  if (path.includes('/reports')) return 'report';
  if (path.includes('/transactions')) return 'transaction';
  if (path.includes('/settings')) return 'settings';
  if (path.includes('/promo-codes')) return 'promo_code';
  return 'unknown';
};

const generateDescription = (req: AdminAuthRequest, body: any): string => {
  const adminEmail = req.admin?.email || 'Unknown';
  
  if (req.path.includes('/users/') && req.path.includes('/block')) {
    return `${adminEmail} blocked user ${req.params.id}`;
  }
  if (req.path.includes('/users/') && req.path.includes('/unblock')) {
    return `${adminEmail} unblocked user ${req.params.id}`;
  }
  if (req.path.includes('/users/') && req.path.includes('/verify')) {
    return `${adminEmail} verified user ${req.params.id}`;
  }
  if (req.path.includes('/users/') && req.method === 'DELETE') {
    return `${adminEmail} deleted user ${req.params.id}`;
  }
  if (req.path.includes('/reports/') && req.path.includes('/resolve')) {
    const action = req.body.action || 'resolved';
    return `${adminEmail} ${action} report ${req.params.id}`;
  }
  if (req.path.includes('/settings/pricing')) {
    return `${adminEmail} updated boost pricing`;
  }
  if (req.path.includes('/promo-codes') && req.method === 'POST') {
    return `${adminEmail} created promo code ${req.body.code}`;
  }
  
  return `${adminEmail} performed action on ${req.path}`;
};

const sanitizeBody = (body: any): any => {
  if (!body) return {};
  const sanitized = { ...body };
  // Remove sensitive fields
  delete sanitized.password;
  delete sanitized.token;
  return sanitized;
};

const sanitizeResponse = (body: any): any => {
  if (!body) return {};
  // Only include success and message, not full data
  return {
    success: body.success,
    message: body.message,
  };
};
