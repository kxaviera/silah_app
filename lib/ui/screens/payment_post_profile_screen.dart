import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/profile_api.dart';
import '../../core/pricing_config.dart';
import '../../core/payment_api.dart';
import '../shell/app_shell.dart';
import 'invoice_screen.dart';

class PaymentPostProfileScreen extends StatefulWidget {
  const PaymentPostProfileScreen({super.key});
  static const routeName = '/payment-post-profile';

  @override
  State<PaymentPostProfileScreen> createState() => _PaymentPostProfileScreenState();
}

class _PaymentPostProfileScreenState extends State<PaymentPostProfileScreen> {
  final _profileApi = ProfileApi();
  final _paymentApi = PaymentApi();
  final promoCodeController = TextEditingController();
  bool hasPromoCode = false;
  late double originalAmount;
  double discount = 0.0;
  late double finalAmount;
  bool _isActivatingFree = false;
  bool _isValidatingPromo = false;
  bool _isProcessing = false;
  String? _selectedPaymentMethod;

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    originalAmount = 299.0;
    finalAmount = 299.0;
    _selectedPaymentMethod = 'Google Pay'; // Default selection
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'groom';
    
    // Check if payment is enabled
    final paymentEnabled = AppSettingsService.isPaymentEnabled();
    final paymentRequired = AppSettingsService.isPaymentRequired();
    
    // Update amounts based on role and settings
    if (paymentEnabled) {
      originalAmount = AppSettingsService.getPrice('standard', role).toDouble();
    } else {
      originalAmount = 0.0; // Free when payment disabled
    }
    finalAmount = originalAmount - discount;
    final gstAmount = finalAmount * 0.18;
    final totalAmount = finalAmount + gstAmount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF212121)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complete payment section
            const Text(
              'Complete payment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your profile will be boosted immediately after payment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            
            // Plan card - Light grey background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5), // Light grey
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Standard Post',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PricingConfig.getDurationString('standard'),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        finalAmount > 0
                            ? '₹${finalAmount.toInt()}'
                            : 'Free',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(
                    icon: Icons.check_circle,
                    text: 'Profile goes live immediately',
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.check_circle,
                    text: 'Visible in search results',
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.check_circle,
                    text: 'Higher visibility and responses',
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.check_circle,
                    text: 'Valid for ${PricingConfig.getDurationString('standard')}',
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Promo code section (optional, can be collapsed)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 18, color: Color(0xFF757575)),
                      const SizedBox(width: 8),
                      const Text(
                        'Promo code (optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: promoCodeController,
                          style: const TextStyle(color: Color(0xFF212121), fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter code',
                            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _isValidatingPromo ? null : _validatePromoCode,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isValidatingPromo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                  if (hasPromoCode) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Promo code applied: ₹${discount.toInt()} discount',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Payment methods section
            const Text(
              'Payment methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment method cards
            _buildPaymentMethodCard(
              context,
              'Google Pay',
              Icons.account_balance_wallet,
              const Color(0xFF4285F4), // Google blue
              'Google Pay',
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              context,
              'PhonePe',
              Icons.phone_android,
              const Color(0xFF5F259F), // PhonePe purple
              'PhonePe',
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              context,
              'Paytm',
              Icons.payment,
              const Color(0xFF00BAF2), // Paytm blue
              'Paytm',
            ),
            const SizedBox(height: 32),
            
            // Price breakdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Plan price', '₹${originalAmount.toInt()}', isStriked: hasPromoCode),
                  if (hasPromoCode) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow('Discount', '-₹${discount.toInt()}', isGreen: true),
                  ],
                  const SizedBox(height: 12),
                  _buildPriceRow('Subtotal', '₹${finalAmount.toInt()}'),
                  const SizedBox(height: 8),
                  _buildPriceRow('GST (18%)', '₹${gstAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      Text(
                        '₹${totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Payment button
            if (paymentRequired && finalAmount > 0) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing || _selectedPaymentMethod == null
                      ? null
                      : () => _handlePayment(role, totalAmount),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Pay ₹${totalAmount.toStringAsFixed(0)} & Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : () => _handlePayLater(role),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: theme.colorScheme.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pay Later - Explore First',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _activateFreeBoostAndNavigate(role),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Post Profile for Free',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: Text(
                '🔒 Secure payment • Profile goes live immediately',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF212121),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    String name,
    IconData icon,
    Color iconColor,
    String value,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212121),
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (val) {
                setState(() {
                  _selectedPaymentMethod = val;
                });
              },
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isStriked = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isGreen ? Theme.of(context).colorScheme.primary : const Color(0xFF757575),
            decoration: isStriked ? TextDecoration.lineThrough : null,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            color: isGreen ? Theme.of(context).colorScheme.primary : const Color(0xFF212121),
            fontWeight: isGreen ? FontWeight.w600 : FontWeight.w500,
            decoration: isStriked ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Future<void> _validatePromoCode() async {
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'groom';
    final code = promoCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a promo code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isValidatingPromo = true;
    });
    
    try {
      final response = await _paymentApi.validatePromoCode(
        promoCode: code,
        boostType: 'standard',
        role: role,
      );
      
      if (response['success'] == true) {
        final discountAmount = (response['discount'] as num?)?.toDouble() ?? 0.0;
        setState(() {
          hasPromoCode = true;
          discount = discountAmount;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Promo code applied! ₹${discount.toInt()} off'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Invalid promo code'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to validate promo code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidatingPromo = false;
        });
      }
    }
  }

  Future<void> _handlePayment(String role, double totalAmount) async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final subtotal = finalAmount;
      final gstAmount = subtotal * 0.18;
      
      // Navigate to invoice screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          InvoiceScreen.routeName,
          arguments: {
            'userName': 'User',
            'planName': 'Standard Post',
            'originalAmount': originalAmount,
            'gstAmount': gstAmount,
            'totalAmount': totalAmount,
            'discount': discount,
            'paymentMethod': _selectedPaymentMethod ?? 'Google Pay',
            'promoCode': hasPromoCode ? promoCodeController.text.trim().toUpperCase() : null,
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handlePayLater(String role) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Pay Later',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'You can explore the platform first. Your profile will be visible but with limited features. You can boost your profile anytime from the Profile section.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Navigate to home without payment
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppShell.routeName,
          arguments: role,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _activateFreeBoostAndNavigate(String role) async {
    setState(() {
      _isActivatingFree = true;
      _isProcessing = true;
    });

    try {
      final response = await _profileApi.activateBoost(
        boostType: 'standard',
        isFree: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppShell.routeName,
            arguments: role,
          );
        }
      } else {
        setState(() {
          _isActivatingFree = false;
          _isProcessing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to activate boost'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isActivatingFree = false;
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
