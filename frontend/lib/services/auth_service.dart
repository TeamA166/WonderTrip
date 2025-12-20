import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart'; // <--- YOU MISSED THIS IMPORT

class AuthService {
  // 1. Define Base URL
  // We use a getter so it calculates the correct URL dynamically based on the platform
  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8080/api/v1/auth"; // Web
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 is the special IP Android Emulators use to reach your computer
      return "http://10.0.2.2:8080/api/v1/auth"; 
    } else {
      return "http://127.0.0.1:8080/api/v1/auth"; // iOS Simulator
    }
  }

  // 2. Create Singletons (Static)
  static final Dio _dio = Dio();
  static final CookieJar _cookieJar = CookieJar();
  static bool _configured = false;

  // 3. Constructor
  AuthService() {
    if (!_configured) {
      // For Web support, we cannot use CookieManager (browser handles it).
      // For Mobile, we MUST use CookieManager.
      if (!kIsWeb) {
        _dio.interceptors.add(CookieManager(_cookieJar));
      } else {
        // This tells the browser to include cookies in requests
        _dio.options.extra['withCredentials'] = true; 
      }
      
      _dio.options.connectTimeout = const Duration(seconds: 5);
      _dio.options.receiveTimeout = const Duration(seconds: 3);
      
      _configured = true;
    }
  }

  // --- API METHODS ---

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/forgot-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      // Print the full error to debug console if connection fails
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
}