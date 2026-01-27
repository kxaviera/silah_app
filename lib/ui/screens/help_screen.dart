import 'package:flutter/material.dart';

import 'help_detail_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  static const routeName = '/help';

  static final _topics = [
    (
      icon: Icons.account_circle_outlined,
      title: 'Account & Profile',
      description: 'Questions about your account, profile settings, or updating information.',
      sections: [
        {'heading': 'Updating your profile', 'body': 'You can edit your profile anytime from the Profile tab. Tap your profile, then Edit to update your name, photo, location, profession, religion, and other details.'},
        {'heading': 'Profile visibility', 'body': 'Your profile is shown to others based on search preferences and filters. Boost your profile to go live and increase visibility. Unboosted profiles are not visible to other users.'},
        {'heading': 'Account settings', 'body': 'Manage your account from the Profile screen. You can update preferences, view boost status, and access Payment & Boost, Profile Activity, and other options from the menu.'},
      ],
    ),
    (
      icon: Icons.payment_outlined,
      title: 'Payments & Subscriptions',
      description: 'Issues with featured posts, payments, or refunds.',
      sections: [
        {'heading': 'Boost & Featured posts', 'body': 'Boost your profile to go live and get more responses. Standard and Featured options give your profile greater visibility for a set period. Choose the option that suits you from the Boost banner on the Discover screen.'},
        {'heading': 'Payments', 'body': 'Payments are processed securely. Once a boost or featured post is published and your profile is live, it cannot be refunded. Make sure you have completed your profile before boosting.'},
        {'heading': 'Billing & invoices', 'body': 'View your payment history and invoices from the Payment & Boost section in the app menu. You can also check Profile Activity to see when your boost started and when it expires.'},
      ],
    ),
    (
      icon: Icons.security_outlined,
      title: 'Safety & Privacy',
      description: 'Report suspicious users, block/report issues, or privacy concerns.',
      sections: [
        {'heading': 'Reporting users', 'body': 'If you encounter suspicious or inappropriate behaviour, use the Report option on the user\'s profile or in messages. We review all reports seriously and take action when needed.'},
        {'heading': 'Blocking', 'body': 'You can block users from contacting you. Blocked users cannot message you or see your profile. Manage blocked users from your profile or message settings.'},
        {'heading': 'Staying safe', 'body': 'Never share passwords, OTPs, or financial details with other users. Meet in public places when meeting in person. Report any activity that makes you uncomfortable.'},
      ],
    ),
    (
      icon: Icons.chat_bubble_outline,
      title: 'Messages & Requests',
      description: 'Help with messaging, contact requests, or communication features.',
      sections: [
        {'heading': 'Contact requests', 'body': 'When someone is interested in your profile, they send a contact request. You can accept or decline from the Requests tab. Received and sent requests are shown in separate tabs.'},
        {'heading': 'Messaging', 'body': 'Accepted requests can message you through the app. Keep conversations within Silah for your safety. Use the Chat tab to view and reply to messages.'},
        {'heading': 'Notifications', 'body': 'You can view new matches, messages, and requests from the notifications icon on the Discover screen. Tap it to open the Notifications page and stay updated.'},
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Help & support',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(_topics.length, (i) {
              final t = _topics[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < _topics.length - 1 ? 12 : 0),
                child: _buildHelpCard(
                  context,
                  icon: t.icon,
                  title: t.title,
                  description: t.description,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      HelpDetailScreen.routeName,
                      arguments: {
                        'title': t.title,
                        'sections': t.sections,
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
