import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/new_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  // ✅ Email parametresi eklendi
  final String? email;
  const VerificationScreen({super.key, this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

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

  void _showResultPopup(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(success ? "Success" : "Error", textAlign: TextAlign.center),
        content: Text(
          success ? "Verification code is correct!" : "Invalid code. Please enter all 6 digits correctly.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success && mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NewPasswordScreen())
                );
              }
            },
            child: const Center(child: Text("OK", style: TextStyle(fontSize: 18))),
          )
        ],
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
              if (widget.email != null) ...[
                const SizedBox(height: 10),
                Text(
                  "Sent to ${widget.email}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildCodeBox(index)),
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () {
                  String fullCode = _controllers.map((e) => e.text).join();
                  if (fullCode.length == 6) {
                    _showResultPopup(true);
                  } else {
                    _showResultPopup(false);
                  }
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB8F67),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
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
      width: 44,
      height: 44,
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
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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