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
        title: Text("${widget.userName}'s Profile", style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 1. User Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                SecureAvatar(photoPath: widget.userPhotoPath, size: 80),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text("${_posts.length} Posts", style: const TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          
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
                      return _buildPostCard(post);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: SecurePostImage(photoPath: post.photoPath),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(" ${post.rating}"),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}