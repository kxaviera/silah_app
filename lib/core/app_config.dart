/// App configuration for different environments
class AppConfig {
  // Environment: 'development', 'staging', 'production'
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Base URL
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.silah.com/api'; // TODO: Update with actual production URL
      case 'staging':
        return 'https://staging-api.silah.com/api'; // TODO: Update with actual staging URL
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
