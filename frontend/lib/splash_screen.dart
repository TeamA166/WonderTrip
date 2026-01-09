import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/onboarding_screen.dart';
import 'package:flutter_application_wondertrip/main_screen.dart';
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
  
  // Three states: null (loading), true (valid), false (invalid)
  bool? _isSessionValid; 

  @override
  void initState() {
    super.initState();
    
    // Start Animation and Check simultaneously
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    
    // Check with server
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authService = AuthService();
    // This now ping the server to verify the cookie
    bool isValid = await authService.validateSession();
    
    if (mounted) {
      setState(() {
        _isSessionValid = isValid;
      });
      
      // OPTIONAL: Auto-navigate when check is done?
      // If you want auto-navigation, uncomment the line below:
      // _handleNavigation(); 
    }
  }

  void _handleNavigation() {
    // If the check is still running, show a message or wait
    if (_isSessionValid == null) {
      print("Still checking session...");
      return; 
    }

    if (_scaleAnimation.value >= 1.0) {
        if (_isSessionValid == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
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
    // Calculate dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double maxDimension = screenSize.width > screenSize.height 
        ? screenSize.width : screenSize.height;
    final double circleSize = maxDimension * 2.0; 

    return GestureDetector(
      onTap: _handleNavigation, 
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
                      // Only show logo when animation finishes
                      opacity: _scaleAnimation.value > 1.0 ? 1.0 : 0.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/logo.png', width: 250, height: 250),
                          // Optional: Show loading indicator if check is slow
                          if (_isSessionValid == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: CircularProgressIndicator(color: Colors.white),
                            )
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