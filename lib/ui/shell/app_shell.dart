import 'package:flutter/material.dart';

import '../screens/discover_screen.dart';
import '../screens/requests_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/help_screen.dart';
import '../../core/notification_service.dart';
import '../../core/socket_service.dart';
import '../../core/auth_api.dart';
import '../../core/profile_api.dart';
import '../../core/api_client.dart';
import '../screens/notifications_screen.dart';
import '../screens/payment_post_profile_screen.dart';
import '../widgets/notification_badge.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  static const routeName = '/home';

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late final String _role;
  
  int _unreadMessagesCount = 0;
  int _unreadRequestsCount = 0;
  int _newMatchesCount = 0;
  
  // User profile data
  String _userName = 'Silah user';
  String? _userPhotoUrl;
  bool _isLoadingProfile = true;
  
  final _authApi = AuthApi();
  final _profileApi = ProfileApi();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = ModalRoute.of(context)?.settings.arguments as String? ?? 'groom';
    _fetchNotificationCounts();
    _fetchUserProfile();
  }

  @override
  void initState() {
    super.initState();
    // Refresh counts periodically
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    // Refresh every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _fetchNotificationCounts();
        _startPeriodicRefresh();
      }
    });
  }

  Future<void> _fetchNotificationCounts() async {
    try {
      final counts = await NotificationService.instance.getUnreadCounts();
      if (mounted) {
        setState(() {
          _unreadMessagesCount = counts['messages'] ?? 0;
          _unreadRequestsCount = counts['requests'] ?? 0;
          _newMatchesCount = counts['matches'] ?? 0;
        });
      }
    } catch (e) {
      // Silently fail - counts will update on next refresh
      print('Error fetching notification counts: $e');
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      // Get current user ID
      final meResponse = await _authApi.getMe();
      if (meResponse['success'] == true && meResponse['user'] != null) {
        final user = meResponse['user'] as Map<String, dynamic>;
        final userId = user['_id'] as String?;
        
        // Set name and photo from getMe response first
        if (mounted) {
          setState(() {
            _userName = user['fullName'] as String? ?? 'Silah user';
            // Get profile photo from user object
            final photoUrl = user['profilePhoto'] as String?;
            if (photoUrl != null && photoUrl.isNotEmpty) {
              // Construct full URL if it's a relative path
              _userPhotoUrl = photoUrl.startsWith('http') 
                  ? photoUrl 
                  : '${ApiClient.baseUrl}$photoUrl';
            } else {
              _userPhotoUrl = null;
            }
          });
        }
        
        if (userId != null) {
          // Get full profile data
          final profileResponse = await _profileApi.getProfile(userId);
          if (profileResponse['success'] == true && profileResponse['profile'] != null) {
            final profile = profileResponse['profile'] as Map<String, dynamic>;
            if (mounted) {
              setState(() {
                _userName = profile['fullName'] as String? ?? 
                           profile['name'] as String? ??
                           user['fullName'] as String? ?? 
                           'Silah user';
                // Update photo URL from profile
                final photoUrl = profile['profilePhoto'] as String?;
                if (photoUrl != null && photoUrl.isNotEmpty) {
                  _userPhotoUrl = photoUrl.startsWith('http') 
                      ? photoUrl 
                      : '${ApiClient.baseUrl}$photoUrl';
                }
                _isLoadingProfile = false;
              });
            }
          } else {
            // Keep data from getMe
            if (mounted) {
              setState(() {
                _isLoadingProfile = false;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoadingProfile = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  // Profile screen key for refresh
  final GlobalKey<_ProfileScreenState> _profileScreenKey = GlobalKey<_ProfileScreenState>();

  @override
  Widget build(BuildContext context) {
    final pages = [
      DiscoverScreen(role: _role),
      const RequestsScreen(),
      const MessagesScreen(),
      ProfileScreen(key: _profileScreenKey, role: _role),
    ];

    final titles = ['Search', 'Requests', 'Messages', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: _newMatchesCount > 0
                ? NotificationBadge(
                    count: _newMatchesCount,
                    child: const Icon(Icons.search),
                  )
                : const Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: _unreadRequestsCount > 0
                ? NotificationBadge(
                    count: _unreadRequestsCount,
                    child: const Icon(Icons.inbox_outlined),
                  )
                : const Icon(Icons.inbox_outlined),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: _unreadMessagesCount > 0
                ? NotificationBadge(
                    count: _unreadMessagesCount,
                    child: const Icon(Icons.chat_bubble),
                  )
                : const Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                // Refresh profile before navigating
                await _fetchUserProfile();
                // Navigate to Profile tab and refresh it
                if (mounted) {
                  setState(() => _index = 3);
                  // Trigger refresh on ProfileScreen
                  final profileScreen = pages[3] as ProfileScreen;
                  if (profileScreen is ProfileScreen) {
                    // Access the state to refresh
                    final profileState = profileScreen.createState();
                    if (profileState is _ProfileScreenState) {
                      profileState.refreshProfile();
                    }
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        image: _userPhotoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_userPhotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _userPhotoUrl == null
                          ? (_isLoadingProfile
                              ? const Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF757575)),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.black54,
                                  size: 28,
                                ))
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isLoadingProfile
                              ? const SizedBox(
                                  height: 16,
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Color(0xFFE0E0E0),
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF757575)),
                                  ),
                                )
                              : Text(
                                  _userName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'View and edit profile',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    badge: _unreadMessagesCount + _unreadRequestsCount + _newMatchesCount,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, NotificationsScreen.routeName);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Boost Activity',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/boost-activity',
                        arguments: _role,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.payment_outlined,
                    title: 'Payment & Boost',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        PaymentPostProfileScreen.routeName,
                        arguments: _role,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Others',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms & conditions',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, TermsScreen.routeName);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, PrivacyScreen.routeName);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & support',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, HelpScreen.routeName);
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleLogout(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.logout,
                    size: 20,
                    color: Colors.black87,
                  ),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    int? badge,
  }) {
    return ListTile(
      leading: badge != null && badge > 0
          ? NotificationBadge(
              count: badge,
              child: Icon(
                icon,
                color: Colors.black54,
                size: 24,
              ),
            )
          : Icon(
              icon,
              color: Colors.black54,
              size: 24,
            ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Disconnect socket
      SocketService().disconnect();
      
      // Call logout API
      final authApi = AuthApi();
      await authApi.logout();

      // Clear token
      await ApiClient.instance.clearToken();

      // Navigate to login
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      // Even if logout fails, clear token and navigate
      await ApiClient.instance.clearToken();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }
}
