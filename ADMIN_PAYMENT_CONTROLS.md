# Admin Payment Controls - Implementation Guide

## Overview
Admin has full control over pricing, boost validity, and payment options. Users can post for free when payment is disabled.

## Admin Controls

### 1. Payment Master Switch
**Endpoint:** `PUT /api/admin/settings/payment`

**Controls:**
- `paymentEnabled` (boolean): Master switch for payment system
  - `true`: Payment system is active (users must pay to boost)
  - `false`: Payment system is disabled (all boosts are free)

**Example:**
```json
{
  "paymentEnabled": false  // All boosts become free
}
```

### 2. Allow Free Posting
**Endpoint:** `PUT /api/admin/settings/payment`

**Controls:**
- `allowFreePosting` (boolean): Allow users to skip payment
  - Only applicable when `paymentEnabled: true`
  - `true`: Users can choose to skip payment and post for free
  - `false`: Payment is mandatory (no skip option)

**Example:**
```json
{
  "paymentEnabled": true,
  "allowFreePosting": true  // Users can skip payment
}
```

### 3. Boost Pricing Control
**Endpoint:** `PUT /api/admin/settings/boost-pricing`

**Controls per boost type and role:**
- `price` (number): Price in paise (₹199 = 19900)
- `duration` (number): Validity in days (3, 7, 14, etc.)
- `enabled` (boolean): Enable/disable this boost option for the role

**Example:**
```json
{
  "standard": {
    "bride": {
      "price": 19900,    // ₹199
      "duration": 3,     // 3 days
      "enabled": true    // Available for brides
    },
    "groom": {
      "price": 29900,    // ₹299
      "duration": 5,     // Changed to 5 days
      "enabled": true
    }
  },
  "featured": {
    "bride": {
      "price": 39900,
      "duration": 7,
      "enabled": false   // Disabled for brides
    },
    "groom": {
      "price": 59900,
      "duration": 10,    // Changed to 10 days
      "enabled": true
    }
  }
}
```

## User Experience Flow

### Scenario 1: Payment Disabled
```
Admin sets: paymentEnabled = false
User Experience:
- All boost options show "Free"
- No payment screen shown
- Profile activated immediately for free
- Boost duration still applies (3/7 days from settings)
```

### Scenario 2: Payment Enabled, Free Posting Allowed
```
Admin sets: paymentEnabled = true, allowFreePosting = true
User Experience:
- Boost options show prices
- Payment screen shown
- "Skip for now" button available
- User can choose to pay or skip
```

### Scenario 3: Payment Enabled, Free Posting Disabled
```
Admin sets: paymentEnabled = true, allowFreePosting = false
User Experience:
- Boost options show prices
- Payment screen shown
- No "Skip" button
- Payment is mandatory
```

### Scenario 4: Boost Option Disabled
```
Admin sets: featured.bride.enabled = false
User Experience:
- Featured boost option doesn't appear for brides
- Only Standard boost available
- Grooms still see Featured option (if enabled)
```

## Frontend Implementation

### 1. Fetch Settings on App Startup
```dart
// In main.dart or app initialization
Future<void> initApp() async {
  // Fetch app settings
  final response = await api.get('/api/settings');
  final settings = AppSettings.fromJson(response.data['settings']);
  AppSettingsService.updateSettings(settings);
}
```

### 2. Check Payment Status
```dart
// Before showing payment screen
if (!AppSettingsService.isPaymentRequired()) {
  // Activate boost for free
  await activateBoostForFree(boostType);
} else {
  // Show payment screen
  Navigator.pushNamed(context, PaymentScreen.routeName);
}
```

### 3. Update UI Based on Settings
```dart
// In boost options
final price = AppSettingsService.getPrice('standard', role);
final isEnabled = AppSettingsService.settings.boostPricing.standard.isEnabledForRole(role);

if (!isEnabled) {
  // Don't show this option
  return SizedBox.shrink();
}

// Show price or "Free"
Text(price > 0 ? '₹$price' : 'Free')
```

## Backend Implementation

