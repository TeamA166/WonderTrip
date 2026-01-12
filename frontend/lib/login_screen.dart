import 'package:flutter/material.dart';
// REMOVED: import 'package:http/http.dart' as http; 
// REMOVED: import 'dart:convert'; (Dio handles JSON automatically)

import 'package:flutter_application_wondertrip/signup_screen.dart';
import 'package:flutter_application_wondertrip/main_screen.dart';
import 'package:flutter_application_wondertrip/forgot_password_screen.dart'; 

// 1. Import AuthService
import 'services/auth_service.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 2. Initialize Service
  final AuthService _authService = AuthService();
  
  bool _rememberMe = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    // 3. Use AuthService instead of http
    final responseData = await _authService.login(email, password);

    if (!mounted) return;

    if (responseData != null && !responseData.containsKey('error')) {
      // SUCCESS
      // The session cookie is now safely stored in AuthService's CookieJar!
      
      // Extract email safely (backend sends: {"user": {"email": "..."}})
      String userEmail = email;
      if (responseData['user'] != null && responseData['user']['email'] != null) {
        userEmail = responseData['user']['email'];
      }

      _showMessage("Welcome $userEmail!");
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // FAILURE
      String errorMsg = "Login failed";
      if (responseData != null && responseData['error'] != null) {
        errorMsg = responseData['error'];
      }
      _showMessage(errorMsg);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... YOUR UI CODE REMAINS EXACTLY THE SAME ...
    // ... COPY THE REST OF THE BUILD METHOD FROM YOUR PREVIOUS CODE ...
    final Size screenSize = MediaQuery.of(context).size;
    final double defaultPadding = screenSize.width * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF119DA4),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          child: Stack(
            children: [
              // 1. Title
              Positioned(
                left: 15,
                top: screenSize.height * 0.12,
                child: const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Color(0xFFF6F6F6),
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // 2. Subtitle
              Positioned(
                left: 15,
                top: screenSize.height * 0.17,
                child: const Text(
                  'Sign in to continue where you left off',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // 3. Email Label
              Positioned(
                left: defaultPadding,
                top: screenSize.height * 0.25,
                child: const Text(
                  'Email',
                  style: TextStyle(
                    color: Color(0xFFF6F6F6),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // 4. Email Input
              Positioned(
                left: defaultPadding,
                right: defaultPadding,
                top: screenSize.height * 0.29,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC9B8F),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "example@mail.com",
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),

              // 5. Password Label
              Positioned(
                left: defaultPadding,
                top: screenSize.height * 0.38,
                child: const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFFF6F6F6),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // 6. Password Input
              Positioned(
                left: defaultPadding,
                right: defaultPadding,
                top: screenSize.height * 0.42,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC9C90),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),

              // 7. Remember Me
              Positioned(
                left: defaultPadding,
                top: screenSize.height * 0.51,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? newValue) {
                          setState(() => _rememberMe = newValue ?? false);
                        },
                        activeColor: const Color(0xFFFB8F67),
                        checkColor: const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remember me',
                      style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14),
                    ),
                  ],
                ),
              ),

              // 8. Forgot Password
              Positioned(
                right: defaultPadding,
                top: screenSize.height * 0.51 + 4,
                child: GestureDetector(
                  onTap: () => _goToScreen(context, const ForgotPasswordScreen()),
                  child: const Text(
                    'Forget password?',
                    style: TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // 9. Login Button
              Positioned(
                left: defaultPadding,
                right: defaultPadding,
                top: screenSize.height * 0.60,
                child: GestureDetector(
                  onTap: _isLoading ? null : _handleLogin,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.grey : const Color(0xFFFB8F67),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                  ),
                ),
              ),

              // 10. Sign Up
              Positioned(
                left: defaultPadding,
                right: defaultPadding,
                top: screenSize.height * 0.70,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _goToScreen(context, const SignupScreen()),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Don’t have an account? ',
                            style: TextStyle(color: Color(0xFFF6F6F6), fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(color: Color(0xFFFB8F67), fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}