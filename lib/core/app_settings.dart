import 'settings_api.dart';

// App settings model - fetched from backend
class AppSettings {
  final bool paymentEnabled;
  final BoostPricing boostPricing;
  final bool allowFreePosting;

  AppSettings({
    required this.paymentEnabled,
    required this.boostPricing,
    required this.allowFreePosting,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      paymentEnabled: json['paymentEnabled'] ?? true,
      allowFreePosting: json['allowFreePosting'] ?? false,
      boostPricing: BoostPricing.fromJson(json['boostPricing'] ?? {}),
    );
  }

  // Default settings (fallback)
  factory AppSettings.defaultSettings() {
    return AppSettings(
      paymentEnabled: true,
      allowFreePosting: false,
      boostPricing: BoostPricing.defaultPricing(),
    );
  }
}

class BoostPricing {
  final BoostPlan standard;
  final BoostPlan featured;

  BoostPricing({
    required this.standard,
    required this.featured,
  });

  factory BoostPricing.fromJson(Map<String, dynamic> json) {
    return BoostPricing(
      standard: BoostPlan.fromJson(json['standard'] ?? {}),
      featured: BoostPlan.fromJson(json['featured'] ?? {}),
    );
  }

  factory BoostPricing.defaultPricing() {
    return BoostPricing(
      standard: BoostPlan.defaultPlan('standard'),
      featured: BoostPlan.defaultPlan('featured'),
    );
  }

  // Get price for role and boost type
  int getPrice(String role, String boostType) {
    final plan = boostType == 'featured' ? featured : standard;
    return plan.getPrice(role);
  }

  // Get duration for boost type
  int getDuration(String boostType) {
    final plan = boostType == 'featured' ? featured : standard;
    return plan.duration;
  }
}

class BoostPlan {
  final RolePricing bride;
  final RolePricing groom;
  final int duration;

  BoostPlan({
    required this.bride,
    required this.groom,
    required this.duration,
  });

  factory BoostPlan.fromJson(Map<String, dynamic> json) {
    return BoostPlan(
      duration: json['duration'] ?? 3,
      bride: RolePricing.fromJson(json['bride'] ?? {}),
      groom: RolePricing.fromJson(json['groom'] ?? {}),
    );
  }

  factory BoostPlan.defaultPlan(String type) {
    final isFeatured = type == 'featured';
    return BoostPlan(
      duration: isFeatured ? 7 : 3,
      bride: RolePricing(
        price: isFeatured ? 399 : 199,
        enabled: true,
      ),
      groom: RolePricing(
        price: isFeatured ? 599 : 299,
        enabled: true,
      ),
    );
  }

  // Get price for role
  int getPrice(String role) {
    final rolePricing = role.toLowerCase() == 'bride' ? bride : groom;
    return rolePricing.enabled ? rolePricing.price : 0;
  }

  // Check if boost type is enabled for role
  bool isEnabledForRole(String role) {
    final rolePricing = role.toLowerCase() == 'bride' ? bride : groom;
    return rolePricing.enabled;
  }
}

class RolePricing {
  final int price; // in rupees
  final bool enabled;

  RolePricing({
    required this.price,
    required this.enabled,
  });

  factory RolePricing.fromJson(Map<String, dynamic> json) {
    return RolePricing(
      price: json['price'] ?? 0,
      enabled: json['enabled'] ?? true,
    );
  }
}

// Global settings instance (will be fetched from backend)
class AppSettingsService {
  static AppSettings _settings = AppSettings.defaultSettings();
  static bool _isLoading = false;

  static AppSettings get settings => _settings;
  static bool get isLoading => _isLoading;

  static void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
  }

  /// Fetch settings from backend
  static Future<void> fetchSettings() async {
    if (_isLoading) return;
    
    _isLoading = true;
    try {
      final settingsApi = SettingsApi();
      final response = await settingsApi.getAppSettings();
      
      if (response['success'] == true && response['settings'] != null) {
        _settings = AppSettings.fromJson(response['settings']);
      }
    } catch (e) {
      // Use default settings on error
      _settings = AppSettings.defaultSettings();
    } finally {
      _isLoading = false;
    }
  }

  // Check if payment is required
  static bool isPaymentRequired() {
    return _settings.paymentEnabled && !_settings.allowFreePosting;
  }

  // Check if payment is enabled
  static bool isPaymentEnabled() {
    return _settings.paymentEnabled;
  }

  // Get price for boost type and role
  static int getPrice(String boostType, String role) {
    return _settings.boostPricing.getPrice(role, boostType);
  }

  // Get duration for boost type
  static int getDuration(String boostType) {
    return _settings.boostPricing.getDuration(boostType);
  }

  // Format price
  static String formatPrice(int price) {
    if (price == 0) return 'Free';
    return '₹$price';
  }

  // Get duration string
  static String getDurationString(String boostType) {
    final days = getDuration(boostType);
    return '$days ${days == 1 ? 'day' : 'days'}';
  }
}
