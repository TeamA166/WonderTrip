import 'package:flutter/material.dart';

// ✅ LOGIN VE SIGNUP IMPORTLARI KESİNLEŞTİRİLDİ
import 'package:flutter_application_wondertrip/login_screen.dart'; 
import 'package:flutter_application_wondertrip/signup_screen.dart'; 

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  // Buton Fonksiyonu: Yeni bir ekrana geçişi sağlar
  void _goToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double defaultPadding = screenSize.width * 0.1; // %10 marjin (Responsive)

    return Scaffold(
      // Ekranın üst kısmındaki zaman/pil göstergesini yöneten AppBar'ı gizler
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: const Color(0xFF119DA4), // Tema rengi
          elevation: 0,
        ),
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF119DA4), // Turkuaz arka plan
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            
            // 🖼️ Üst Görsel (start.png) - Responsive Konumlandırma
            Positioned(
              left: screenSize.width * 0.05,
              right: screenSize.width * 0.05,
              top: screenSize.height * 0.1, // %10 yukardan başla
              child: Image.asset(
                'assets/images/start.png', // Görsel yolu güncellendi (assets/images)
                fit: BoxFit.contain, // Görseli orantılı sığdır
                height: screenSize.height * 0.3, // Ekranın %30'u
              ),
            ),
            
            // 1. Başlık: 'Hello, Welcome !'
            Positioned(
              left: defaultPadding,
              right: defaultPadding,
              top: screenSize.height * 0.45, 
              child: const Text(
                'Hello, Welcome !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF6F6F6),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // 2. Açıklama: 'Time to get started'
            Positioned(
              left: defaultPadding,
              right: defaultPadding,
              top: screenSize.height * 0.52, 
              child: const Text(
                'Time to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            // 3. Login Butonu
            Positioned(
              left: defaultPadding,
              right: defaultPadding,
              top: screenSize.height * 0.62, // %62 yükseklik
              child: GestureDetector(
                onTap: () => _goToScreen(context, const LoginScreen()),
                child: Container(
                  height: 56, // Sabit yükseklik
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB8F67), // Turuncu renk
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
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
            
            // 4. Sign up Butonu
            Positioned(
              left: defaultPadding,
              right: defaultPadding,
              top: screenSize.height * 0.72, // %72 yükseklik
              child: GestureDetector(
                onTap: () => _goToScreen(context, const SignupScreen()),
                child: Container(
                  height: 56, // Sabit yükseklik
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB8F67), // Turuncu renk
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign up',
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
          ],
        ),
      ),
    );
  }
}