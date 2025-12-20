import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/login_screen.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart'; // Import Service

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  
  final AuthService _authService = AuthService(); // Initialize Service
  bool _isLoading = false;

  Future<void> _handlePasswordReset() async {
    final newPass = _passController.text;
    final confirmPass = _confirmPassController.text;

    // 1. Validation
    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showMessage("Please fill in both fields.", isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showMessage("Passwords do not match.", isError: true);
      return;
    }

    if (newPass.length < 6) {
      _showMessage("Password must be at least 6 characters.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // 2. Call Backend
    final success = await _authService.resetPassword(newPass);

    if (!mounted) return;

    if (success) {
      _showMessage("Password reset successfully!", isError: false);
      
      // Wait a moment so user sees the message, then navigate
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;

      // 3. Navigate to Login (Clear history so they can't go back)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      _showMessage("Session expired or server error. Please try again.", isError: true);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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
              const SizedBox(height: 80),
              const Text(
                'Create New Password',
                style: TextStyle(color: Color(0xFFF6F6F6), fontSize: 28, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your new password must be different from previous used passwords.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50),
              
              _buildLabel("New Password"),
              _buildPasswordField(_passController),
              const SizedBox(height: 20),
              
              _buildLabel("Confirm Password"),
              _buildPasswordField(_confirmPassController),
              const SizedBox(height: 50),
              
              GestureDetector(
                onTap: _isLoading ? null : _handlePasswordReset,
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
                        'Reset Password', 
                        style: TextStyle(color: Color(0xFF212121), fontSize: 22, fontWeight: FontWeight.w700)
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
  
  // ... _buildLabel and _buildPasswordField helpers remain the same ...
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPasswordField(TextEditingController controller) {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: const Color(0xFFBC9B8F), borderRadius: BorderRadius.circular(28)),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}