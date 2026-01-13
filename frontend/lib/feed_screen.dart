import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';
import 'package:flutter_application_wondertrip/post_detail_screen.dart';
import 'package:flutter_application_wondertrip/user_profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController(); // ✅ 1. Scroll Controller

  List<Post> _posts = [];
  bool _isLoading = true;      // Initial full-screen load
  bool _isLoadingMore = false; // Loading next page
  int _currentPage = 1;
  bool _hasMore = true;        // Stop trying if server returns empty list

  @override
  void initState() {
    super.initState();
    _loadFeed();
    
    // ✅ 2. Listen to scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
        _loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Initial Load (Pull to refresh calls this too)
  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
    });

    final posts = await _authService.getFeed(page: 1);
    
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
        // If we got fewer than 10 posts, that means there are no more pages
        if (posts.length < 10) _hasMore = false; 
      });
    }
  }

  // Load Next Page
  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);

    int nextPage = _currentPage + 1;
    final newPosts = await _authService.getFeed(page: nextPage);

    if (mounted) {
      setState(() {
        if (newPosts.isEmpty) {
          _hasMore = false; // Stop calling server
        } else {
          _posts.addAll(newPosts); // Append new data
          _currentPage = nextPage;
          if (newPosts.length < 10) _hasMore = false;
        }
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text("Explore Feed", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: _posts.isEmpty
                  ? const Center(child: Text("No posts yet. Be the first!"))
                  : ListView.builder(
                      controller: _scrollController, // ✅ Attach Controller
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      // Add +1 to item count for the bottom loading spinner
                      itemCount: _posts.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // If we are at the very bottom, show spinner
                        if (index == _posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _buildFeedCard(_posts[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildFeedCard(Post post) {
    // (This part stays exactly the same as before)
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(
                      userId: post.userId,
                      userName: post.userName,
                      userPhotoPath: post.userPhotoPath,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  SecureAvatar(photoPath: post.userPhotoPath, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (post.verified)
                          const Text("Verified Traveler", style: TextStyle(color: Color(0xFF0C7489), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post))),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: SecurePostImage(photoPath: post.photoPath, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, size: 26),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 26),
                const Spacer(),
                const Icon(Icons.star, color: Colors.amber, size: 20),
                Text(" ${post.rating}/5", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(post.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}