import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/profile_api.dart';
import '../../core/pricing_config.dart';
import '../../core/payment_api.dart';
import 'invoice_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  static const routeName = '/payment';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _profileApi = ProfileApi();
  final _paymentApi = PaymentApi();
  final promoCodeController = TextEditingController();
  bool hasPromoCode = false;
  double discount = 0.0;
  bool _isLoading = false;
  bool _isActivatingFree = false;
  bool _isValidatingPromo = false;
  bool _isProcessing = false;
  String? _selectedPaymentMethod;
  String? _errorMessage;

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = 'Google Pay'; // Default selection
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boostType = args?['boostType'] as String? ?? 'standard';
    final role = args?['role'] as String? ?? 'groom';
    
    // Get pricing from app settings
    final paymentEnabled = AppSettingsService.isPaymentEnabled();
    final paymentRequired = AppSettingsService.isPaymentRequired();
    
    // Determine plan details
    String planTitle;
    String duration;
    int priceAmount;
    List<String> features;
    
    if (boostType == 'featured') {
      planTitle = 'Featured boost';
      duration = AppSettingsService.getDurationString('featured');
      priceAmount = AppSettingsService.getPrice('featured', role);
      features = [
        'Top placement in search',
        'Featured badge on profile',
        'Priority in all filters',
        'Maximum visibility',
        'Valid for ${AppSettingsService.getDuration('featured')} days',
      ];
    } else {
      planTitle = 'Standard boost';
      duration = AppSettingsService.getDurationString('standard');
      priceAmount = AppSettingsService.getPrice('standard', role);
      features = [
        'Higher visibility in search',
        'Standard badge on profile',
        'Appears in top results',
        'Valid for ${AppSettingsService.getDuration('standard')} days',
      ];
    }
    
    // If payment not required, show free option
    if (!paymentRequired || priceAmount == 0) {
      priceAmount = 0;
    }

    final finalAmount = priceAmount.toDouble() - discount;
    final gstAmount = finalAmount * 0.18;
    final totalAmount = finalAmount + gstAmount;

    final theme = Theme.of(context);
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
            
            // Plan card - Light grey background (matching image)
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
                          Text(
                            planTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            duration,
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
                  ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF212121),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Promo code section (optional)
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
            // Only show payment methods if payment is required
            if (paymentRequired && finalAmount > 0) ...[
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
            ],
            
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
                  _buildPriceRow('Plan price', '₹${priceAmount}', isStriked: hasPromoCode),
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
                      : () => _handlePayment(boostType, role, planTitle, priceAmount.toDouble(), finalAmount, totalAmount),
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
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isActivatingFree ? null : () => _activateFreeBoost(boostType, role),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isActivatingFree
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Activate for Free',
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
                '🔒 Secure payment • Your profile goes live immediately',
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boostType = args?['boostType'] as String? ?? 'standard';
    final role = args?['role'] as String? ?? 'groom';
    
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
        boostType: boostType,
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

  Future<void> _handlePayment(
    String boostType,
    String role,
    String planTitle,
    double originalAmount,
    double finalAmount,
    double totalAmount,
  ) async {
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
      final gstAmount = finalAmount * 0.18;
      
      // Navigate to invoice screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          InvoiceScreen.routeName,
          arguments: {
            'userName': 'User',
            'planName': planTitle,
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

  Future<void> _activateFreeBoost(String boostType, String role) async {
    setState(() {
      _isActivatingFree = true;
      _errorMessage = null;
    });

    try {
      final response = await _profileApi.activateBoost(
        boostType: boostType,
        isFree: true,
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile boosted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to previous screen
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to activate boost';
          _isActivatingFree = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'Failed to activate boost'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isActivatingFree = false;
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
