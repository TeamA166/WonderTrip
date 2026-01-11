import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/splash_screen.dart';
// Import AuthService to initialize it
import 'package:flutter_application_wondertrip/services/auth_service.dart'; 

void main() async {
  // 1. Ensure Flutter engine is ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the saved cookies from the disk
  await AuthService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wonder Trip App',
      home: AnimatedSplashScreen(), 
    );
  }
}