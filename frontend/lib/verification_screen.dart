import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/new_password_screen.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart'; // Import Service

class VerificationScreen extends StatefulWidget {
  final String email; // 1. Add email variable

  // 2. Require email in constructor
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  
  final AuthService _authService = AuthService(); // Initialize Service
  bool _isLoading = false; // Loading state

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Real API Call Logic
  Future<void> _handleVerification() async {
    // Combine the 6 boxes into one string
    String fullCode = _controllers.map((e) => e.text).join();

    if (fullCode.length != 6) {
      _showError("Please enter all 6 digits.");
      return;
    }

    setState(() => _isLoading = true);

    // Call Backend
    final success = await _authService.verifyCode(widget.email, fullCode);

    if (!mounted) return;

    if (success) {
      // If successful, the Backend set a Cookie.
      // We can now move to the New Password Screen.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NewPasswordScreen())
      );
    } else {
      _showError("Invalid or expired code. Please try again.");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white), 
                    onPressed: () => Navigator.pop(context)
                  ),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF6F6F6), 
                  fontSize: 28, 
                  fontWeight: FontWeight.w600
                ),
              ),
              const SizedBox(height: 10),
              // Show the user which email they are verifying for (Good UX)
              Text(
                'Sent to ${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildCodeBox(index)),
              ),
              
              const SizedBox(height: 60),

              GestureDetector(
                // Disable button if loading
                onTap: _isLoading ? null : _handleVerification,
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
                      'Verify', 
                      style: TextStyle(
                        color: Color(0xFF212121), 
                        fontSize: 22, 
                        fontWeight: FontWeight.w700
                      )
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

  Widget _buildCodeBox(int index) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9), 
        shape: BoxShape.circle,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        decoration: const InputDecoration(
          border: InputBorder.none, 
          counterText: ""
        ),
        onTap: () {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].value.text.length,
          );
        },
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (value.length > 1) {
              _controllers[index].text = value.substring(value.length - 1);
            }
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }
}