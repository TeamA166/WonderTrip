import 'package:flutter/material.dart';
// Import screens
import 'package:flutter_application_wondertrip/onboarding_screen.dart';
import 'package:flutter_application_wondertrip/main_screen.dart'; // Import Main Screen
// Import Auth Service
import 'package:flutter_application_wondertrip/services/auth_service.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  bool _isTransitioning = false;
  
  // Variable to store login status
  bool? _isLoggedIn; 

  @override
  void initState() {
    super.initState();
    
    // 1. Check Session immediately when screen loads
    _checkLoginStatus();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  // Helper function to check auth
  Future<void> _checkLoginStatus() async {
    final authService = AuthService();
    bool loggedIn = await authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  // MODIFIED NAVIGATION FUNCTION
  void _handleNavigation() {
    // Wait for animation to be ready AND for login check to finish
    if (_scaleAnimation.value >= 1.0 && !_isTransitioning && _isLoggedIn != null) {
        
        setState(() => _isTransitioning = true);

        // 2. Decide where to go
        if (_isLoggedIn == true) {
          // User is logged in -> Go to Main Screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // User is NOT logged in -> Go to Onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxDimension = screenSize.width > screenSize.height 
        ? screenSize.width 
        : screenSize.height;
    final double circleSize = maxDimension * 2.0; 

    return GestureDetector(
      onTap: _handleNavigation, // Call the intelligent navigation
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E0E0),
        body: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF0C7489),
                    shape: OvalBorder(),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: _scaleAnimation.value > 1.0 ? 1.0 : 0.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center, 
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo.png', 
                            width: 250, 
                            height: 250, 
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}