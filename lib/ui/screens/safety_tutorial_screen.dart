import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafetyTutorialScreen extends StatefulWidget {
  const SafetyTutorialScreen({super.key});
  static const routeName = '/safety-tutorial';

  @override
  State<SafetyTutorialScreen> createState() => _SafetyTutorialScreenState();
}

class _SafetyTutorialScreenState extends State<SafetyTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<SafetyTip> _tips = [
    SafetyTip(
      icon: Icons.security,
      title: 'Never Share Personal Information',
      description: 'Never share your OTP, bank details, passwords, or any financial information with anyone on the platform.',
      color: Colors.red,
    ),
    SafetyTip(
      icon: Icons.block,
      title: 'Block Suspicious Users',
      description: 'If someone makes you uncomfortable or asks for money, block them immediately. You can block users from their profile or chat.',
      color: Colors.orange,
    ),
    SafetyTip(
      icon: Icons.flag,
      title: 'Report Inappropriate Behavior',
      description: 'Report users who send inappropriate messages, ask for money, or violate our community guidelines. We take all reports seriously.',
      color: Colors.purple,
    ),
    SafetyTip(
      icon: Icons.phone_locked,
      title: 'Keep Contact Private',
      description: 'Use our in-app messaging system. Only share your contact details after you\'ve met in person and feel comfortable.',
      color: Colors.blue,
    ),
    SafetyTip(
      icon: Icons.verified_user,
      title: 'Verify Before Meeting',
      description: 'Always verify the person\'s identity before meeting. Meet in public places and inform a friend or family member about your meeting.',
      color: Colors.green,
    ),
    SafetyTip(
      icon: Icons.money_off,
      title: 'We Never Ask for Money',
      description: 'Silah or our representatives will NEVER ask you for money, OTP, or bank details. If someone claims to be from Silah and asks for money, it\'s a scam.',
      color: Colors.red,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('safety_tutorial_completed', true);
    
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Safety Guide',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_currentPage < _tips.length - 1)
            TextButton(
              onPressed: _completeTutorial,
              child: Text(
                'Skip',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(
                _tips.length,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < _tips.length - 1 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _tips.length,
              itemBuilder: (context, index) {
                final tip = _tips[index];
                return _buildTipPage(tip, theme);
              },
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentPage > 0 ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _tips.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeTutorial();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage < _tips.length - 1 ? 'Next' : 'Got it!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipPage(SafetyTip tip, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tip.icon,
              size: 60,
              color: tip.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            tip.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            tip.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: tip.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: tip.color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Remember: Your safety is our priority',
                    style: TextStyle(
                      fontSize: 14,
                      color: tip.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SafetyTip {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  SafetyTip({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
