import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Kontrolcüler: Form verilerini yönetmek için
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Kayıt işlemi tetiklendiğinde çalışacak fonksiyon
  void _handleSignup() {
    final String name = _nameController.text.trim();
    final String surname = _surnameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Basit doğrulama kontrolleri
    if (name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Lütfen tüm alanları doldurun.");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Şifreler uyuşmuyor!");
      return;
    }

    // Konsol çıktısı ile verilerin alındığını doğruluyoruz
    debugPrint("Kayıt Bilgileri: $name $surname, Email: $email");

    // NOT: BURAYA İLERİDE API BAĞLANTISI EKLENECEK
    _showSnackBar("Kayıt başarılı! API bağlantısı bekleniyor.");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Yardımcı Widget: Giriş balonlarını oluşturur
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFF6F6F6),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 18.0),
          decoration: BoxDecoration(
            color: const Color(0xFFBC9B8F),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: const InputDecoration(
                // Dikey Ortalama: contentPadding ile yazı kutunun ortasına gelir
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
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
                style: TextStyle(
                  color: Color(0xFFF6F6F6),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Start your journey now by creating an account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 35),

              // Form Alanları
              _buildInputField(label: "Name", controller: _nameController),
              _buildInputField(label: "Surname", controller: _surnameController),
              _buildInputField(label: "Email", controller: _emailController),
              _buildInputField(label: "Password", controller: _passwordController, isPassword: true),
              _buildInputField(label: "Confirm Password", controller: _confirmPasswordController, isPassword: true),

              const SizedBox(height: 15),

              // Sign Up Butonu
              GestureDetector(
                onTap: _handleSignup,
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB8F67),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF212121),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Giriş Linki
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Color(0xFFF6F6F6), fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(color: Color(0xFFFB8F67), fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}