import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';
import 'package:flutter_application_wondertrip/post_detail_screen.dart';

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

  // ✅ UPDATED: Modern Edit Dialog with Stars
  Future<void> _handleEdit(Post post) async {
    final titleController = TextEditingController(text: post.title);
    final descController = TextEditingController(text: post.description);
    int currentRating = post.rating; // Local variable for the dialog state

    await showDialog(
      context: context,
      barrierDismissible: false, // Force user to use buttons
      builder: (ctx) => StatefulBuilder(
        // StatefulBuilder allows us to update the stars INSIDE the dialog
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Edit Post", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF6F6F6),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Description Field
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF6F6F6),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  
                  // Star Rating Row
                  const Text("Rating", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      int starValue = index + 1;
                      return GestureDetector(
                        onTap: () {
                          // Update dialog state when star is clicked
                          setDialogState(() {
                            currentRating = starValue;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            starValue <= currentRating ? Icons.star : Icons.star_border,
                            color: starValue <= currentRating ? Colors.amber : Colors.grey[400],
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx); // Close dialog
                  setState(() => _isLoading = true); // Show spinner on screen
                  
                  final success = await _authService.updatePost(
                    post.id, 
                    titleController.text, 
                    descController.text, 
                    currentRating
                  );

                  if (success) {
                    await _loadMyPosts(); // Refresh data
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post updated successfully")));
                  } else {
                    setState(() => _isLoading = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update post")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C7489),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("My Posts", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myPosts.isEmpty
              ? const Center(child: Text("You haven't posted anything yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myPosts.length,
                  itemBuilder: (context, index) {
                    final post = _myPosts[index];
                    return _buildPostItem(post);
                  },
                ),
    );
  }

  Widget _buildPostItem(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Post Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: SecurePostImage(photoPath: post.photoPath),
              ),
            ),
            
            // 2. Post Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 3. EDIT / DELETE MENU
                      PopupMenuButton<String>(
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
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(post.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      if (post.verified) 
                        const Text("Verified", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                      else 
                        const Text("Pending", style: TextStyle(color: Colors.orange, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(post.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  
                  const Text(
                    "View Comments & Details", 
                    style: TextStyle(color: Color(0xFF119DA4), fontWeight: FontWeight.bold)
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