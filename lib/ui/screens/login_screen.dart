import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth_api.dart';
import '../../core/socket_service.dart';
import '../shell/app_shell.dart';
import '../screens/complete_profile_screen.dart';
import '../screens/safety_tutorial_screen.dart';
import '../screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authApi = AuthApi();
  final _googleSignIn = GoogleSignIn();
  
  final _emailOrMobileController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Login',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logos/logo_green.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                // Welcome text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to Silah',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Form fields
                if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _emailOrMobileController,
                style: const TextStyle(color: Colors.black87),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email or mobile',
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email or mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.black87),
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isGoogleLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignUpScreen.routeName);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Call login API
      final response = await _authApi.login(
        emailOrMobile: _emailOrMobileController.text.trim(),
        password: _passwordController.text,
      );

      if (response['success'] == true) {
        // Login successful, get user data to determine role
        final userResponse = await _authApi.getMe();
        
        if (userResponse['success'] == true && mounted) {
          final user = userResponse['user'] as Map<String, dynamic>;
          final role = user['role'] as String? ?? 'groom';
          final userId = user['_id'] ?? user['id'];
          
          // Connect socket for real-time messaging
          if (userId != null) {
            try {
              await SocketService().connect(userId: userId.toString());
            } catch (e) {
              print('Socket connection failed: $e');
            }
          }
          
          // Check if safety tutorial needs to be shown
          final prefs = await SharedPreferences.getInstance();
          final tutorialCompleted = prefs.getBool('safety_tutorial_completed') ?? false;
          
          if (!tutorialCompleted && mounted) {
            // Show safety tutorial first
            final tutorialResult = await Navigator.pushNamed(
              context,
              SafetyTutorialScreen.routeName,
            );
            
            // Continue to app after tutorial
            if (mounted && tutorialResult == true) {
              final isProfileComplete = user['isProfileComplete'] as bool? ?? false;
              
              if (isProfileComplete) {
                Navigator.pushReplacementNamed(
                  context,
                  AppShell.routeName,
                  arguments: role,
                );
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  CompleteProfileScreen.routeName,
                  arguments: role,
                );
              }
            }
            return;
          }
          
          // Navigate based on profile completion
          final isProfileComplete = user['isProfileComplete'] as bool? ?? false;
          
          if (isProfileComplete) {
            Navigator.pushReplacementNamed(
              context,
              AppShell.routeName,
              arguments: role,
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              CompleteProfileScreen.routeName,
              arguments: role,
            );
          }
        } else {
          // If getMe fails, still navigate (role will default)
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              CompleteProfileScreen.routeName,
              arguments: 'groom',
            );
          }
        }
      } else {
        // Show error message
        setState(() {
          _errorMessage = response['message'] ?? 'Login failed. Please check your credentials.';
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

  Future<void> _handleGoogleSignIn() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
      _isGoogleLoading = true;
    });

    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled sign-in
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        setState(() {
          _errorMessage = 'Google Sign-In failed. Please try again.';
          _isGoogleLoading = false;
        });
        return;
      }

      // Call backend Google Sign-In API
      final response = await _authApi.googleSignIn(
        idToken: googleAuth.idToken!,
      );

      if (response['success'] == true) {
        // Google Sign-In successful, get user data
        final userResponse = await _authApi.getMe();
        
        if (userResponse['success'] == true && mounted) {
          final user = userResponse['user'] as Map<String, dynamic>;
          final role = user['role'] as String? ?? 'groom';
          final userId = user['_id'] ?? user['id'];
          
          // Connect socket for real-time messaging
          if (userId != null) {
            try {
              await SocketService().connect(userId: userId.toString());
            } catch (e) {
              print('Socket connection failed: $e');
            }
          }
          
          // Check if safety tutorial needs to be shown
          final prefs = await SharedPreferences.getInstance();
          final tutorialCompleted = prefs.getBool('safety_tutorial_completed') ?? false;
          
          if (!tutorialCompleted && mounted) {
            // Show safety tutorial first
            final tutorialResult = await Navigator.pushNamed(
              context,
              SafetyTutorialScreen.routeName,
            );
            
            // Continue to app after tutorial
            if (mounted && tutorialResult == true) {
              final isProfileComplete = user['isProfileComplete'] as bool? ?? false;
              
              if (isProfileComplete) {
                Navigator.pushReplacementNamed(
                  context,
                  AppShell.routeName,
                  arguments: role,
                );
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  CompleteProfileScreen.routeName,
                  arguments: role,
                );
              }
            }
            return;
          }
          
          // Check if profile is complete
          final isProfileComplete = user['isProfileComplete'] as bool? ?? false;
          
          if (isProfileComplete) {
            // Navigate to home
            Navigator.pushReplacementNamed(
              context,
              AppShell.routeName,
              arguments: role,
            );
          } else {
            // Navigate to complete profile
            Navigator.pushReplacementNamed(
              context,
              CompleteProfileScreen.routeName,
              arguments: role,
            );
          }
        } else {
          // If getMe fails, navigate to complete profile
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/complete-profile',
              arguments: 'groom',
            );
          }
        }
      } else {
        // Show error message
        setState(() {
          _errorMessage = response['message'] ?? 'Google Sign-In failed. Please try again.';
          _isGoogleLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during Google Sign-In. Please try again.';
        _isGoogleLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailOrMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

