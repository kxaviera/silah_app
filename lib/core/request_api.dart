import 'package:dio/dio.dart';
import 'api_client.dart';

class RequestApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Send contact request
  Future<Map<String, dynamic>> sendRequest({
    required String userId,
    required String requestType, // 'mobile', 'photos', 'both'
  }) async {
    try {
      final response = await _dio.post('/requests', data: {
        // Send both keys so it works with old/new backend handlers
        'userId': userId,
        'toUserId': userId,
        'requestType': requestType,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to send request.',
      };
    }
  }

  /// Get received requests
  Future<Map<String, dynamic>> getReceivedRequests() async {
    try {
      final response = await _dio.get('/requests/received');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch requests.',
        'requests': [],
      };
    }
  }

  /// Get sent requests
  Future<Map<String, dynamic>> getSentRequests() async {
    try {
      final response = await _dio.get('/requests/sent');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch requests.',
        'requests': [],
      };
    }
  }

  /// Accept request
  Future<Map<String, dynamic>> acceptRequest(String requestId) async {
    try {
      final response = await _dio.post('/requests/$requestId/accept');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to accept request.',
      };
    }
  }

  /// Reject request
  Future<Map<String, dynamic>> rejectRequest(String requestId) async {
    try {
      final response = await _dio.post('/requests/$requestId/reject');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to reject request.',
      };
    }
  }

  /// Check if contact request is approved (for chat access)
  Future<Map<String, dynamic>> checkRequestStatus(String userId) async {
    try {
      final response = await _dio.get('/requests/status/$userId');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'approved': false,
        'message': e.response?.data['message'] ?? 'Failed to check request status.',
      };
    }
  }
}
