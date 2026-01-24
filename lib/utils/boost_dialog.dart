import 'package:flutter/material.dart';

import '../core/app_settings.dart';
import '../core/profile_api.dart';

/// Shows a dialog when a non-boosted user tries to use a feature (chat, mobile, request contact).
/// "Boost" button triggers free boost only — never opens payment screen. Profile goes live.
/// Use when payment enabled or disabled; always free boost from this dialog.
Future<void> showBoostRequiredDialog(
  BuildContext context, {
  VoidCallback? onBoosted,
}) async {
  final profileApi = ProfileApi();
  bool isActivating = false;
  final callerContext = context;

  if (!callerContext.mounted) return;
  await showDialog<void>(
    context: callerContext,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (_, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Boost your profile',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To use this feature (chat, request contact, view mobile), boost your profile. '
                'Your profile will go live — no payment. Tap Boost Free to continue.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              if (isActivating)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isActivating ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isActivating
                  ? null
                  : () async {
                      setDialogState(() => isActivating = true);
                      try {
                        await AppSettingsService.fetchSettings();
                      } catch (_) {}
                      final response = await profileApi.activateBoost(
                        boostType: 'standard',
                        isFree: true,
                      );
                      if (!ctx.mounted) return;
                      setDialogState(() => isActivating = false);
                      Navigator.pop(ctx);
                      if (response['success'] == true) {
                        onBoosted?.call();
                        if (callerContext.mounted) {
                          ScaffoldMessenger.of(callerContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profile boosted! Your profile is now live. You can use this feature.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (callerContext.mounted) {
                          ScaffoldMessenger.of(callerContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] as String? ??
                                    'Could not boost. Please try again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Boost Free'),
            ),
          ],
        );
      },
    ),
  );
}
