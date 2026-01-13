import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';
import 'package:flutter_application_wondertrip/post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhotoPath;

  const UserProfileScreen({
    super.key, 
    required this.userId, 
    required this.userName,
    required this.userPhotoPath
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    final posts = await _authService.getPostsByUser(widget.userId);
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(widget.userName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 1. User Header (Modernized)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(3), // White border effect
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: SecureAvatar(photoPath: widget.userPhotoPath, size: 80),
                ),
                const SizedBox(width: 20),
                // Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName, 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_posts.length} Posts", 
                        style: const TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold, fontSize: 12)
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // 2. Posts List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _posts.isEmpty
                ? const Center(child: Text("No posts yet."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _buildModernPostCard(post);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 4,
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // ✅ MODERN IMAGE STACK
            Stack(
              children: [
                // 1. Image
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: SecurePostImage(photoPath: post.photoPath, fit: BoxFit.cover),
                ),

                // 2. Title (Top Left)
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      post.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // 3. Likes (Bottom Left)
                Positioned(
                  bottom: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "${post.likeCount}", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Rating (Bottom Right)
                Positioned(
                  bottom: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${post.rating}/5",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ✅ FOOTER (Description only)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                post.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}