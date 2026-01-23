import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Register new user (basic info only - rest in complete profile)
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? role, // Optional - will be set in complete profile
    String? mobile,
  }) async {
    try {
      // Debug: Log the API URL being used
      print('🔗 API Base URL: ${ApiClient.baseUrl}');
      print('📤 Registering user: $email');
      
      final response = await _dio.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (role != null) 'role': role, // Only send if provided
        if (mobile != null) 'mobile': mobile,
      });

      print('✅ Registration successful');
      
      if (response.data['success'] == true) {
        // Store token
        final token = response.data['token'] as String;
        await ApiClient.instance.setToken(token);
      }

      return response.data;
    } on DioException catch (e) {
      // Enhanced error logging
      print('❌ Registration error:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.response?.data}');
      print('   Error: ${e.message}');
      print('   Type: ${e.type}');
      
      String errorMessage = 'Registration failed. Please try again.';
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Please check:\n• Your internet connection\n• The server is running\n• API URL: ${ApiClient.baseUrl}';
      } else if (e.response != null) {
        // Server responded with an error
        final serverMessage = e.response?.data['message'];
        if (serverMessage != null) {
          errorMessage = serverMessage.toString();
        } else {
          errorMessage = 'Server error (${e.response?.statusCode}). Please try again.';
        }
      } else {
        // No response from server
        errorMessage = 'Network error: ${e.message ?? "Unable to reach server"}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
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
