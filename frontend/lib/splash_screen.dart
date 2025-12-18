import 'package:flutter/material.dart';

// OnboardingScreen'a geçiş için bu import'u kullanıyoruz:
import 'package:flutter_application_wondertrip/onboarding_screen.dart'; 


class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  // Geçişin birden fazla kez tetiklenmesini engellemek için bayrak
  bool _isTransitioning = false; 

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animasyonun değer aralığını ayarla (0.0'dan 1.5 katına büyüme)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut, // Yumuşak geçiş
      ),
    );

    _controller.forward();
    
    // Not: Otomatik geçiş kodu kaldırılmıştır. Geçiş, onTap ile manuel yapılır.
  }

  // MANUEL GEÇİŞ FONKSİYONU: Ekrana dokunulduğunda çalışır
  void _goToOnboarding() {
    // Sadece animasyon bittiyse ve daha önce geçiş başlamadıysa çalıştır
    // Animasyonun bittiğini anlamak için animasyon değerini kontrol ediyoruz.
    if (_scaleAnimation.value >= 1.0 && !_isTransitioning) {
        _isTransitioning = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(), 
          ),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxDimension = screenSize.width > screenSize.height 
        ? screenSize.width 
        : screenSize.height;
    final double circleSize = maxDimension * 2.0; 

    // ✅ Ana widget'ı GestureDetector ile sarmalıyoruz
    return GestureDetector(
      onTap: _goToOnboarding, // Herhangi bir yere tıklandığında geçişi dene
      child: Scaffold(
        backgroundColor: const Color(0xFFE0E0E0), // Splash1 rengi
        body: Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF0C7489), // Koyu mavi renk
                    shape: OvalBorder(),
                  ),
                  child: Center(
                    // Daire yeterince büyüdüğünde logoyu görünür yap
                    child: Opacity(
                      opacity: _scaleAnimation.value > 1.0 ? 1.0 : 0.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center, 
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // LOGO GÖRSELİ: Doğru yol ve 250x250 boyutunda
                          Image.asset(
                            'assets/images/logo.png', 
                            width: 250, 
                            height: 250, 
                          ),
                          
                          // Ekstra metin/buton/ipucu kaldırılmıştır.
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}