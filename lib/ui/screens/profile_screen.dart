import 'package:flutter/material.dart';

import '../../core/profile_api.dart';
import '../../core/auth_api.dart';
import '../../core/api_client.dart';
import 'boost_activity_screen.dart';
import 'payment_screen.dart';
import 'complete_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String role;
  const ProfileScreen({super.key, required this.role});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileApi = ProfileApi();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Track if we've already loaded data to avoid unnecessary refreshes
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if we haven't loaded yet or if explicitly requested
    if (!_hasLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasLoaded) {
          _loadUserData();
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user data
      final authApi = AuthApi();
      final userResponse = await authApi.getMe();
      if (userResponse['success'] == true) {
        final user = userResponse['user'] as Map<String, dynamic>;
        final userId = user['_id'] ?? user['id'];
        
        // Set initial data from getMe
        setState(() {
          _userData = {
            ...user,
            'name': user['fullName'] ?? user['name'] ?? 'User',
          };
        });
        
        if (userId != null) {
          // Get full profile data
          final profileResponse = await _profileApi.getProfile(userId.toString());
          if (profileResponse['success'] == true && profileResponse['profile'] != null) {
            final profile = profileResponse['profile'] as Map<String, dynamic>;
            setState(() {
              _userData = {
                ...profile,
                'name': profile['fullName'] ?? profile['name'] ?? user['fullName'] ?? 'User',
              };
              _isLoading = false;
              _hasLoaded = true;
            });
          } else {
            // Use user data from getMe
            setState(() {
              _isLoading = false;
              _hasLoaded = true;
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _hasLoaded = true;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
      });
    }
  }

  // Public method to refresh profile (called from drawer)
  void refreshProfile() {
    _hasLoaded = false;
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final userData = _userData ?? {
      'name': 'User',
      'role': widget.role,
    };
    
    // Calculate age from dateOfBirth if available
    int? age;
    if (userData['dateOfBirth'] != null) {
      try {
        final dob = DateTime.parse(userData['dateOfBirth'] as String);
        age = DateTime.now().difference(dob).inDays ~/ 365;
      } catch (e) {
        // Ignore
      }
    }

    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    image: _userData?['profilePhoto'] != null
                        ? DecorationImage(
                            image: NetworkImage(
                              _userData!['profilePhoto'].toString().startsWith('http')
                                  ? _userData!['profilePhoto'] as String
                                  : '${ApiClient.baseUrl}${_userData!['profilePhoto']}',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _userData?['profilePhoto'] == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.black54,
                        )
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userData['name'] as String,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          _buildVerificationBadge(userData),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${userData['age'] ?? 'N/A'} years • ${userData['gender'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      CompleteProfileScreen.routeName,
                    ).then((_) {
                      // Refresh profile after editing
                      _loadUserData();
                    });
                  },
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Boost Status Card (if expired, show repost button)
          _buildBoostStatusCard(context, theme),
          const SizedBox(height: 24),
          
          // Boost Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final isVerified = _userData?['isVerified'] == true;
                if (!isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Your profile must be verified before you can boost. Please wait for admin approval.',
                      ),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  return;
                }
                Navigator.pushNamed(
                  context,
                  BoostActivityScreen.routeName,
                  arguments: widget.role,
                );
              },
              icon: const Icon(Icons.rocket_launch, size: 20),
              label: const Text(
                'Boost my profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Personal details section
          _buildSectionTitle('Personal details'),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.person_outline,
            'Name',
            userData['name'] as String,
          ),
          _buildInfoCard(
            Icons.cake_outlined,
            'Age',
            '${age ?? userData['age'] ?? 'N/A'} years',
          ),
          _buildInfoCard(
            Icons.person_outline,
            'Gender',
            userData['gender'] as String,
          ),
          _buildInfoCard(
            Icons.height_outlined,
            'Height',
            '${userData['height']} cm',
          ),
          _buildInfoCard(
            Icons.face_outlined,
            'Complexion',
            userData['complexion'] as String,
          ),
          
          const SizedBox(height: 24),
          
          // Location section
          _buildSectionTitle('Location'),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.flag_outlined,
            'Country',
            userData['country'] as String,
          ),
          _buildInfoCard(
            Icons.map_outlined,
            'State',
            userData['state'] as String,
          ),
          _buildInfoCard(
            Icons.location_city_outlined,
            'City',
            userData['city'] as String,
          ),
          
          const SizedBox(height: 24),
          
          // Religion & community
          _buildSectionTitle('Religion & community'),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.church_outlined,
            'Religion',
            userData['religion'] as String,
          ),
          _buildInfoCard(
            Icons.group_outlined,
            'Caste / Community',
            userData['caste'] as String,
          ),
          
          const SizedBox(height: 24),
          
          // Education & profession
          _buildSectionTitle('Education & profession'),
          const SizedBox(height: 12),
          _buildInfoCard(
            Icons.school_outlined,
            'Education',
            userData['education'] as String,
          ),
          _buildInfoCard(
            Icons.work_outline,
            'Profession',
            userData['profession'] as String,
          ),
          _buildInfoCard(
            Icons.attach_money_outlined,
            'Annual income',
            '\$${userData['income']}',
          ),
          
          const SizedBox(height: 24),
          
          // About me
          _buildSectionTitle('About me'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              userData['about'] as String,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Partner preferences
          _buildSectionTitle('Partner preferences'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              userData['preferences'] as String,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBoostStatusCard(BuildContext context, ThemeData theme) {
    // Get real boost data from user profile
    final isBoosted = _userData?['isBoosted'] as bool? ?? false;
    final boostExpiresAt = _userData?['boostExpiresAt'] != null
        ? DateTime.tryParse(_userData!['boostExpiresAt'].toString())
        : null;
    
    final boostStatus = (isBoosted && boostExpiresAt != null && boostExpiresAt.isAfter(DateTime.now()))
        ? 'Active'
        : 'Expired';
    final boostType = _userData?['boostType'] as String? ?? 'Standard'; // 'Standard' or 'Featured'
    
    final daysLeft = boostExpiresAt != null && boostExpiresAt.isAfter(DateTime.now())
        ? boostExpiresAt.difference(DateTime.now()).inDays
        : 0;
    final expiredDays = boostExpiresAt != null && boostExpiresAt.isBefore(DateTime.now())
        ? DateTime.now().difference(boostExpiresAt).inDays
        : 0;
    
    final isBoostActive = boostStatus == 'Active';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBoostActive
            ? theme.colorScheme.primaryContainer.withOpacity(0.2)
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBoostActive
              ? theme.colorScheme.primary.withOpacity(0.3)
              : Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBoostActive ? Icons.rocket_launch : Icons.timer_off,
                color: isBoostActive
                    ? theme.colorScheme.primary
                    : Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          boostType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isBoostActive
                                ? theme.colorScheme.primary
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isBoostActive
                                ? Colors.green.shade50
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            boostStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isBoostActive
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBoostActive
                          ? '$daysLeft days remaining'
                          : 'Expired $expiredDays days ago',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isBoostActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to payment for repost
                  Navigator.pushNamed(
                    context,
                    PaymentScreen.routeName,
                    arguments: {
                      'boostType': boostType.toLowerCase().contains('featured')
                          ? 'featured'
                          : 'standard',
                      'isRepost': true,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                label: const Text(
                  'Repost Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.black54,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(Map<String, dynamic> userData) {
    final isVerified = userData['isVerified'] == true;
    final verificationNotes = userData['verificationNotes'] as String?;
    final isRejected = verificationNotes != null && verificationNotes.isNotEmpty && !isVerified;
    
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      );
    } else if (isRejected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 16, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text(
              'Rejected',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pending, size: 16, color: Colors.orange.shade700),
            const SizedBox(width: 4),
            Text(
              'Under Review',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      );
    }
  }
}

