import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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

  /// Send message.
  ///
  /// - Use [conversationId] when an existing conversation already exists.
  /// - Use [receiverId] (without [conversationId]) to start a brand new chat.
  Future<Map<String, dynamic>> sendMessage({
    String? conversationId,
    String? receiverId,
    required String message,
  }) async {
    try {
      final payload = <String, dynamic>{
        'message': message,
      };
      if (conversationId != null) {
        payload['conversationId'] = conversationId;
      }
      if (receiverId != null) {
        payload['receiverId'] = receiverId;
      }

      final response = await _dio.post('/messages', data: payload);
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to send message.',
      };
    }
  }

  /// Send an image message for a conversation.
  Future<Map<String, dynamic>> sendImage({
    String? conversationId,
    String? receiverId,
    required XFile image,
  }) async {
    try {
      final formData = FormData();

      if (conversationId != null) {
        formData.fields.add(MapEntry('conversationId', conversationId));
      }
      if (receiverId != null) {
        formData.fields.add(MapEntry('receiverId', receiverId));
      }

      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.name,
          ),
        ),
      );

      final response = await _dio.post(
        '/messages',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to send image.',
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
