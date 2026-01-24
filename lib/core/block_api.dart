import 'package:dio/dio.dart';
import 'api_client.dart';

class BlockApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Block user (chat)
  Future<Map<String, dynamic>> blockUser(String targetUserId) async {
    try {
      final response = await _dio.post('/block/$targetUserId');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to block user.',
      };
    }
  }

  /// Unblock user (chat)
  Future<Map<String, dynamic>> unblockUser(String targetUserId) async {
    try {
      final response = await _dio.post('/block/$targetUserId/unblock');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to unblock user.',
      };
    }
  }

  /// Get block status: iBlockedThem, theyBlockedMe
  Future<Map<String, dynamic>> getBlockStatus(String targetUserId) async {
    try {
      final response = await _dio.get('/block/status/$targetUserId');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to get block status.',
        'iBlockedThem': false,
        'theyBlockedMe': false,
      };
    }
  }
}
