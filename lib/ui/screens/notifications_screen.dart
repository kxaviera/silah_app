import 'package:flutter/material.dart';

import '../../core/notification_api.dart';
import '../../core/auth_api.dart';
import '../../utils/boost_dialog.dart';
import 'chat_screen.dart';
import 'boost_activity_screen.dart';
import '../shell/app_shell.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all'; // all, messages, requests, matches, boost
  final NotificationApi _api = NotificationApi();
  final AuthApi _authApi = AuthApi();
  String? _userRole;
  
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadNotifications();
  }

  Future<void> _loadUserRole() async {
    try {
      final response = await _authApi.getMe();
      if (response['success'] == true && mounted) {
        final user = response['user'] as Map<String, dynamic>;
        setState(() {
          _userRole = user['role'] as String? ?? 'groom';
        });
      }
    } catch (e) {
      // Default to groom if failed
      if (mounted) {
        setState(() {
          _userRole = 'groom';
        });
      }
    }
  }

  Future<bool> _isUserBoosted() async {
    try {
      final me = await _authApi.getMe();
      if (me['success'] != true || me['user'] == null) return false;
      final u = me['user'] as Map<String, dynamic>;
      final status = u['boostStatus'] as String?;
      final expires = u['boostExpiresAt'] as String?;
      if (status != 'active' || expires == null) return false;
      return DateTime.parse(expires).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isRefreshing = true;
        _currentPage = 1;
        _hasMore = true;
      });
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final response = await _api.getNotifications(
        page: _currentPage,
        limit: 20,
        unreadOnly: false,
      );

      if (response['success'] == true) {
        final notifications = response['notifications'] as List? ?? [];
        final pagination = response['pagination'] as Map<String, dynamic>?;

        setState(() {
          if (refresh || _currentPage == 1) {
            _notifications = notifications.map((n) => n as Map<String, dynamic>).toList();
          } else {
            _notifications.addAll(notifications.map((n) => n as Map<String, dynamic>).toList());
          }

          // Check if there are more pages
          if (pagination != null) {
            final currentPage = pagination['page'] as int? ?? _currentPage;
            final totalPages = pagination['pages'] as int? ?? 1;
            _hasMore = currentPage < totalPages;
          } else {
            // If no pagination info, assume no more if we got fewer than limit
            _hasMore = notifications.length >= 20;
          }
          _isLoading = false;
          _isRefreshing = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? response['error']?['message'] ?? 'Failed to load notifications')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _currentPage++;
      _isLoading = true;
    });

    await _loadNotifications();
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'all') {
      return List<Map<String, dynamic>>.from(_notifications);
    }
    return _notifications.where((n) {
      final type = (n['type'] as String? ?? '').toLowerCase();
      if (_selectedFilter == 'request') {
        return type.contains('request');
      }
      if (_selectedFilter == 'messages') {
        return type.contains('message');
      }
      if (_selectedFilter == 'match') {
        return type.contains('match');
      }
      if (_selectedFilter == 'boost') {
        return type.contains('boost');
      }
      return type.contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  int get _unreadCount {
    return _notifications.where((n) => (n['isRead'] as bool?) == false).length;
  }

  String _getTimeAgo(dynamic dateTime) {
    DateTime dt;
    if (dateTime is String) {
      dt = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      dt = dateTime;
    } else {
      return 'Recently';
    }

    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_request':
        return Icons.inbox;
      case 'request_accepted':
      case 'request_rejected':
        return Icons.check_circle;
      case 'new_message':
        return Icons.chat_bubble;
      case 'new_match':
        return Icons.favorite;
      case 'profile_view':
        return Icons.visibility;
      case 'profile_liked':
      case 'profile_shortlisted':
        return Icons.thumb_up;
      case 'boost_expiring':
      case 'boost_expired':
        return Icons.rocket_launch;
      case 'payment_success':
        return Icons.payment;
      case 'payment_failed':
        return Icons.error;
      case 'profile_verified':
        return Icons.verified;
      case 'profile_rejected':
        return Icons.cancel;
      case 'profile_blocked':
        return Icons.block;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_request':
        return Colors.blue;
      case 'request_accepted':
        return Colors.green;
      case 'request_rejected':
        return Colors.red;
      case 'new_message':
        return Colors.purple;
      case 'new_match':
        return Colors.pink;
      case 'profile_view':
        return Colors.orange;
      case 'profile_liked':
      case 'profile_shortlisted':
        return Colors.red;
      case 'boost_expiring':
      case 'boost_expired':
        return Colors.amber;
      case 'payment_success':
        return Colors.green;
      case 'payment_failed':
        return Colors.red;
      case 'profile_verified':
        return Colors.green;
      case 'profile_rejected':
        return Colors.orange;
      case 'profile_blocked':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    final notificationId = notification['id'] as String? ?? notification['_id'] as String?;
    final type = notification['type'] as String;
    final data = notification['data'] as Map<String, dynamic>?;

    // Mark as read if not already read
    if (notificationId != null && (notification['isRead'] as bool?) != true) {
      try {
        await _api.markAsRead(notificationId);
        setState(() {
          notification['isRead'] = true;
        });
      } catch (e) {
        // Silently fail - navigation is more important
        print('Error marking notification as read: $e');
      }
    }

    // Navigate based on type
    switch (type) {
      case 'new_request':
      case 'request_accepted':
      case 'request_rejected':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppShell.routeName,
          (route) => false,
          arguments: {'role': _userRole ?? 'groom', 'initialTab': 1},
        );
        break;
      case 'new_message':
        if (data?['conversationId'] != null && data?['userId'] != null) {
          final boosted = await _isUserBoosted();
          if (!mounted) return;
          if (!boosted) {
            await showBoostRequiredDialog(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: data!['conversationId'] as String,
                otherUserId: data['userId'] as String,
                name: notification['title'] as String,
              ),
            ),
          );
        } else {
          // Navigate to AppShell and switch to Messages tab
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppShell.routeName,
            (route) => false,
            arguments: {'role': _userRole ?? 'groom', 'initialTab': 2},
          );
        }
        break;
      case 'new_match':
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppShell.routeName,
          (route) => false,
          arguments: {'role': _userRole ?? 'groom', 'initialTab': 0},
        );
        break;
      case 'profile_view':
      case 'profile_liked':
      case 'profile_shortlisted':
        Navigator.pushNamed(context, BoostActivityScreen.routeName);
        break;
      case 'boost_expiring':
      case 'boost_expired':
        Navigator.pushNamed(context, BoostActivityScreen.routeName);
        break;
      case 'payment_success':
      case 'payment_failed':
        // Navigate to payment or invoice screen
        break;
      case 'profile_verified':
      case 'profile_rejected':
      case 'profile_blocked':
        // Navigate to Profile tab
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppShell.routeName,
          (route) => false,
          arguments: {'role': _userRole ?? 'groom', 'initialTab': 3},
        );
        break;
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _api.markAllAsRead();
      setState(() {
        for (var notification in _notifications) {
          notification['isRead'] = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Mark all read'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    count: _notifications.length,
                    selected: _selectedFilter == 'all',
                    onSelected: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Messages',
                    count: _notifications.where((n) => n['type'] == 'new_message').length,
                    selected: _selectedFilter == 'messages',
                    onSelected: () => setState(() => _selectedFilter = 'messages'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Requests',
                    count: _notifications
                        .where((n) => n['type'].toString().contains('request'))
                        .length,
                    selected: _selectedFilter == 'request',
                    onSelected: () => setState(() => _selectedFilter = 'request'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Matches',
                    count: _notifications.where((n) => n['type'] == 'new_match').length,
                    selected: _selectedFilter == 'match',
                    onSelected: () => setState(() => _selectedFilter = 'match'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Boost',
                    count: _notifications
                        .where((n) => n['type'].toString().contains('boost'))
                        .length,
                    selected: _selectedFilter == 'boost',
                    onSelected: () => setState(() => _selectedFilter = 'boost'),
                  ),
                ],
              ),
            ),
          ),

          // Notifications list
          Expanded(
            child: _isLoading && _notifications.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'re all caught up!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadNotifications(refresh: true),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredNotifications.length + (_hasMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == _filteredNotifications.length) {
                              // Load more indicator
                              if (_hasMore) {
                                _loadMore();
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final notification = _filteredNotifications[index];
                            final isRead = (notification['isRead'] as bool?) ?? false;
                            final type = notification['type'] as String? ?? '';
                            final createdAt = notification['createdAt'];

                        return _NotificationCard(
                          title: notification['title'] as String? ?? notification['message'] as String? ?? 'Notification',
                          body: notification['body'] as String? ?? notification['message'] as String? ?? '',
                          timeAgo: _getTimeAgo(createdAt),
                          isRead: isRead,
                          icon: _getNotificationIcon(type),
                          iconColor: _getNotificationColor(type),
                          onTap: () => _handleNotificationTap(notification),
                          onDelete: () async {
                            final notificationId = notification['id'] as String? ?? notification['_id'] as String?;
                            if (notificationId != null) {
                              try {
                                await _api.deleteNotification(notificationId);
                                setState(() {
                                  _notifications.remove(notification);
                                });
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error deleting notification: ${e.toString()}')),
                                  );
                                }
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? theme.colorScheme.primary
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? theme.colorScheme.primary : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? theme.colorScheme.primary : Colors.grey.shade300,
        width: selected ? 2 : 1,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.isRead,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red.shade400,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? Colors.grey.shade200 : Colors.blue.shade200,
              width: isRead ? 1 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
