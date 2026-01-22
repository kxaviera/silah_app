import { Response } from 'express';
import { AdminAuthRequest } from '../middleware/adminAuth.middleware';
import mongoose from 'mongoose';
import os from 'os';

// Get system health
export const getSystemHealth = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    // Database connection status
    const dbState = mongoose.connection.readyState;
    const dbStates = ['disconnected', 'connected', 'connecting', 'disconnecting'];
    const dbStatus = dbStates[dbState] || 'unknown';

    // Server uptime
    const uptime = process.uptime();

    // Memory usage
    const memoryUsage = process.memoryUsage();
    const totalMemory = os.totalmem();
    const freeMemory = os.freemem();
    const usedMemory = totalMemory - freeMemory;

    // CPU info
    const cpus = os.cpus();
    const cpuModel = cpus[0]?.model || 'Unknown';
    const cpuCount = cpus.length;

    // System load (if available)
    const loadAvg = os.loadavg();

    res.status(200).json({
      success: true,
      health: {
        status: dbState === 1 ? 'healthy' : 'degraded',
        database: {
          status: dbStatus,
          connected: dbState === 1,
        },
        server: {
          uptime: Math.floor(uptime),
          uptimeFormatted: formatUptime(uptime),
          nodeVersion: process.version,
          platform: os.platform(),
          arch: os.arch(),
        },
        memory: {
          used: memoryUsage.heapUsed,
          total: memoryUsage.heapTotal,
          external: memoryUsage.external,
          rss: memoryUsage.rss,
          systemTotal: totalMemory,
          systemFree: freeMemory,
          systemUsed: usedMemory,
          systemUsagePercent: (usedMemory / totalMemory) * 100,
        },
        cpu: {
          model: cpuModel,
          cores: cpuCount,
          loadAverage: loadAvg,
        },
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch system health',
    });
  }
};

// Get system metrics
export const getSystemMetrics = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { hours = 24 } = req.query;
    const hoursNum = parseInt(hours as string);

    // This would typically come from a metrics collection
    // For now, return current metrics
    const memoryUsage = process.memoryUsage();
    const totalMemory = os.totalmem();
    const freeMemory = os.freemem();

    res.status(200).json({
      success: true,
      metrics: {
        memory: {
          heapUsed: memoryUsage.heapUsed,
          heapTotal: memoryUsage.heapTotal,
          rss: memoryUsage.rss,
          systemTotal: totalMemory,
          systemFree: freeMemory,
          systemUsed: totalMemory - freeMemory,
        },
        cpu: {
          loadAverage: os.loadavg(),
          cores: os.cpus().length,
        },
        uptime: process.uptime(),
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch system metrics',
    });
  }
};

// Get recent errors
export const getRecentErrors = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    // This would typically come from an error log collection
    // For now, return empty array
    // In production, you'd store errors in a collection

    res.status(200).json({
      success: true,
      errors: [],
      message: 'Error logging not implemented. Consider using a logging service like Winston or Sentry.',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch recent errors',
    });
  }
};

// Get service status
export const getServiceStatus = async (
  req: AdminAuthRequest,
  res: Response
): Promise<void> => {
  try {
    const dbState = mongoose.connection.readyState;
    const dbConnected = dbState === 1;

    // Check external services (would need actual checks)
    const services = {
      database: {
        status: dbConnected ? 'operational' : 'down',
        responseTime: 0, // Would measure actual response time
      },
      email: {
        status: 'operational', // Would check email service
        responseTime: 0,
      },
      sms: {
        status: 'operational', // Would check SMS service
        responseTime: 0,
      },
      payment: {
        status: 'operational', // Would check payment gateway
        responseTime: 0,
      },
    };

    const allOperational = Object.values(services).every(
      (service) => service.status === 'operational'
    );

    res.status(200).json({
      success: true,
      status: allOperational ? 'all_operational' : 'degraded',
      services,
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to fetch service status',
    });
  }
};

// Helper function
const formatUptime = (seconds: number): string => {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);

  if (days > 0) {
    return `${days}d ${hours}h ${minutes}m`;
  } else if (hours > 0) {
    return `${hours}h ${minutes}m ${secs}s`;
  } else if (minutes > 0) {
    return `${minutes}m ${secs}s`;
  } else {
    return `${secs}s`;
  }
};
