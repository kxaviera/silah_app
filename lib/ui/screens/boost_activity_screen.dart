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
            'Boost Activity',
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
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Boost Activity',
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
              // Boost Status Card - Enhanced Professional Design
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: isBoostActive
                      ? LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.shade100,
                            Colors.grey.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isBoostActive
                          ? theme.colorScheme.primary.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: isBoostActive
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: isBoostActive
                                ? Border.all(color: Colors.white.withOpacity(0.4), width: 2.5)
                                : Border.all(color: Colors.grey.shade300, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: isBoostActive
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isBoostActive ? Icons.check_circle : Icons.timer_off_rounded,
                            color: isBoostActive ? Colors.white : Colors.grey.shade600,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isBoostActive ? 'Profile Live' : 'Profile Inactive',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isBoostActive ? Colors.white : Colors.black87,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isBoostActive
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                      border: isBoostActive
                                          ? Border.all(color: Colors.white.withOpacity(0.4), width: 1)
                                          : null,
                                    ),
                                    child: Text(
                                      boostType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isBoostActive ? Colors.white : Colors.grey.shade700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (isBoostActive && boostStartsAt != null && boostExpiresAt != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_formatDate(boostStartsAt)} - ${_formatDate(boostExpiresAt)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.95),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                              ],
                              Row(
                                children: [
                                  Icon(
                                    isBoostActive ? Icons.access_time : Icons.info_outline,
                                    size: 14,
                                    color: isBoostActive
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBoostActive
                                        ? '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} remaining'
                                        : 'Boost expired or not activated',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isBoostActive
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black54,
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
                              onPressed: () {
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
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              PaymentPostProfileScreen.routeName,
                              arguments: role,
                            ).then((_) {
                              _loadBoostData();
                            });
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
              
              // Stats Grid - Professional Cards
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
                      icon: Icons.favorite_outline,
                      label: 'Likes',
                      value: totalLikes.toString(),
                      color: Colors.red,
                      gradient: [Colors.red.shade50, Colors.red.shade100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context,
                      icon: Icons.bookmark_outline,
                      label: 'Shortlisted',
                      value: totalShortlisted.toString(),
                      color: Colors.orange,
                      gradient: [Colors.orange.shade50, Colors.orange.shade100],
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
                                  (view['name'] as String? ?? 'U')[0].toUpperCase(),
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
                                    view['name'] as String? ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    view['time'] as String? ?? 'Recently',
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
}
