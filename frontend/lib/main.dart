import 'package:flutter/material.dart';
// Yeni dosyayı içeri aktardık.
import 'package:flutter_application_wondertrip/splash_screen.dart'; 

// Ana fonksiyon: Uygulamanın başlangıç noktası
void main() {
  runApp(const MyApp());
}

// Uygulamanın temel widget'ı
class MyApp extends StatelessWidget {
  // Const yapıcı metot (constructor) doğru
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp const olabilir, ancak home özelliği const olamaz.
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki "Debug" yazısını kaldırır
      title: 'Wonder Trip App',
      // Uygulamanın ilk açılacak ekranı Splash Screen'dir.
      home: AnimatedSplashScreen(), 
    );
  }
}