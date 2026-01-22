import 'package:dio/dio.dart';
import 'api_client.dart';

class PaymentApi {
  final Dio _dio = ApiClient.instance.dio;

  /// Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required String boostType,
    required String role,
    String? promoCode,
  }) async {
    try {
      final response = await _dio.post('/payments/create-intent', data: {
        'boostType': boostType,
        'role': role,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to create payment intent.',
      };
    }
  }

  /// Verify payment
  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String boostType,
  }) async {
    try {
      final response = await _dio.post('/payments/verify', data: {
        'paymentId': paymentId,
        'boostType': boostType,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to verify payment.',
      };
    }
  }

  /// Get invoice
  Future<Map<String, dynamic>> getInvoice(String invoiceNumber) async {
    try {
      final response = await _dio.get('/payments/invoice/$invoiceNumber');
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Failed to fetch invoice.',
      };
    }
  }

  /// Validate promo code
  Future<Map<String, dynamic>> validatePromoCode({
    required String promoCode,
    required String boostType,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/payments/validate-promo', data: {
        'promoCode': promoCode,
        'boostType': boostType,
        'role': role,
      });
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Invalid promo code.',
        'discount': 0,
      };
    }
  }
}
