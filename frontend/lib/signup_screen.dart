import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_wondertrip/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    final String name = _nameController.text.trim();
    final String surname = _surnameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields.");
      return;
    }
    if (password != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 📡 API isteği başlatılıyor
      final url = Uri.parse('https://api.batuhanalun.com/api/v1/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'surname': surname,
          'email': email,
          'password': password,
        }),
      );

      // ✅ KRİTİK DÜZELTME: Async işlemden sonra mounted kontrolü
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar("Registration successful! Please login.");
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const LoginScreen())
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showSnackBar(errorData['error'] ?? "Signup failed");
      }
    } catch (e) {
      // ✅ KRİTİK DÜZELTME: Hata durumunda da mounted kontrolü
      if (!mounted) return;
      _showSnackBar("Failed to connect to backend.");
    } finally {
      // ✅ KRİTİK DÜZELTME: Durum güncellerken mounted kontrolü
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF119DA4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Create Account Now!', 
                style: TextStyle(color: Color(0xFFF6F6F6), fontSize: 28, fontWeight: FontWeight.w600)
              ),
              const SizedBox(height: 35),
              _buildField("Name", _nameController),
              _buildField("Surname", _surnameController),
              _buildField("Email", _emailController),
              _buildField("Password", _passwordController, isPass: true),
              _buildField("Confirm Password", _confirmPasswordController, isPass: true),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _isLoading ? null : _handleSignup,
                child: Container(
                  height: 56, 
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB8F67), 
                    borderRadius: BorderRadius.circular(28)
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Sign Up', 
                          style: TextStyle(color: Color(0xFF212121), fontSize: 20, fontWeight: FontWeight.w700)
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text.rich(TextSpan(children: [
                    TextSpan(
                      text: 'Already have an account? ', 
                      style: TextStyle(color: Color(0xFFF6F6F6), fontSize: 16)
                    ),
                    TextSpan(
                      text: 'Log In', 
                      style: TextStyle(color: Color(0xFFFB8F67), fontSize: 16, fontWeight: FontWeight.w800)
                    ),
                  ])),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 52, 
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(color: const Color(0xFFBC9B8F), borderRadius: BorderRadius.circular(26)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller, 
              obscureText: isPass, 
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ), 
              style: const TextStyle(color: Colors.white)
            ),
          ),
        ),
      ],
    );
  }
}