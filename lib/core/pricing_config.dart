// Pricing configuration for different roles and boost types
class PricingConfig {
  // Standard boost pricing (3 days)
  static const Map<String, int> standardBoostPrice = {
    'bride': 199, // ₹199 for brides
    'groom': 299, // ₹299 for grooms
  };

  // Featured boost pricing (7 days)
  static const Map<String, int> featuredBoostPrice = {
    'bride': 399, // ₹399 for brides
    'groom': 599, // ₹599 for grooms
  };

  // Get standard boost price for a role
  static int getStandardPrice(String role) {
    return standardBoostPrice[role.toLowerCase()] ?? standardBoostPrice['groom']!;
  }

  // Get featured boost price for a role
  static int getFeaturedPrice(String role) {
    return featuredBoostPrice[role.toLowerCase()] ?? featuredBoostPrice['groom']!;
  }

  // Get price for boost type and role
  static int getPrice(String boostType, String role) {
    if (boostType == 'featured') {
      return getFeaturedPrice(role);
    }
    return getStandardPrice(role);
  }

  // Format price as currency string
  static String formatPrice(int price) {
    return '₹$price';
  }

  // Get duration for boost type
  static int getDuration(String boostType) {
    return boostType == 'featured' ? 7 : 3;
  }

  // Get duration string
  static String getDurationString(String boostType) {
    final days = getDuration(boostType);
    return '$days ${days == 1 ? 'day' : 'days'}';
  }
}
