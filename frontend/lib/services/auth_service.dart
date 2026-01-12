import 'dart:io'; // Required for Directory/File access on Android/iOS
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  // 1. Define Base URL
  String get baseUrl {
    if (kIsWeb) {
      return "https://api.batuhanalun.com//api/v1/auth"; // Web-http://localhost:8080/api/v1/auth
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return "https://api.batuhanalun.com/api/v1/auth"; // Android Emulator-http://10.0.2.2:8080/api/v1/auth"
    } else {
      return "https://api.batuhanalun.com/api/v1/auth"; // iOS Simulator-http://127.0.0.1:8080/api/v1/auth
    }
  }

  // 2. Create Singletons
  static final Dio _dio = Dio();
  
  // CHANGED: Use PersistCookieJar to save to disk (Mobile only)
  static late PersistCookieJar _cookieJar; 
  static bool _configured = false;

  // 3. INITIALIZATION (Must call this in main.dart)
  static Future<void> init() async {
    if (_configured) return;

    if (!kIsWeb) {
      // Mobile: Save cookies to the app's secure documents folder
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;

      _cookieJar = PersistCookieJar(
        storage: FileStorage("$appDocPath/.cookies/"),
      );

      _dio.interceptors.add(CookieManager(_cookieJar));
    } else {
      // Web: The browser handles cookies automatically.
      // We just need to tell Dio to allow credentials.
      _dio.options.extra['withCredentials'] = true;
    }

    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    
    _configured = true;
  }

  // --- API METHODS ---

  // Check if User is already logged in (Has valid cookies on disk)
  Future<bool> isLoggedIn() async {
    if (kIsWeb) return false; // On Web, you usually rely on the backend returning 401
    
    // Load cookies for our Base URL
    // If the list is not empty, it means we have a session saved
    final uri = Uri.parse(baseUrl);
    final cookies = await _cookieJar.loadForRequest(uri);
    
    return cookies.isNotEmpty;
  }

  // Logout (Clear cookies from disk)
  Future<void> logout() async {
    if (!kIsWeb) {
      await _cookieJar.deleteAll();
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/forgot-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Request Error on $baseUrl: $e");
      return false;
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '$baseUrl/verify-code',
        data: {'email': email, 'code': code},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Verify Error: $e");
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    try {
      final response = await _dio.post(
        '$baseUrl/reset-password',
        data: {'new_password': newPassword},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Reset Error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login', 
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data; 
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response?.data; 
      }
      print("Login Error: $e");
      return null;
    }
  }
}