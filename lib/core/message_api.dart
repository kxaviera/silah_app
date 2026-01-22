import 'package:dio/dio.dart';
import 'api_client.dart';

class MessageApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Get conversations
  Future<Map<String, dynamic>> getConversations() async {
    try {
      final response = await _dio.get('/messages/conversations');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch conversations.',
        'conversations': [],
      };
    }
  }

  /// Get messages for a conversation
  Future<Map<String, dynamic>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/messages/$conversationId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch messages.',
        'messages': [],
      };
    }
  }

  /// Send message
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    try {
      final response = await _dio.post('/messages', data: {
        'conversationId': conversationId,
        'message': message,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to send message.',
      };
    }
  }

  /// Mark message as read
  Future<Map<String, dynamic>> markAsRead(String messageId) async {
    try {
      final response = await _dio.put('/messages/$messageId/read');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to mark as read.',
      };
    }
  }
}
