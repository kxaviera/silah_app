import 'package:flutter/material.dart';

import '../../core/profile_api.dart';
import '../../core/request_api.dart';
import '../../core/auth_api.dart';
import 'discover_screen.dart' show ProfileAd;

class AdDetailScreen extends StatefulWidget {
  final String? userId;
  final ProfileAd? ad; // Optional for backward compatibility
  const AdDetailScreen({super.key, this.userId, this.ad});

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  final _profileApi = ProfileApi();
  final _requestApi = RequestApi();
  
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  bool _isRequesting = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadProfile();
    }
  }
  
  Future<void> _loadProfile() async {
    if (widget.userId == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _profileApi.getProfile(widget.userId!);
      
      if (response['success'] == true) {
        setState(() {
          _profile = response['profile'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _handleRequestContact() async {
    if (widget.userId == null) return;
    
    // Check if current user is verified
    try {
      final authApi = AuthApi();
      final meResponse = await authApi.getMe();
      if (meResponse['success'] == true) {
        final currentUser = meResponse['user'] as Map<String, dynamic>?;
        if (currentUser?['isVerified'] != true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Your profile must be verified before you can send contact requests. Please wait for admin approval.',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      // If can't check, proceed - backend will handle it
    }
    
    // Check if target user is verified
    if (_profile != null && _profile!['isVerified'] != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'This profile is not verified yet. Contact requests can only be sent to verified profiles.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isRequesting = true;
    });
    
    try {
      final response = await _requestApi.sendRequest(
        userId: widget.userId!,
        requestType: 'both', // 'mobile', 'photos', 'both'
      );
      
      if (response['success'] == true) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Request sent',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              content: const Text(
                'Your request to view mobile number and photos has been sent. '
                'You will be notified when they respond.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to send request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('verified') 
                ? 'Verification required to send contact requests.'
                : 'An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }
  
  ProfileAd? get _ad {
    if (widget.ad != null) return widget.ad;
    if (_profile == null) return null;
    
    return ProfileAd(
      id: _profile!['_id'] ?? _profile!['id'] ?? '',
      name: _profile!['name'] ?? _profile!['fullName'] ?? 'Unknown',
      age: _profile!['age'] ?? 0,
      country: _profile!['country'] ?? 'India',
      livingCountry: _profile!['livingCountry'],
      state: _profile!['state'],
      city: _profile!['city'],
      religion: _profile!['religion'] ?? '',
      role: _profile!['role'] ?? 'groom',
      featured: _profile!['boostType'] == 'featured' || _profile!['isBoosted'] == true,
      sponsored: _profile!['boostType'] == 'featured',
      isVerified: _profile!['isVerified'] == true,
      profession: _profile!['profession'],
      education: _profile!['education'],
      height: _profile!['height'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ad = _ad;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage != null || ad == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Profile not found',
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.userId != null ? _loadProfile : null,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ad.featured || ad.sponsored
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : Colors.grey.shade200,
                  width: ad.featured || ad.sponsored ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            ad.name[0],
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      if (ad.featured || ad.sponsored)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: ad.featured
                                  ? theme.colorScheme.primary
                                  : Colors.orange.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              ad.featured ? Icons.star : Icons.workspace_premium,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      ad.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (ad.isVerified)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.verified,
                                        size: 24,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (ad.featured)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  'Featured',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            if (ad.sponsored)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                                child: Text(
                                  'Sponsored',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${ad.age} years • ${ad.country}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ad.religion,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (ad.age != null)
                  _detailChip(Icons.cake_outlined, 'Age ${ad.age}'),
                if (ad.height != null)
                  _detailChip(Icons.height_outlined, 'Height ${ad.height} cm'),
                _detailChip(Icons.flag_outlined, ad.country),
                _detailChip(Icons.church_outlined, ad.religion),
                if (ad.profession != null)
                  _detailChip(Icons.work_outline, ad.profession!),
                if (ad.education != null)
                  _detailChip(Icons.school_outlined, ad.education!),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'Looking for a life partner who shares similar values and interests. '
                'Family-oriented, professional, and seeking a meaningful connection. '
                'Open to getting to know each other better.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Education & Profession'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  if (ad.education != null)
                    _infoRow(Icons.school_outlined, 'Education', ad.education!),
                  if (ad.education != null && ad.profession != null)
                    Divider(color: Colors.grey.shade200, height: 24),
                  if (ad.profession != null)
                    _infoRow(Icons.work_outline, 'Profession', ad.profession!),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Contact details will be shared only after approval.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRequesting ? null : _handleRequestContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isRequesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.phone, size: 20),
                label: const Text(
                  'Request contact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
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
    );
  }
}
