import 'package:flutter/material.dart';

class HelpDetailScreen extends StatelessWidget {
  const HelpDetailScreen({super.key});
  static const routeName = '/help-detail';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? 'Help';
    final sections = (args?['sections'] as List<Map<String, String>>?) ?? [];

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
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
              title,
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
            ...sections.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildSection(
                    s['heading'] ?? '',
                    s['body'] ?? '',
                  ),
                )),
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