### 1. Settings Model
```typescript
interface AppSettings {
  paymentEnabled: boolean;
  allowFreePosting: boolean;
  boostPricing: {
    standard: {
      bride: { price: number; duration: number; enabled: boolean };
      groom: { price: number; duration: number; enabled: boolean };
    };
    featured: {
      bride: { price: number; duration: number; enabled: boolean };
      groom: { price: number; duration: number; enabled: boolean };
    };
  };
}
```

### 2. Get Settings Endpoint
```typescript
// GET /api/settings (public)
app.get('/api/settings', async (req, res) => {
  const settings = await Settings.findOne();
  res.json({
    success: true,
    settings: {
      paymentEnabled: settings.paymentEnabled,
      allowFreePosting: settings.allowFreePosting,
      boostPricing: settings.boostPricing
    }
  });
});
```

### 3. Boost Activation Logic
```typescript
// When activating boost
async function activateBoost(userId, boostType, role) {
  const settings = await Settings.findOne();
  const pricing = settings.boostPricing[boostType][role];
  
  // Check if enabled
  if (!pricing.enabled) {
    throw new Error('Boost option not available');
  }
  
  // Check if payment required
  if (settings.paymentEnabled && pricing.price > 0) {
    // Require payment
    return { requiresPayment: true, amount: pricing.price };
  }
  
  // Free boost - activate directly
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + pricing.duration);
  
  await User.findByIdAndUpdate(userId, {
    boostStatus: 'active',
    boostType: boostType,
    boostExpiresAt: expiresAt
  });
  
  return { requiresPayment: false, activated: true };
}
```

## Admin Dashboard UI

### Settings Page Layout

```
┌─────────────────────────────────────┐
│ Payment Controls                    │
├─────────────────────────────────────┤
│ ☑ Payment Enabled                   │
│ ☐ Allow Free Posting                │
│                                     │
│ [Save Changes]                      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Standard Boost Pricing              │
├─────────────────────────────────────┤
│ Bride:                              │
│   Price: ₹[199]                     │
│   Duration: [3] days                │
│   ☑ Enabled                         │
│                                     │
│ Groom:                              │
│   Price: ₹[299]                     │
│   Duration: [3] days                │
│   ☑ Enabled                         │
│                                     │
│ [Save Changes]                      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Featured Boost Pricing              │
├─────────────────────────────────────┤
│ Bride:                              │
│   Price: ₹[399]                     │
│   Duration: [7] days                │
│   ☑ Enabled                         │
│                                     │
│ Groom:                              │
│   Price: ₹[599]                     │
│   Duration: [7] days                │
│   ☑ Enabled                         │
│                                     │
│ [Save Changes]                      │
└─────────────────────────────────────┘
```

## Use Cases

### Use Case 1: Launch with Free Posting
```
1. Admin sets paymentEnabled = false
2. All users can post for free
3. Boost duration still applies (3/7 days)
4. Later, admin enables payment
```

### Use Case 2: Promotional Period
```
1. Admin sets allowFreePosting = true
2. Users see prices but can skip
3. After promotion, set allowFreePosting = false
4. Payment becomes mandatory
```

### Use Case 3: Disable Boost Option
```
1. Admin sets featured.bride.enabled = false
2. Brides no longer see Featured option
3. Only Standard boost available for brides
4. Grooms still see both options
```

### Use Case 4: Change Pricing
```
1. Admin updates standard.groom.price = 24900 (₹249)
2. Settings updated immediately
3. Frontend fetches new settings
4. New users see updated price
```

## Testing Checklist

- [ ] Payment disabled → All boosts free
- [ ] Payment enabled, free posting allowed → Skip button visible
- [ ] Payment enabled, free posting disabled → No skip button
- [ ] Boost option disabled → Not shown in UI
- [ ] Price change → Reflected in UI immediately
- [ ] Duration change → Applied to new boosts
- [ ] Role-specific pricing → Correct prices shown per role
- [ ] Free boost activation → No payment required
- [ ] Paid boost activation → Payment flow works

---

**Last Updated:** 2024-01-15
