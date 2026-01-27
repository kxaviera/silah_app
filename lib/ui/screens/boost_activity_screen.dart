import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/profile_api.dart';
import '../../core/auth_api.dart';
import 'payment_post_profile_screen.dart';
import 'payment_screen.dart';

class BoostActivityScreen extends StatefulWidget {
  const BoostActivityScreen({super.key});
  static const routeName = '/boost-activity';

  @override
  State<BoostActivityScreen> createState() => _BoostActivityScreenState();
}

class _BoostActivityScreenState extends State<BoostActivityScreen> {
  final _profileApi = ProfileApi();
  final _authApi = AuthApi();
  bool _isLoading = true;
  Map<String, dynamic>? _boostData;
  Map<String, dynamic>? _analyticsData;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadBoostData();
  }

  Future<void> _loadBoostData() async {
    try {
      // Get boost status
      final boostResponse = await _profileApi.getBoostStatus();
      if (boostResponse['success'] == true) {
        setState(() {
          _boostData = boostResponse['boost'] as Map<String, dynamic>?;
        });
      }
      
      // Get analytics
      final analyticsResponse = await _profileApi.getAnalytics();
      if (analyticsResponse['success'] == true) {
        setState(() {
          _analyticsData = analyticsResponse['analytics'] as Map<String, dynamic>?;
        });
      }
      
      // Get user role from profile
      try {
        final userResponse = await _authApi.getMe();
        if (userResponse['success'] == true) {
          final userId = userResponse['user']?['_id'] ?? userResponse['user']?['id'];
          if (userId != null) {
            final profileResponse = await _profileApi.getProfile(userId);
            if (profileResponse['success'] == true) {
              final profile = profileResponse['profile'] as Map<String, dynamic>?;
              setState(() {
                _userRole = profile?['role'] as String? ?? 'groom';
              });
            } else {
              // Fallback to user data
              final user = userResponse['user'] as Map<String, dynamic>?;
              setState(() {
                _userRole = user?['role'] as String? ?? 'groom';
              });
            }
          } else {
            setState(() {
              _userRole = 'groom';
            });
          }
        } else {
          setState(() {
            _userRole = 'groom';
          });
        }
      } catch (e) {
        // Default to groom if can't fetch
        setState(() {
          _userRole = 'groom';
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _userRole = 'groom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final role = args as String? ?? _userRole ?? 'groom';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Profile Activity',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final boostStatus = _boostData?['status'] as String? ?? 'Expired';
    final boostType = _boostData?['type'] as String? ?? 'Standard';
    final boostStartsAt = _boostData?['startsAt'] != null 
        ? DateTime.parse(_boostData!['startsAt'] as String)
        : null;
    final boostExpiresAt = _boostData?['expiresAt'] != null 
        ? DateTime.parse(_boostData!['expiresAt'] as String)
        : null;
    final daysLeft = boostExpiresAt != null 
        ? boostExpiresAt.difference(DateTime.now()).inDays
        : 0;
    final isFeatured = boostType.toLowerCase() == 'featured';
    final totalViews = _analyticsData?['totalViews'] as int? ?? 0;
    final totalLikes = _analyticsData?['totalLikes'] as int? ?? 0;
    final totalShortlisted = _analyticsData?['totalShortlisted'] as int? ?? 0;
    final totalRequests = _analyticsData?['totalRequests'] as int? ?? 0;
    final recentViews = _analyticsData?['recentViews'] as List<dynamic>? ?? [];

    final theme = Theme.of(context);
    final isBoostActive = boostStatus == 'Active' && daysLeft > 0;

    // Determine whether current boost is effectively free or paid
    final settings = AppSettingsService.settings;
    final isPaymentRequired = AppSettingsService.isPaymentRequired();
    final planPrice = AppSettingsService.getPrice(
      boostType.toLowerCase() == 'featured' ? 'featured' : 'standard',
      role,
    );
    final isFreeBoost = !isPaymentRequired || settings.allowFreePosting || planPrice == 0;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile Activity',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBoostData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Boost status card - clearer, with free/paid label
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isBoostActive
                        ? theme.colorScheme.primary.withOpacity(0.4)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isBoostActive
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isBoostActive ? Icons.rocket_launch : Icons.timer_off_rounded,
                            color: isBoostActive
                                ? theme.colorScheme.primary
                                : Colors.grey.shade600,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isBoostActive ? 'Profile live' : 'Profile inactive',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isBoostActive
                                          ? theme.colorScheme.primary.withOpacity(0.08)
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          boostType.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isBoostActive
                                                ? theme.colorScheme.primary
                                                : Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isFreeBoost ? 'Free boost' : 'Paid boost',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isBoostActive
                                    ? 'Your profile is currently visible to other members.'
                                    : 'Boost your profile to make it visible and start receiving requests.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (boostStartsAt != null && boostExpiresAt != null) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 14, color: Colors.black45),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_formatDate(boostStartsAt)} - ${_formatDate(boostExpiresAt)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                              ],
                              Row(
                                children: [
                                  Icon(
                                    isBoostActive ? Icons.access_time : Icons.info_outline,
                                    size: 14,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBoostActive
                                        ? '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} remaining'
                                        : 'Boost expired or not activated',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isBoostActive && !isFeatured) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Upgrade to Featured',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Get top placement and maximum visibility',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () async {
                                try {
                                  await AppSettingsService.fetchSettings();
                                } catch (_) {}
                                final paymentEnabled = AppSettingsService.isPaymentEnabled();
                                final payRequired = AppSettingsService.isPaymentRequired();
                                final price = AppSettingsService.getPrice('featured', role);
                                if (paymentEnabled && payRequired && price > 0) {
                                  Navigator.pushNamed(
                                    context,
                                    PaymentScreen.routeName,
                                    arguments: {
                                      'boostType': 'featured',
                                      'role': role,
                                      'isUpgrade': true,
                                    },
                                  ).then((_) {
                                    _loadBoostData();
                                  });
                                } else {
                                  final res = await _profileApi.activateBoost(
                                    boostType: 'featured',
                                    isFree: true,
                                  );
                                  if (!mounted) return;
                                  if (res['success'] == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Upgraded to Featured! Profile is live.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _loadBoostData();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(res['message'] as String? ?? 'Failed to upgrade'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Upgrade',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!isBoostActive) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await AppSettingsService.fetchSettings();
                            } catch (_) {}
                            final paymentEnabled = AppSettingsService.isPaymentEnabled();
                            final payRequired = AppSettingsService.isPaymentRequired();
                            final price = AppSettingsService.getPrice('standard', role);
                            if (paymentEnabled && payRequired && price > 0) {
                              Navigator.pushNamed(
                                context,
                                PaymentPostProfileScreen.routeName,
                                arguments: role,
                              ).then((_) {
                                _loadBoostData();
                              });
                            } else {
                              final res = await _profileApi.activateBoost(
                                boostType: 'standard',
                                isFree: true,
                              );
                              if (!mounted) return;
                              if (res['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile boosted! Your profile is now live.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _loadBoostData();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] as String? ?? 'Failed to boost'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.rocket_launch, size: 22),
                          label: const Text(
                            'Activate Boost Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Analytics Section Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Performance',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 22,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your profile engagement and visibility',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Grid - implemented metrics only
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      icon: Icons.visibility_outlined,
                      label: 'Profile Views',
                      value: totalViews.toString(),
                      color: Colors.blue,
                      gradient: [Colors.blue.shade50, Colors.blue.shade100],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context,
                      icon: Icons.inbox_outlined,
                      label: 'Contact Requests',
                      value: totalRequests.toString(),
                      color: Colors.purple,
                      gradient: [Colors.purple.shade50, Colors.purple.shade100],
                    ),
                  ),
                ],
              ),
              
              if (recentViews.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Profile Views',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // View all
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: recentViews.take(5).map((view) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade100,
                              width: recentViews.indexOf(view) < recentViews.length - 1 ? 1 : 0,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.2),
                                    theme.colorScheme.primary.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  ((view['viewerName'] as String? ?? 'User')
                                          .trim()
                                          .isNotEmpty
                                      ? (view['viewerName'] as String).trim()[0].toUpperCase()
                                      : 'U'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (view['viewerName'] as String? ?? 'Unknown'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatViewTime(view['viewedAt']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatViewTime(dynamic dateTime) {
    DateTime dt;
    if (dateTime is String) {
      dt = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      dt = dateTime;
    } else {
      return 'Recently';
    }

    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}
