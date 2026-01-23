import 'package:flutter/material.dart';

import '../../core/app_data.dart';
import '../../core/profile_api.dart';
import '../../core/auth_api.dart';
import '../../core/app_settings.dart';
import '../widgets/profile_ad_card.dart';
import 'payment_screen.dart';
import 'payment_post_profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final String role; // 'bride' or 'groom'
  const DiscoverScreen({super.key, required this.role});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _profileApi = ProfileApi();
  final _authApi = AuthApi();
  final _searchController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;
  String? _selectedReligion;
  bool _onlyNRIs = false;
  bool _onlyInIndia = false;
  String? _selectedLivingCountry;
  int? _minAge;
  int? _maxAge;
  int? _minHeight;
  
  List<ProfileAd> _profiles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _errorMessage;
  
  String _currentTab = 'All'; // 'All', 'India', 'Abroad'
  String? _userCity; // User's city for prioritization
  
  // Boost status
  bool _isProfileBoosted = false;
  bool _isCheckingBoost = false;
  bool _isActivatingBoost = false;
  Map<String, dynamic>? _boostStatusData; // Store full boost status

  @override
  void initState() {
    super.initState();
    _checkBoostStatus();
    _loadProfiles();
    _fetchUserCity();
    
    // Debounce search
    _searchController.addListener(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _searchController.text == _searchController.text) {
          _loadProfiles(refresh: true);
        }
      });
    });
  }


  Future<void> _fetchUserCity() async {
    try {
      final userResponse = await _authApi.getMe();
      if (userResponse['success'] == true && mounted) {
        final user = userResponse['user'] as Map<String, dynamic>;
        final city = user['city'] as String?;
        if (mounted) {
          setState(() {
            _userCity = city;
          });
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _checkBoostStatus() async {
    setState(() {
      _isCheckingBoost = true;
    });

    try {
      // Get boost status from API
      final boostResponse = await _profileApi.getBoostStatus();
      if (boostResponse['success'] == true && mounted) {
        final boost = boostResponse['boost'] as Map<String, dynamic>?;
        final boostStatus = boost?['status'] as String? ?? 'none';
        final boostExpiresAt = boost?['expiresAt'] as String?;
        
        bool isActive = false;
        if (boostStatus == 'Active' && boostExpiresAt != null) {
          try {
            final expiresAt = DateTime.parse(boostExpiresAt);
            isActive = expiresAt.isAfter(DateTime.now());
          } catch (e) {
            // Invalid date format
            isActive = boostStatus == 'Active';
          }
        }

        if (mounted) {
          setState(() {
            _isProfileBoosted = isActive;
            _boostStatusData = boost;
            _isCheckingBoost = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isProfileBoosted = false;
            _boostStatusData = null;
            _isCheckingBoost = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProfileBoosted = false;
          _boostStatusData = null;
          _isCheckingBoost = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lookingFor = widget.role == 'bride' ? 'groom' : 'bride';

    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 8),
        // Boost Profile Banner - Show always (different content based on status)
        if (!_isCheckingBoost) ...[
          _buildBoostBanner(context, theme),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search by name, city or profession',
              hintStyle: TextStyle(color: Colors.black38),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) {
              // Search will trigger via listener
            },
            onSubmitted: (_) => _loadProfiles(refresh: true),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _TopTabs(
                  lookingFor: lookingFor,
                  onTabChanged: (index) {
                    setState(() {
                      if (index == 1) {
                        _currentTab = 'India';
                        _onlyInIndia = true;
                        _onlyNRIs = false;
                      } else if (index == 2) {
                        _currentTab = 'Abroad';
                        _onlyNRIs = true;
                        _onlyInIndia = false;
                      } else {
                        _currentTab = 'All';
                        _onlyNRIs = false;
                        _onlyInIndia = false;
                      }
                    });
                    _loadProfiles(refresh: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showAdvancedFilters(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getActiveFiltersCount() > 0
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                      width: _getActiveFiltersCount() > 0 ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune,
                        size: 20,
                        color: _getActiveFiltersCount() > 0
                            ? theme.colorScheme.primary
                            : Colors.black54,
                      ),
                      if (_getActiveFiltersCount() > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_getActiveFiltersCount()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading && _profiles.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _errorMessage != null && _profiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading profiles',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadProfiles(refresh: true),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _profiles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No profiles found',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollEndNotification &&
                                notification.metrics.pixels >=
                                    notification.metrics.maxScrollExtent * 0.8) {
                              if (_hasMore && !_isLoadingMore) {
                                setState(() {
                                  _currentPage++;
                                });
                                _loadProfiles();
                              }
                            }
                            return false;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (_, i) {
                              if (i == _profiles.length) {
                                return _isLoadingMore
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                              return ProfileAdCard(ad: _profiles[i]);
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: _profiles.length + (_hasMore ? 1 : 0),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildBoostBanner(BuildContext context, ThemeData theme) {
    final userRole = widget.role;
    final settings = AppSettingsService.settings;
    final isPaymentRequired = AppSettingsService.isPaymentRequired();
    final standardPrice = AppSettingsService.getPrice('standard', userRole);
    final featuredPrice = AppSettingsService.getPrice('featured', userRole);
    final canBoostFree = !isPaymentRequired || settings.allowFreePosting;
    final standardEnabled = settings.boostPricing.standard.isEnabledForRole(userRole);
    final featuredEnabled = settings.boostPricing.featured.isEnabledForRole(userRole);

    // If profile is boosted, show live status banner
    if (_isProfileBoosted && _boostStatusData != null) {
      final boostType = _boostStatusData!['type'] as String? ?? 'Standard';
      final startsAt = _boostStatusData!['startsAt'] != null
          ? DateTime.parse(_boostStatusData!['startsAt'] as String)
          : null;
      final expiresAt = _boostStatusData!['expiresAt'] != null
          ? DateTime.parse(_boostStatusData!['expiresAt'] as String)
          : null;
      final isFeatured = boostType.toLowerCase() == 'featured';
      final daysLeft = expiresAt != null
          ? expiresAt.difference(DateTime.now()).inDays
          : 0;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Profile Live',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              boostType.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (startsAt != null && expiresAt != null)
                        Text(
                          'Valid: ${_formatDate(startsAt)} - ${_formatDate(expiresAt)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (daysLeft > 0)
                        Text(
                          '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} remaining',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Upgrade to Featured button (if not already featured)
            if (!isFeatured && featuredEnabled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      PaymentScreen.routeName,
                      arguments: {
                        'boostType': 'featured',
                        'role': userRole,
                        'isUpgrade': true,
                      },
                    ).then((_) {
                      _checkBoostStatus();
                    });
                  },
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: Text(
                    'Upgrade to Featured (₹$featuredPrice)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            // View Activity button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/boost-activity',
                    arguments: userRole,
                  );
                },
                icon: const Icon(Icons.analytics_outlined, size: 18),
                label: const Text(
                  'View Activity & Analytics',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Profile not boosted - show boost prompt
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Boost Your Profile to Go Live!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your profile is not visible to others yet. Boost it now to get responses and find your perfect match!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick Boost Buttons
          Row(
            children: [
              // Quick Boost Free Button (if available)
              if (canBoostFree && standardEnabled)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isActivatingBoost
                        ? null
                        : () => _quickBoost(context, 'standard', userRole),
                    icon: _isActivatingBoost
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.flash_on, size: 18),
                    label: Text(
                      _isActivatingBoost
                          ? 'Activating...'
                          : canBoostFree
                              ? 'Boost Free'
                              : 'Boost Now',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              if (canBoostFree && standardEnabled) const SizedBox(width: 12),
              // Boost Now Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isActivatingBoost
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            PaymentPostProfileScreen.routeName,
                            arguments: widget.role,
                          ).then((_) {
                            _checkBoostStatus();
                          });
                        },
                  icon: const Icon(Icons.rocket_launch, size: 18),
                  label: const Text(
                    'Boost Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _quickBoost(BuildContext context, String boostType, String role) async {
    final settings = AppSettingsService.settings;
    final isPaymentRequired = AppSettingsService.isPaymentRequired();
    final price = AppSettingsService.getPrice(boostType, role);

    // Check if payment is required
    if (isPaymentRequired && price > 0 && !settings.allowFreePosting) {
      // Payment required - navigate to payment screen
      Navigator.pushNamed(
        context,
        PaymentScreen.routeName,
        arguments: {
          'boostType': boostType,
          'role': role,
        },
      ).then((_) {
        _checkBoostStatus();
      });
      return;
    }

    // Free boost available - activate directly
    setState(() {
      _isActivatingBoost = true;
    });

    try {
      final response = await _profileApi.activateBoost(
        boostType: boostType,
        isFree: true,
      );

      if (response['success'] == true && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile boosted successfully! Your profile is now live.'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Refresh boost status
        await _checkBoostStatus();
      } else {
        // Show error
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActivatingBoost = false;
        });
      }
    }
  }

  Future<void> _loadProfiles({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _profiles = [];
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // Determine country filter based on tab
      String? countryFilter;
      if (_currentTab == 'India') {
        countryFilter = 'India';
      }

      final response = await _profileApi.searchProfiles(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        country: countryFilter ?? (_selectedState != null ? null : 'India'), // Default to India if no state selected
        state: _selectedState,
        city: _selectedCity,
        religion: _selectedReligion,
        livingCountry: _selectedLivingCountry,
        onlyNRIs: _onlyNRIs,
        onlyInIndia: _onlyInIndia,
        minAge: _minAge,
        maxAge: _maxAge,
        minHeight: _minHeight,
        prioritizeByCity: _userCity, // Prioritize by user's city
        page: _currentPage,
        limit: 20,
      );

      if (response['success'] == true) {
        final profiles = (response['profiles'] as List)
            .map((p) => ProfileAd.fromMap(p))
            .toList();

        setState(() {
          if (refresh) {
            _profiles = profiles;
          } else {
            _profiles.addAll(profiles);
          }
          _hasMore = profiles.length == 20;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load profiles';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_onlyNRIs) count++;
    if (_onlyInIndia) count++;
    if (_selectedState != null) count++;
    if (_selectedCity != null) count++;
    if (_selectedReligion != null) count++;
    if (_selectedLivingCountry != null) count++;
    if (_minAge != null || _maxAge != null) count++;
    if (_minHeight != null) count++;
    return count;
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AdvancedFiltersSheet(
        selectedState: _selectedState,
        selectedCity: _selectedCity,
        selectedReligion: _selectedReligion,
        onlyNRIs: _onlyNRIs,
        onlyInIndia: _onlyInIndia,
        selectedLivingCountry: _selectedLivingCountry,
        minAge: _minAge,
        maxAge: _maxAge,
        minHeight: _minHeight,
        onApply: (filters) {
          setState(() {
            _selectedState = filters['state'];
            _selectedCity = filters['city'];
            _selectedReligion = filters['religion'];
            _onlyNRIs = filters['onlyNRIs'] ?? false;
            _onlyInIndia = filters['onlyInIndia'] ?? false;
            _selectedLivingCountry = filters['livingCountry'];
            _minAge = filters['minAge'];
            _maxAge = filters['maxAge'];
            _minHeight = filters['minHeight'];
          });
          Navigator.pop(context);
          _loadProfiles(refresh: true);
        },
        onReset: () {
          setState(() {
            _selectedState = null;
            _selectedCity = null;
            _selectedReligion = null;
            _onlyNRIs = false;
            _onlyInIndia = false;
            _selectedLivingCountry = null;
            _minAge = null;
            _maxAge = null;
            _minHeight = null;
          });
          Navigator.pop(context);
          _loadProfiles(refresh: true);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TopTabs extends StatefulWidget {
  final String lookingFor;
  final Function(int) onTabChanged;
  const _TopTabs({required this.lookingFor, required this.onTabChanged});

  @override
  State<_TopTabs> createState() => _TopTabsState();
}

class _TopTabsState extends State<_TopTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titles = [
      'All',
      'India',
      'Abroad',
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(titles.length, (i) {
          final selected = _index == i;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => _index = i);
                widget.onTabChanged(i);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    titles[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? theme.colorScheme.primary
                          : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AdvancedFiltersSheet extends StatefulWidget {
  final String? selectedState;
  final String? selectedCity;
  final String? selectedReligion;
  final bool onlyNRIs;
  final bool onlyInIndia;
  final String? selectedLivingCountry;
  final int? minAge;
  final int? maxAge;
  final int? minHeight;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onReset;

  const _AdvancedFiltersSheet({
    required this.selectedState,
    required this.selectedCity,
    required this.selectedReligion,
    required this.onlyNRIs,
    required this.onlyInIndia,
    required this.selectedLivingCountry,
    required this.minAge,
    required this.maxAge,
    required this.minHeight,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  late String? _state;
  late String? _city;
  late String? _religion;
  late bool _onlyNRIs;
  late bool _onlyInIndia;
  late String? _livingCountry;
  late int? _minAge;
  late int? _maxAge;
  late int? _minHeight;

  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _minHeightController = TextEditingController();

  Widget _buildFilterDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    String? hint,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        style: const TextStyle(
          color: Color(0xFF212121),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF757575), size: 22),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                displayText(item),
                style: const TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        hint: hint != null
            ? Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 15,
                ),
              )
            : null,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        iconSize: 24,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        menuMaxHeight: 300,
        isExpanded: true,
        isDense: false,
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Text(
                displayText(item),
                style: TextStyle(
                  color: value == item
                      ? theme.colorScheme.primary
                      : const Color(0xFF212121),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _state = widget.selectedState;
    _city = widget.selectedCity;
    _religion = widget.selectedReligion;
    _onlyNRIs = widget.onlyNRIs;
    _onlyInIndia = widget.onlyInIndia;
    _livingCountry = widget.selectedLivingCountry;
    _minAge = widget.minAge;
    _maxAge = widget.maxAge;
    _minHeight = widget.minHeight;
    _minAgeController.text = widget.minAge?.toString() ?? '';
    _maxAgeController.text = widget.maxAge?.toString() ?? '';
    _minHeightController.text = widget.minHeight?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location filters
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildFilterDropdown<String?>(
                      label: 'State (India)',
                      icon: Icons.map_outlined,
                      value: _state,
                      items: <String?>[null, ...AppData.indianStates],
                      displayText: (value) => value ?? 'All states',
                      hint: 'Select state',
                      onChanged: (value) {
                        setState(() {
                          _state = value;
                          _city = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilterDropdown<String?>(
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      value: _city,
                      items: <String?>[null, ...AppData.getCitiesForState(_state)],
                      displayText: (value) => value ?? 'All cities',
                      hint: _state == null ? 'Select state first' : 'Select city',
                      onChanged: (value) => setState(() => _city = value),
                    ),
                    const SizedBox(height: 24),
                    
                    // NRI / India toggle
                    Text(
                      'Profile Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Only NRIs (Living abroad)'),
                      subtitle: const Text('Show profiles of people working/living outside India'),
                      value: _onlyNRIs,
                      onChanged: (v) {
                        setState(() {
                          _onlyNRIs = v;
                          if (v) _onlyInIndia = false;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Only in India'),
                      subtitle: const Text('Show profiles of people living in India'),
                      value: _onlyInIndia,
                      onChanged: (v) {
                        setState(() {
                          _onlyInIndia = v;
                          if (v) _onlyNRIs = false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilterDropdown<String?>(
                      label: 'Living in (Country)',
                      icon: Icons.flag_outlined,
                      value: _livingCountry,
                      items: <String?>[null, ...AppData.countries],
                      displayText: (value) => value ?? 'All countries',
                      hint: 'Select country',
                      onChanged: (value) => setState(() => _livingCountry = value),
                    ),
                    const SizedBox(height: 24),
                    
                    // Religion
                    Text(
                      'Religion',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildFilterDropdown<String?>(
                      label: 'Religion',
                      icon: Icons.church_outlined,
                      value: _religion,
                      items: <String?>[null, ...AppData.religions],
                      displayText: (value) => value ?? 'All religions',
                      hint: 'Select religion',
                      onChanged: (value) => setState(() => _religion = value),
                    ),
                    const SizedBox(height: 24),
                    
                    // Age range
                    Text(
                      'Age Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minAgeController,
                            decoration: const InputDecoration(
                              labelText: 'Min age',
                              hintText: 'e.g. 25',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              _minAge = v.isEmpty ? null : int.tryParse(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxAgeController,
                            decoration: const InputDecoration(
                              labelText: 'Max age',
                              hintText: 'e.g. 35',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              _maxAge = v.isEmpty ? null : int.tryParse(v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Height
                    Text(
                      'Height',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _minHeightController,
                      decoration: const InputDecoration(
                        labelText: 'Minimum height (cm)',
                        hintText: 'e.g. 170',
                        prefixIcon: Icon(Icons.height_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        _minHeight = v.isEmpty ? null : int.tryParse(v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply({
                        'state': _state,
                        'city': _city,
                        'religion': _religion,
                        'onlyNRIs': _onlyNRIs,
                        'onlyInIndia': _onlyInIndia,
                        'livingCountry': _livingCountry,
                        'minAge': _minAge,
                        'maxAge': _maxAge,
                        'minHeight': _minHeight,
                      });
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileAd {
  final String id;
  final String name;
  final int age;
  final String country; // home or origin
  final String? livingCountry;
  final String? state;
  final String? city;
  final String religion;
  final String role; // 'bride' or 'groom'
  final bool featured;
  final bool sponsored;
  final bool isVerified; // Admin verification status
  final String? profession;
  final String? education;
  final int? height;

  ProfileAd({
    required this.id,
    required this.name,
    required this.age,
    required this.country,
    this.livingCountry,
    this.state,
    this.city,
    required this.religion,
    required this.role,
    this.featured = false,
    this.sponsored = false,
    this.isVerified = false,
    this.profession,
    this.education,
    this.height,
  });

  factory ProfileAd.fromMap(Map<String, dynamic> map) {
    return ProfileAd(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['fullName'] ?? map['name'] ?? '',
      age: map['age'] ?? 0,
      country: map['country'] ?? '',
      livingCountry: map['livingCountry'],
      state: map['state'],
      city: map['city'],
      religion: map['religion'] ?? '',
      role: map['role'] ?? '',
      featured: map['boostType'] == 'featured' || map['featured'] == true,
      sponsored: map['sponsored'] == true,
      isVerified: map['isVerified'] == true,
      profession: map['profession'],
      education: map['education'],
      height: map['height'],
    );
  }
}

// Mock data removed - using real API data from backend
