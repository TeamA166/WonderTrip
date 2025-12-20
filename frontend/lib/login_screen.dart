import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_wondertrip/signup_screen.dart';
// 1. Şifremi unuttum ekranını içeri aktarıyoruz
import 'package:flutter_application_wondertrip/forgot_password_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Kontrolcüler
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _rememberMe = false;
  bool _isLoading = false;

  // --- API Giriş Mantığı ---
  Future<void> _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://127.0.0.1:8080/api/v1/auth/login'); 

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Async işlem sonrası mounted kontrolü (Güvenlik için)
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showMessage("Welcome ${data['user']['email']}!");
        // Burada ana sayfaya yönlendirme yapılabilir.
      } else {
        final errorData = jsonDecode(response.body);
        _showMessage(errorData['error'] ?? "Login failed");
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage("Could not connect to server: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final Size screenSize = MediaQuery.of(context).size;
    final double defaultPadding = screenSize.width * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF119DA4),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          child: Stack(
            children: [
              // 1. Başlık
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

              // 2. Alt Başlık
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

              // 3. Email Etiketi
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

              // 4. Email TextField
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

              // 5. Şifre Etiketi
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

              // 6. Şifre TextField
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

              // 7. Beni Hatırla
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

              // 8. Şifremi Unuttum Bağlantısı (Yeni eklendi)
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

              // 9. Giriş Butonu
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

              // 10. Kayıt Ol Bağlantısı
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