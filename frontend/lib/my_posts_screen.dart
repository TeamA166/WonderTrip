import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';
import 'package:flutter_application_wondertrip/post_detail_screen.dart';
import 'package:flutter_application_wondertrip/edit_post_screen.dart';
// Import FeedScreen to access the "Global Feed" button if needed, 
// though typically this is in the Drawer or AppBar actions.
import 'package:flutter_application_wondertrip/feed_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final AuthService _authService = AuthService();
  List<Post> _myPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    final posts = await _authService.getMyPosts();
    if (mounted) {
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _authService.deletePost(postId);
      if (success) {
        await _loadMyPosts();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted")));
      } else {
        setState(() => _isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete")));
      }
    }
  }

  Future<void> _handleEdit(Post post) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
    );

    if (result == true) {
      _loadMyPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("My Posts", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Optional: Add Global Feed shortcut here if desired
          IconButton(
            icon: const Icon(Icons.public, color: Color(0xFF0C7489)),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedScreen()));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myPosts.isEmpty
              ? const Center(child: Text("You haven't posted anything yet."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _myPosts.length,
                  itemBuilder: (context, index) {
                    final post = _myPosts[index];
                    return _buildModernPostItem(post);
                  },
                ),
    );
  }

  Widget _buildModernPostItem(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
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
                // 1. The Image
                SizedBox(
                  height: 250, // Nice tall image
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
                    constraints: const BoxConstraints(maxWidth: 200), // Prevent overflow
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // 3. Edit Menu (Top Right)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: Colors.white, // Popup background
                    ),
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') _handleEdit(post);
                        if (value == 'delete') _handleDelete(post.id);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text("Edit")]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))]),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Likes (Bottom Left)
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

                // 5. Rating (Bottom Right)
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

            // ✅ FOOTER (Status & Description)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Status
                  Row(
                    children: [
                      Icon(
                        post.verified ? Icons.verified : Icons.hourglass_empty,
                        color: post.verified ? const Color(0xFF119DA4) : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.verified ? "Verified Public Post" : "Pending Verification",
                        style: TextStyle(
                          color: post.verified ? const Color(0xFF119DA4) : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    post.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}