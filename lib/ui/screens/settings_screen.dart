import 'package:flutter/material.dart';

import '../../core/notification_api.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationApi _api = NotificationApi();
  
  bool _pushNotifications = true;
  bool _messageNotifications = true;
  bool _requestNotifications = true;
  bool _matchNotifications = false;
  bool _boostReminders = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await _api.getPreferences();
      if (response['success'] == true) {
        final prefs = response['preferences'] as Map<String, dynamic>;
        setState(() {
          _pushNotifications = prefs['pushEnabled'] as bool? ?? true;
          _messageNotifications = prefs['messageNotifications'] as bool? ?? true;
          _requestNotifications = prefs['requestNotifications'] as bool? ?? true;
          _matchNotifications = prefs['matchNotifications'] as bool? ?? false;
          _boostReminders = prefs['boostReminders'] as bool? ?? true;
        });
      }
    } catch (e) {
      // Silently fail - use defaults
      print('Error loading preferences: $e');
    }
  }

  Future<void> _updatePreferences() async {
    setState(() => _isLoading = true);
    try {
      await _api.updatePreferences(
        pushEnabled: _pushNotifications,
        messageNotifications: _messageNotifications,
        requestNotifications: _requestNotifications,
        matchNotifications: _matchNotifications,
        profileViewNotifications: false,
        boostReminders: _boostReminders,
        paymentNotifications: true,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SwitchListTile(
              title: const Text(
                'Push notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: const Text(
                'Get alerts for messages and requests',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _updatePreferences();
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Notification Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'New messages',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Get notified when you receive messages',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  value: _messageNotifications,
                  onChanged: (value) {
                    setState(() => _messageNotifications = value);
                    _updatePreferences();
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                SwitchListTile(
                  title: const Text(
                    'New requests',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Get notified when you receive contact requests',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  value: _requestNotifications,
                  onChanged: (value) {
                    setState(() => _requestNotifications = value);
                    _updatePreferences();
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                SwitchListTile(
                  title: const Text(
                    'Request responses',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Get notified when your requests are accepted/rejected',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  value: _requestNotifications, // Same as requests
                  onChanged: (value) {
                    setState(() => _requestNotifications = value);
                    _updatePreferences();
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                SwitchListTile(
                  title: const Text(
                    'New matches',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Get notified when new profiles match your preferences',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  value: _matchNotifications,
                  onChanged: (value) {
                    setState(() => _matchNotifications = value);
                    _updatePreferences();
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                SwitchListTile(
                  title: const Text(
                    'Boost reminders',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Get reminders when your boost is expiring',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  value: _boostReminders,
                  onChanged: (value) {
                    setState(() => _boostReminders = value);
                    _updatePreferences();
                  },
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              title: const Text(
                'Language',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: const Text(
                'English',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language selection coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Account',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: ListTile(
              title: const Text(
                'Delete account',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text(
                'Permanently delete your account and all data',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              trailing: Icon(
                Icons.delete_outline,
                color: Colors.red.shade400,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account deletion coming soon')),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

