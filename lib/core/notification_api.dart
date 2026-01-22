import 'package:dio/dio.dart';
import 'api_client.dart';

class NotificationApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Register FCM token with backend
  Future<Map<String, dynamic>> registerToken({
    required String fcmToken,
    required String deviceType,
  }) async {
    try {
      final response = await _dio.post(
        '/notifications/register-token',
        data: {
          'fcmToken': fcmToken,
          'deviceType': deviceType,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
          'unreadOnly': unreadOnly,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get unread notification counts
  Future<Map<String, dynamic>> getUnreadCounts() async {
    try {
      final response = await _dio.get('/notifications/unread-count');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await _dio.put('/notifications/$notificationId/read');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _dio.put('/notifications/read-all');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete notification
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await _dio.delete('/notifications/$notificationId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update notification preferences
  Future<Map<String, dynamic>> updatePreferences({
    required bool pushEnabled,
    required bool messageNotifications,
    required bool requestNotifications,
    required bool matchNotifications,
    required bool profileViewNotifications,
    required bool boostReminders,
    required bool paymentNotifications,
  }) async {
    try {
      final response = await _dio.put(
        '/notifications/preferences',
        data: {
          'pushEnabled': pushEnabled,
          'messageNotifications': messageNotifications,
          'requestNotifications': requestNotifications,
          'matchNotifications': matchNotifications,
          'profileViewNotifications': profileViewNotifications,
          'boostReminders': boostReminders,
          'paymentNotifications': paymentNotifications,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get notification preferences
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _dio.get('/notifications/preferences');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      return data?['error']?['message'] ?? 'An error occurred';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network.';
    } else {
      return 'An unexpected error occurred';
    }
  }
}
