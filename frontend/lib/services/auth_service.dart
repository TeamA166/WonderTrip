import 'dart:io'; // Required for Directory/File access on Android/iOS
import 'dart:typed_data'; // Required for Uint8List (Images)
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  // 1. Define Base URL (Points to /auth group)
  String get baseUrl {
      // 1. Web: localhost works fine
      if (kIsWeb) {
        return "https://api.batuhanalun.com/api/v1/auth"; 
      } 
      // 2. Android Emulator: Must use special IP 10.0.2.2 to reach host machine
      else if (defaultTargetPlatform == TargetPlatform.android) {
        return "https://api.batuhanalun.com/api/v1/auth"; 
      } 
      // 3. iOS Simulator: Uses localhost (127.0.0.1)
      else {
        return "https://api.batuhanalun.com/api/v1/auth"; 
      }
    }

  // 2. Create Singletons
  static final Dio _dio = Dio();
  
  // Use PersistCookieJar to save to disk (Mobile only)
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
      _dio.options.extra['withCredentials'] = true;
    }

    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    _configured = true;
  }

  // --- AUTH METHODS ---

  // Check if User is already logged in (Has valid cookies on disk)
  Future<bool> isLoggedIn() async {
    if (kIsWeb) return false; 
    
    final uri = Uri.parse(baseUrl);
    final cookies = await _cookieJar.loadForRequest(uri);
    
    return cookies.isNotEmpty;
  }

  // Check if session is actually valid on server
  Future<bool> validateSession() async {
    try {
      if (!kIsWeb) {
        final uri = Uri.parse(baseUrl);
        final cookies = await _cookieJar.loadForRequest(uri);
        if (cookies.isEmpty) return false; 
      }

      // Calls: .../api/v1/auth/me
      final response = await _dio.get('$baseUrl/me');

      if (response.statusCode == 200) {
        return true; 
      }
      
      await logout();
      return false;

    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          print("Session expired. Logging out.");
          await logout(); 
          return false;
        }
      }
      print("Validation Error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    if (!kIsWeb) {
      await _cookieJar.deleteAll();
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

  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/forgot-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Request Error: $e");
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

  // --- POSTS & IMAGE METHODS (NEW) ---

  // 1. Get Verified Posts (Public Feed)
  // Calls: .../api/v1/posts
  Future<List<Post>> getVerifiedPosts({int page = 1}) async {
    try {
      // Logic: Strip "/auth" and replace with "/posts"
      // Current baseUrl: .../api/v1/auth
      // Target URL: .../api/v1/posts
      final publicUrl = baseUrl.replaceAll("/auth", "/protected");

      final response = await _dio.get(
        '$publicUrl/posts',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching verified posts: $e");
      return [];
    }
  }

  // 2. Get Unverified Posts (Admin Protected)
  // Calls: .../api/v1/protected/posts/unverified
  Future<List<Post>> getUnverifiedPosts({int page = 1}) async {
    try {
      // Logic: Strip "/auth" and replace with "/protected"
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected"); 
      
      final response = await _dio.get(
        '$protectedUrl/posts/unverified',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching unverified posts: $e");
      return [];
    }
  }

  // 3. Fetch Secure Image Bytes
  // Calls: .../api/v1/protected/posts/photo/:filename
  Future<Uint8List?> getPostImageBytes(String filename) async {
    if (filename.isEmpty) return null;
    
    // Safety: Get just the filename (e.g. "abc.jpg")
    final cleanName = filename.split('/').last; 
    
    // Logic: Switch to protected route
    final protectedUrl = baseUrl.replaceAll("/auth", "/protected");

    try {
      final response = await _dio.get(
        '$protectedUrl/posts/photo/$cleanName',
        options: Options(responseType: ResponseType.bytes), // Return Bytes
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      print("Error loading image $cleanName: $e");
      return null;
    }
  }

    Future<Map<String, dynamic>?> getProfile() async {
    try {
      // Uses the protected endpoint to get user details
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.get('$protectedUrl/profile');

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  Future<Uint8List?> getProfileImageBytes() async {
    try {
      // Switch from /auth to /protected
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      
      final response = await _dio.get(
        '$protectedUrl/profile-photo',
        options: Options(responseType: ResponseType.bytes), // Important: Get raw bytes
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching profile photo: $e");
      return null;
    }
  }
  // Update User Profile
  Future<bool> updateProfile(String firstName, String lastName, String email) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      
      final response = await _dio.put(
        '$protectedUrl/profile',
        data: {
          'name': firstName,
          'surname': lastName,
          'email': email,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Profile Error: $e");
      return false;
    }
  }
  // Upload Profile Photo
  Future<bool> uploadProfilePhoto(File imageFile) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      
      String fileName = imageFile.path.split('/').last;

      // Create FormData
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        '$protectedUrl/profile-photo',
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Photo Upload Error: $e");
      return false;
    }
  }
  // Change Password
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      
      final response = await _dio.put(
        '$protectedUrl/password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return null; // Success (null error)
      } else {
        return "Unknown error";
      }
    } catch (e) {
      if (e is DioException) {
        return e.response?.data['error'] ?? "Connection failed";
      }
      return e.toString();
    }
  }
  // Get logged-in user's posts
  Future<List<Post>> getMyPosts() async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.get('$protectedUrl/posts/me');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Get My Posts Error: $e");
      return [];
    }
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.delete('$protectedUrl/posts/$postId');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Delete Error: $e");
      return false;
    }
  }

  // Update a post (Simple text update)
