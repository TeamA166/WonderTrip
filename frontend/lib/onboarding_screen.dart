import 'package:flutter/material.dart';
// Doğru ekranı import ediyoruz
import 'package:flutter_application_wondertrip/start_screen.dart'; 

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Buton Fonksiyonu: StartScreen'a geçişi sağlar
  void _goToNextScreen(BuildContext context) {
    // Geçiş animasyonu olmadan (pushReplacement) StartScreen'ı açar
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const StartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    // ✅ RESPONSIVE FONT BOYUTLARI
    final double titleFontSize = screenSize.width * 0.085; 
    final double bodyFontSize = screenSize.width * 0.045; 
    final double buttonFontSize = screenSize.width * 0.055; 
    final double defaultMargin = screenSize.width * 0.05; // %5 marjin

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6), // Hex formatı düzeltildi: 0xFFF6F6F6
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            // 🖼️ Onboarding Görseli
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/onboarding.png', 
                fit: BoxFit.cover,
                height: screenSize.height * 0.55, 
              ),
            ),

            // 👇 Metin ve Butonları Ortalamak İçin Yeni Yapı (Positioned yerine Column)
            Positioned(
              left: defaultMargin,
              right: defaultMargin,
              top: screenSize.height * 0.60, // Metin bloğunun başlangıç konumu
              child: Column(
                mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar yer kapla
                crossAxisAlignment: CrossAxisAlignment.start, // Metni sola hizala
                children: [
                  // 1. Başlık: 'Discover, Share, Wonder'
                  Text(
                    'Discover, Share, Wonder',
                    style: TextStyle(
                      color: const Color(0xFF212121),
                      fontSize: titleFontSize, 
                      fontWeight: FontWeight.w600,
                      height: 1.2, // ✅ SATIR YÜKSEKLİĞİ DÜZELTİLDİ (Discover/Wonder arası açıldı)
                    ),
                  ),

                  // 📏 BAŞLIK VE AÇIKLAMA ARASINDAKİ MESAFA
                  SizedBox(height: screenSize.height * 0.02), // %2 yükseklik boşluğu

                  // 2. Açıklama: 'Share your memories...'
                  Text(
                    'Share your memories, discover new ones,\nand make every trip unforgettable.',
                    style: TextStyle(
                      color: const Color(0xFF616161),
                      fontSize: bodyFontSize, 
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // 📏 AÇIKLAMA VE BUTON ARASINDAKİ MESAFA
                  SizedBox(height: screenSize.height * 0.05), // %5 yükseklik boşluğu

                  // 3. Buton (Container)
                  GestureDetector(
                    onTap: () => _goToNextScreen(context), // Tıklama fonksiyonu StartScreen'a gidiyor
                    child: Container(
                      width: screenSize.width * 0.58, // %58 genişlik
                      height: 60, // Yüksekliği 70'ten 60'a indirdik
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C7489),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          'Let’s Go',
                          style: TextStyle(
                            // Renk formatı düzeltildi: 0xFFF6F6F6
                            color: const Color(0xFFF6F6F6), 
                            fontSize: buttonFontSize, 
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}