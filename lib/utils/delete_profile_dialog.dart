import 'package:flutter/material.dart';

import '../core/auth_api.dart';
import '../core/api_client.dart';
import '../ui/screens/login_screen.dart';

/// Deletion reason options (must match backend VALID_DELETION_REASONS)
const List<Map<String, String>> kDeleteReasons = [
  {'code': 'found_match_silah', 'label': 'Found match on Silah'},
  {'code': 'found_match_elsewhere', 'label': 'Found match elsewhere'},
  {'code': 'not_interested', 'label': 'Not interested anymore'},
  {'code': 'privacy_concerns', 'label': 'Privacy concerns'},
  {'code': 'taking_break', 'label': 'Taking a break'},
  {'code': 'other', 'label': 'Other'},
];

/// Shows the delete-profile dialog with reason options. On success, clears token
/// and navigates to [LoginScreen].
Future<void> showDeleteProfileDialog(BuildContext context) async {
  final callerContext = context;
  final authApi = AuthApi();
  String? selectedReason;
  final otherController = TextEditingController();
  bool isDeleting = false;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (_, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete profile',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please tell us why you\'re leaving. This helps us improve.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ...kDeleteReasons.map((r) {
                  final code = r['code']!;
                  final label = r['label']!;
                  return RadioListTile<String>(
                    value: code,
                    groupValue: selectedReason,
                    onChanged: isDeleting
                        ? null
                        : (v) => setDialogState(() => selectedReason = v),
                    title: Text(label, style: const TextStyle(fontSize: 14)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                if (selectedReason == 'other') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: otherController,
                    enabled: !isDeleting,
                    decoration: InputDecoration(
                      hintText: 'Please specify (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    maxLines: 2,
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
                if (isDeleting)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isDeleting || selectedReason == null
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      final reason = selectedReason!;
                      final other = reason == 'other'
                          ? otherController.text.trim()
                          : null;
                      try {
                        final res = await authApi.deleteAccount(
                          reason: reason,
                          otherReason: other?.isEmpty == true ? null : other,
                        );
                        if (res['success'] != true) {
                          if (ctx.mounted) {
                            setDialogState(() => isDeleting = false);
                          }
                          if (callerContext.mounted) {
                            ScaffoldMessenger.of(callerContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  res['message'] as String? ??
                                      'Failed to delete profile.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        await ApiClient.instance.clearToken();
                        if (!callerContext.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          callerContext,
                          LoginScreen.routeName,
                          (_) => false,
                        );
                        if (callerContext.mounted) {
                          ScaffoldMessenger.of(callerContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                res['message'] as String? ??
                                    'Profile deleted. You can sign up again anytime.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => isDeleting = false);
                        }
                        if (callerContext.mounted) {
                          ScaffoldMessenger.of(callerContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to delete: ${e.toString()}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        otherController.dispose();
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete profile'),
            ),
          ],
        );
      },
    ),
  );
}
