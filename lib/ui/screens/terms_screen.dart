import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  static const routeName = '/terms';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Terms & conditions',
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
              'Terms & Conditions',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: January 2024',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Use of the app',
              'By using Silah, you agree to use the platform responsibly and in accordance with these terms. You must be at least 18 years old to create an account and use our services.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '2. Safety and privacy',
              'We prioritize your safety and privacy. Never share personal information like passwords, OTPs, or financial details with other users. Report any suspicious activity immediately.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '3. Payment & subscriptions',
              'Featured posts and sponsored posts are valid for the specified duration (3 days for featured, 7 days for sponsored). Payments are non-refundable once the post is published.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '4. Prohibited content',
              'You may not post false information, offensive content, or engage in harassment. Violations may result in account suspension or termination.',
            ),
            const SizedBox(height: 20),
            _buildSection(
              '5. Liability and termination',
              'Silah reserves the right to suspend or terminate accounts that violate these terms. We are not liable for interactions between users outside our platform.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For questions about these terms, contact us at support@silah.app',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

