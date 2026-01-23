/// App configuration for different environments
class AppConfig {
  // Environment: 'development', 'staging', 'production'
  // TEMPORARY: Set to 'production' for testing (remove after testing)
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'production', // Changed from 'development' to 'production' for testing
  );

  // API Base URL
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.rewardo.fun/api'; // Production API URL
      case 'staging':
        return 'https://staging-api.rewardo.fun/api'; // Staging API URL
      case 'development':
      default:
        return 'http://localhost:5000/api'; // Development URL
    }
  }

  // Socket.io URL (derived from base URL)
  static String get socketUrl {
    final url = baseUrl.replaceFirst('/api', '');
    return url.replaceFirst('http://', '').replaceFirst('https://', '');
  }

  // Socket.io Protocol
  static String get socketProtocol {
    return baseUrl.startsWith('https') ? 'https' : 'http';
  }

  // Full Socket.io URL
  static String get fullSocketUrl {
    return '$socketProtocol://$socketUrl';
  }

  // Debug mode
  static bool get isDebugMode => environment != 'production';

  // Enable test features
  static bool get enableTestFeatures => environment == 'development';
}
