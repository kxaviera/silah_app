import 'package:dio/dio.dart';
import 'api_client.dart';

class SettingsApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Get app settings (public endpoint, no auth required)
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final response = await _dio.get('/settings');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch settings.',
        'settings': {
          'paymentEnabled': true,
          'allowFreePosting': false,
          'boostPricing': {
            'bride': {
              'standard': {'price': 199, 'duration': 3, 'enabled': true},
              'featured': {'price': 399, 'duration': 7, 'enabled': true},
            },
            'groom': {
              'standard': {'price': 299, 'duration': 3, 'enabled': true},
              'featured': {'price': 599, 'duration': 7, 'enabled': true},
            },
          },
        },
      };
    }
  }
}
