import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import http from 'http';
import { Server } from 'socket.io';
import path from 'path';
import { connectDB } from './config/database';
import adminAuthRoutes from './routes/adminAuth.routes';
import adminDashboardRoutes from './routes/adminDashboard.routes';
import adminUsersRoutes from './routes/adminUsers.routes';
import adminReportsRoutes from './routes/adminReports.routes';
import adminTransactionsRoutes from './routes/adminTransactions.routes';
import adminSettingsRoutes from './routes/adminSettings.routes';
import adminPromoCodesRoutes from './routes/adminPromoCodes.routes';
import adminActivityLogsRoutes from './routes/adminActivityLogs.routes';
import adminBulkOperationsRoutes from './routes/adminBulkOperations.routes';
import adminCommunicationsRoutes from './routes/adminCommunications.routes';
import adminAnalyticsRoutes from './routes/adminAnalytics.routes';
import adminSystemHealthRoutes from './routes/adminSystemHealth.routes';
import { logActivity } from './middleware/activityLogger.middleware';
// User-facing routes
import authRoutes from './routes/auth.routes';
import profileRoutes from './routes/profile.routes';
import boostRoutes from './routes/boost.routes';
import requestRoutes from './routes/request.routes';
import messageRoutes from './routes/message.routes';
import notificationRoutes from './routes/notification.routes';
import settingsRoutes from './routes/settings.routes';
import paymentRoutes from './routes/payment.routes';

// Load environment variables
// When running from dist/, __dirname is dist/, so go up one level to backend root
const envPath = path.resolve(__dirname, '..', '.env');
console.log('📁 Loading .env from:', envPath);
dotenv.config({ path: envPath });
console.log('🔍 MONGODB_URI:', process.env.MONGODB_URI ? 'Found' : 'NOT FOUND');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || '*',
    methods: ['GET', 'POST'],
  },
});
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files (uploaded photos)
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// User-facing routes
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/boost', boostRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/payment', paymentRoutes);

// Admin routes
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/admin/dashboard', adminDashboardRoutes);
app.use('/api/admin/users', adminUsersRoutes);
app.use('/api/admin/reports', adminReportsRoutes);
app.use('/api/admin/transactions', adminTransactionsRoutes);
app.use('/api/admin/settings', adminSettingsRoutes);
app.use('/api/admin/promo-codes', adminPromoCodesRoutes);
app.use('/api/admin/activity-logs', adminActivityLogsRoutes);
app.use('/api/admin/bulk', adminBulkOperationsRoutes);
app.use('/api/admin/communications', adminCommunicationsRoutes);
app.use('/api/admin/analytics', adminAnalyticsRoutes);
app.use('/api/admin/system', adminSystemHealthRoutes);

// Apply activity logging to all admin routes (except auth)
app.use('/api/admin', logActivity);

// Socket.io connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Join user room
  socket.on('join:user', (userId: string) => {
    socket.join(`user:${userId}`);
    console.log(`User ${userId} joined their room`);
  });

  // Leave user room
  socket.on('leave:user', (userId: string) => {
    socket.leave(`user:${userId}`);
    console.log(`User ${userId} left their room`);
  });

  // Join conversation room
  socket.on('join:conversation', (conversationId: string) => {
    socket.join(`conversation:${conversationId}`);
    console.log(`User joined conversation ${conversationId}`);
  });

  // Leave conversation room
  socket.on('leave:conversation', (conversationId: string) => {
    socket.leave(`conversation:${conversationId}`);
    console.log(`User left conversation ${conversationId}`);
  });

  // Handle typing indicators
  socket.on('typing:start', (data: { conversationId: string; userId: string }) => {
    socket.to(`conversation:${data.conversationId}`).emit('typing:indicator', {
      userId: data.userId,
      isTyping: true,
    });
  });

  socket.on('typing:stop', (data: { conversationId: string; userId: string }) => {
    socket.to(`conversation:${data.conversationId}`).emit('typing:indicator', {
      userId: data.userId,
      isTyping: false,
    });
  });

  // Handle new message (from client)
  socket.on('send:message', async (data: { conversationId: string; message: any }) => {
    // Broadcast to conversation room
    io.to(`conversation:${data.conversationId}`).emit('new:message', data.message);
  });

  // Handle new request notification
  socket.on('new:request', (data: { userId: string; request: any }) => {
    io.to(`user:${data.userId}`).emit('new:request', data.request);
  });

  // Handle request accepted/rejected
  socket.on('request:accepted', (data: { userId: string; request: any }) => {
    io.to(`user:${data.userId}`).emit('request:accepted', data.request);
  });

  socket.on('request:rejected', (data: { userId: string; request: any }) => {
    io.to(`user:${data.userId}`).emit('request:rejected', data.request);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Export io for use in controllers
export { io };

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
  });
});

// Start server
const startServer = async () => {
  try {
    // Connect to database
    await connectDB();
    
    // Start listening
    server.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📡 API available at http://localhost:${PORT}/api`);
      console.log(`🔌 Socket.io ready for connections`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
