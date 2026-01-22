import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Register new user (basic info only - rest in complete profile)
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? mobile,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        if (mobile != null) 'mobile': mobile,
      });

      if (response.data['success'] == true) {
        // Store token
        final token = response.data['token'] as String;
        await ApiClient.instance.setToken(token);
      }

      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Registration failed. Please try again.',
      };
    }
  }

  /// Login with email/password
  Future<Map<String, dynamic>> login({
    required String emailOrMobile,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'emailOrMobile': emailOrMobile,
        'password': password,
      });

      if (response.data['success'] == true) {
        // Store token
        final token = response.data['token'] as String;
        await ApiClient.instance.setToken(token);
      }

      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Login failed. Please check your credentials.',
      };
    }
  }

  /// Google Sign-In
  Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
  }) async {
    try {
      final response = await _dio.post('/auth/google', data: {
        'idToken': idToken,
      });

      if (response.data['success'] == true) {
        // Store token
        final token = response.data['token'] as String;
        await ApiClient.instance.setToken(token);
      }

      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Google Sign-In failed. Please try again.',
      };
    }
  }

  /// Get current user
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch user data.',
      };
    }
  }

  /// Forgot password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to send reset email.',
      };
    }
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'token': token,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to reset password.',
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore errors on logout
    } finally {
      // Clear token regardless
      await ApiClient.instance.clearToken();
    }
  }
}
