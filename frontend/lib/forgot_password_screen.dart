import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// Import your service and next screen
import 'package:flutter_application_wondertrip/verification_screen.dart';
import 'package:flutter_application_wondertrip/signup_screen.dart';
import 'services/auth_service.dart'; // Import the service created in Step 2

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService(); // 1. Initialize Service
  bool _isLoading = false;

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. USE THE SERVICE (Cleaner & safer)
    final success = await _authService.requestPasswordReset(email);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code sent! Check your email.'),
          backgroundColor: Colors.green,
        ),
      );

      // 3. CORRECT NAVIGATION
      // This works perfectly to pass the email to the next screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerificationScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection failed. Check if Backend is running.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF119DA4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 30),
              const Text(
                'Forget your password?',
                style: TextStyle(
                    color: Color(0xFFF6F6F6),
                    fontSize: 28,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              const Text(
                'Enter your email address to receive a link to reset your password.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'Enter Email Address',
                  style: TextStyle(
                      color: Color(0xFFF6F6F6),
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 15),
              
              // Email Input
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFBC9B8F),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress, // Added for better UX
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                    hintText: "example@mail.com",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to sign in',
                      style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14)),
                ),
              ),
              const SizedBox(height: 30),
              
              // Send Button with Loading State
              GestureDetector(
                onTap: _isLoading ? null : _handleSendResetLink, // Disable tap if loading
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : const Color(0xFFFB8F67), // Dim color when loading
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) // Show Spinner
                      : const Text(
                          'Send',
                          style: TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        ),
                  ),
                ),
              ),
              
              // ... Rest of your UI (Sign Up link) ...
              const SizedBox(height: 100),
              const Center(
                child: Text(
                  'Do u have an account?', 
                  style: TextStyle(
                    color: Color(0xFFE0E0E0), 
                    fontSize: 16, 
                    fontWeight: FontWeight.w700
                  )
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignupScreen())
                ),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign Up', 
                      style: TextStyle(
                        color: Color(0xFF212121), 
                        fontSize: 22, 
                        fontWeight: FontWeight.w700
                      )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}