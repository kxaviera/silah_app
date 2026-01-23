import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth_api.dart';
import '../../core/api_client.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'complete_profile_screen.dart';
import 'safety_tutorial_screen.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for splash screen to show (minimum 1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // Check if token exists
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        // Token exists - verify it's still valid
        try {
          final authApi = AuthApi();
          final userResponse = await authApi.getMe();

          if (userResponse['success'] == true && mounted) {
            // Token is valid - user is logged in
            final user = userResponse['user'] as Map<String, dynamic>;
            final role = user['role'] as String? ?? 'groom';
            final isProfileComplete = user['isProfileComplete'] as bool? ?? false;
            final tutorialCompleted = prefs.getBool('safety_tutorial_completed') ?? false;

            // Only navigate to app if profile is complete
            // If profile is incomplete, user should complete it through normal flow
            if (isProfileComplete) {
              // Check if safety tutorial needs to be shown
              if (!tutorialCompleted && mounted) {
                final tutorialResult = await Navigator.pushNamed(
                  context,
                  SafetyTutorialScreen.routeName,
                );

                if (mounted && tutorialResult == true) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppShell.routeName,
                    arguments: role,
                  );
                } else if (mounted) {
                  // Tutorial cancelled or failed - still navigate to app
                  Navigator.pushReplacementNamed(
                    context,
                    AppShell.routeName,
                    arguments: role,
                  );
                }
              } else {
                // Navigate directly to app
                Navigator.pushReplacementNamed(
                  context,
                  AppShell.routeName,
                  arguments: role,
                );
              }
              return;
            } else {
              // Profile incomplete - clear token and go to login
              // User needs to login again and complete profile through normal flow
              print('Profile incomplete, clearing token and going to login');
              await ApiClient.instance.clearToken();
            }
          } else {
            // Token is invalid or expired - clear it and go to login
            print('Token invalid or expired, clearing and going to login');
            await ApiClient.instance.clearToken();
          }
        } catch (e) {
          // Error validating token - clear it and go to login
          print('Error validating token: $e');
          await ApiClient.instance.clearToken();
        }
      }

      // No token or invalid token - navigate to login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    } catch (e) {
      // Error checking login - clear token and go to login
      print('Error checking login status: $e');
      await ApiClient.instance.clearToken();
      if (mounted) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    }
  }

  void _navigateToApp(String role, bool isProfileComplete) {
    // This method is no longer needed but kept for compatibility
    // Navigation is now handled directly in _checkLoginStatus
    if (!mounted) return;

    if (isProfileComplete) {
      Navigator.pushReplacementNamed(
        context,
        AppShell.routeName,
        arguments: role,
      );
    } else {
      // Should not reach here - incomplete profiles go to login
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF28BC79), // Custom green color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logos/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'Free Classified Matrimony',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