// Update Post (Handles Optional Photo)
  Future<bool> updatePost(String postId, String title, String description, int rating, String coordinates, File? newPhoto) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");

      // Prepare data
      Map<String, dynamic> map = {
        'title': title,
        'description': description,
        'rating': rating,
        'coordinates': coordinates,
      };

      // If a new photo is provided, add it to the FormData
      if (newPhoto != null) {
        String fileName = newPhoto.path.split('/').last;
        map['photo'] = await MultipartFile.fromFile(newPhoto.path, filename: fileName);
      }

      FormData formData = FormData.fromMap(map);

      final response = await _dio.put(
        '$protectedUrl/posts/$postId',
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Post Error: $e");
      return false;
    }
  }
  Future<bool> publishPost(String title, String description, int rating, String coordinates, File photo) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      
      String fileName = photo.path.split('/').last;

      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'rating': rating,
        'coordinates': coordinates,
        'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
      });

      final response = await _dio.post(
        '$protectedUrl/posts', // Assuming route is POST /api/v1/protected/posts
        data: formData,
      );

      return response.statusCode == 201; // Created
    } catch (e) {
      debugPrint("Publish Post Error: $e");
      return false;
    }
  }
  // Get Comments
  Future<List<Comment>> getComments(String postId) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.get('$protectedUrl/posts/$postId/comments');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Get Comments Error: $e");
      return [];
    }
  }

  // Add Comment
  Future<bool> addComment(String postId, String content) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.post(
        '$protectedUrl/posts/$postId/comments',
        data: {'content': content},
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Add Comment Error: $e");
      return false;
    }
  }
  Future<Uint8List?> getCommenterPhotoBytes(String photoPath) async {
    try {
      if (photoPath.isEmpty) return null;

      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      String cleanFileName = photoPath.split('/').last;

      // Call the NEW endpoint we just made in Go
      final response = await _dio.get(
        '$protectedUrl/users/photos/$cleanFileName',
        options: Options(responseType: ResponseType.bytes),
      );
      
      return Uint8List.fromList(response.data);
    } catch (e) {
      return null; // Return null on error so we show a default icon
    }
  }
  // ✅ NEW: Fetch all public posts (for the Map)
  Future<List<Post>> getPosts() async {
    try {
      // Assuming public posts are at /public/posts or similar.
      // If your backend protects feed, verify the endpoint.
      // Here we assume it uses the same structure as "My Posts" but fetches the feed.
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      
      final response = await _dio.get('$protectedUrl/posts'); // Or '/public/posts' depending on your backend

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Get All Posts Error: $e");
      return [];
    }
  }
  // Check if a post is favorited
  Future<bool> isPostFavorited(String postId) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.get('$protectedUrl/posts/$postId/favorite');
      return response.data['is_favorite'] == true;
    } catch (e) {
      return false;
    }
  }

  // Toggle Favorite (Add/Remove)
  Future<bool> toggleFavorite(String postId) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.post('$protectedUrl/posts/$postId/favorite');
      return response.data['is_favorite'] == true;
    } catch (e) {
      debugPrint("Toggle Fav Error: $e");
      return false; // Assume false on error
    }
  }
  Future<List<Post>> getFavoritePosts() async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.get('$protectedUrl/favorites');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Get Favorites Error: $e");
      return [];
    }
  }
  Future<List<Post>> getPostsByUser(String userId) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.get('$protectedUrl/users/$userId/posts');
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  Future<List<Post>> getFeed({int page = 1, int limit = 10}) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      
      // Points to the NEW /feed endpoint
      final response = await _dio.get(
        '$protectedUrl/feed',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Get Feed Error: $e");
      return [];
    }
  }
  Future<bool> toggleLike(String postId) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.post('$protectedUrl/posts/$postId/like');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<bool> isPostLiked(String postId) async {
    try {
      final protectedUrl = baseUrl.replaceAll("/auth", "/protected");
      final response = await _dio.get('$protectedUrl/posts/$postId/like');
      return response.data['is_liked'] == true;
    } catch (e) {
      return false;
    }
  }
}

// --- DATA MODEL ---

class Post {
  final String id;
  final String userId; // Make sure this is here
  final String title;
  final String description;
  final int rating;
  final String coordinates;
  final String photoPath;
  final bool verified;
  final String userName;      // ✅ NEW
  final String userPhotoPath; // ✅ NEW
  final bool isFavorited; // This is now "Bookmark"
  final bool isLiked;     // ✅ NEW: Heart
  final int likeCount;    // ✅ NEW

  Post({
    required this.id, required this.userId, required this.title, required this.description,
    required this.rating, required this.coordinates, required this.photoPath, required this.verified,
    required this.userName, required this.userPhotoPath,
    required this.isFavorited,
    required this.isLiked,
    required this.likeCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      rating: json['rating'],
      coordinates: json['coordinates'] ?? "",
      photoPath: json['photo_path'],
      verified: json['verified'] ?? false,
      userName: json['user_name'] ?? "Unknown",        // ✅ NEW
      userPhotoPath: json['user_photo_path'] ?? "",     // ✅ NEW
      isFavorited: json['is_favorited'] ?? false,
      isLiked: json['is_liked'] ?? false,        // ✅ NEW
      likeCount: json['like_count'] ?? 0,        // ✅ NEW
    );
  }
}
class Comment {
  final String id;
  final String content;
  final String userName;
  final String userPhotoPath; // ✅ ADD THIS
  final String createdAt;

  Comment({
    required this.id, 
    required this.content, 
    required this.userName, 
    required this.userPhotoPath, // ✅ ADD THIS
    required this.createdAt
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      userName: json['user_name'] ?? "Unknown",
      userPhotoPath: json['user_photo_path'] ?? "", // ✅ ADD THIS
      createdAt: json['created_at'],
    );
  }
}