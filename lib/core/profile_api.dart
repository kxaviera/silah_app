import 'package:dio/dio.dart';
import 'api_client.dart';

class ProfileApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Complete profile after signup
  Future<Map<String, dynamic>> completeProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await _dio.put('/profiles/complete', data: profileData);
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to complete profile.',
      };
    }
  }

  /// Upload profile photo
  Future<Map<String, dynamic>> uploadPhoto({
    required String imagePath,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imagePath,
          filename: 'profile_photo.jpg',
        ),
      });

      final response = await _dio.post(
        '/profiles/photo',
        data: formData,
        onSendProgress: onProgress,
      );

      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to upload photo.',
      };
    }
  }

  /// Search profiles
  Future<Map<String, dynamic>> searchProfiles({
    String? search,
    String? country,
    String? state,
    String? city,
    String? religion,
    String? livingCountry,
    bool? onlyNRIs,
    bool? onlyInIndia,
    int? minAge,
    int? maxAge,
    int? minHeight,
    String? prioritizeByCity, // User's city for prioritization
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (religion != null) 'religion': religion,
        if (livingCountry != null) 'livingCountry': livingCountry,
        if (onlyNRIs == true) 'onlyNRIs': true,
        if (onlyInIndia == true) 'onlyInIndia': true,
        if (minAge != null) 'minAge': minAge,
        if (maxAge != null) 'maxAge': maxAge,
        if (minHeight != null) 'minHeight': minHeight,
        if (prioritizeByCity != null && prioritizeByCity.isNotEmpty) 'prioritizeByCity': prioritizeByCity,
      };

      final response = await _dio.get('/profiles/search', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to search profiles.',
        'profiles': [],
      };
    }
  }

  /// Get profile by ID
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await _dio.get('/profiles/$userId');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch profile.',
      };
    }
  }

  /// Update profile
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await _dio.put('/profiles', data: profileData);
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to update profile.',
      };
    }
  }

  /// Get profile analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _dio.get('/profiles/analytics');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch analytics.',
      };
    }
  }

  /// Activate boost (free or paid)
  Future<Map<String, dynamic>> activateBoost({
    required String boostType,
    String? paymentId,
    bool isFree = false,
  }) async {
    try {
      final response = await _dio.post('/boost/activate', data: {
        'boostType': boostType,
        if (paymentId != null) 'paymentId': paymentId,
        'isFree': isFree,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to activate boost.',
      };
    }
  }

  /// Get boost status
  Future<Map<String, dynamic>> getBoostStatus() async {
    try {
      final response = await _dio.get('/boost/status');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch boost status.',
      };
    }
  }
}
