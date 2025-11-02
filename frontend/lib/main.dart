import 'package:flutter/material.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/loading_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system, // Automatically use light/dark mode
      debugShowCheckedModeBanner: false,

      // This is how we set up navigation.
      // We are defining "routes" (pages) for our app.
      initialRoute: '/', // The first route to show is the 'LoadingScreen'
      routes: {
        // When the app launches, show the LoadingScreen
        '/': (context) => const LoadingScreen(),
        // When we navigate to '/home', show the HomeScreen
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

