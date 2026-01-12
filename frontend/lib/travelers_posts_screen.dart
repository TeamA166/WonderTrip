import 'package:flutter/material.dart';

// --- Data Models ---
class Post {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String profileName;
  final String avatarUrl;
  final List<Comment> comments;
  final DateTime date;
  bool isExpanded;

  Post({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.profileName,
    required this.avatarUrl,
    required this.comments,
    required this.date,
    this.isExpanded = false,
  });
}

class Comment {
  final String userName;
  final String text;
  final String avatarUrl;

  Comment({required this.userName, required this.text, required this.avatarUrl});
}

class TravelersPostsScreen extends StatefulWidget {
  const TravelersPostsScreen({super.key});

  @override
  State<TravelersPostsScreen> createState() => _TravelersPostsScreenState();
}

class _TravelersPostsScreenState extends State<TravelersPostsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Mock data representing other users' posts
  final List<Post> _allPosts = [
    Post(
      id: "1",
      profileName: "Sarah J.",
      avatarUrl: "https://i.pravatar.cc/150?u=sarah",
      imageUrl: "https://placehold.co/600x400/BC9B8F/FFFFFF.png?text=Rose+Passage",
      title: "The Rose Passage",
      description: "Step off Piotrkowska into a courtyard hidden in mirrors. This stunning mosaic turns a gray alley into a crystal palace. A shimmering hidden gem in the heart of industrial Łódź.",
      date: DateTime.now().subtract(const Duration(days: 2)),
      comments: [Comment(userName: "Adam", text: "Amazing view!", avatarUrl: "https://i.pravatar.cc/150?u=adam")],
    ),
    Post(
      id: "2",
      profileName: "Mike Ross",
      avatarUrl: "https://i.pravatar.cc/150?u=mike",
      imageUrl: "https://placehold.co/600x400/0C7489/FFFFFF.png?text=Urban+Jungle",
      title: "Urban Jungle: The 6th District",
      description: "A unique mix of nature and street art. Perfect for afternoon walks and capturing the raw soul of the city.",
      date: DateTime.now().subtract(const Duration(days: 5)),
      comments: [],
    ),
    Post(
      id: "3",
      profileName: "Elena V.",
      avatarUrl: "https://i.pravatar.cc/150?u=elena",
      imageUrl: "https://placehold.co/600x400/FB8F67/FFFFFF.png?text=Industrial+Zen",
      title: "Industrial Zen: Wi-Ma Factory",
      description: "An old textile giant turned into a creative sanctuary. Industrial ruins meet art studios and quiet cafes.",
      date: DateTime.now().subtract(const Duration(hours: 5)),
      comments: [],
    ),
  ];

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  List<Post> get _filteredPosts {
    List<Post> filtered = _allPosts.where((post) {
      final query = _searchQuery.toLowerCase();
      return post.title.toLowerCase().contains(query) ||
             post.description.toLowerCase().contains(query);
    }).toList();

    // Sort by Latest by default
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void _showComments(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentSheet(
        post: post,
        onCommentAdded: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C7489)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TRAVELER’S POSTS',
          style: TextStyle(color: Color(0xFF0C7489), fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search places or stories...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0C7489)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Posts Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) => _buildPostCard(_filteredPosts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    bool isLongText = post.description.length > 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(post.avatarUrl), radius: 18),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.profileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(_formatDate(post.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                Text(post.title, style: const TextStyle(color: Color(0xFFFB8F67), fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Image.network(post.imageUrl, width: double.infinity, height: 220, fit: BoxFit.cover),
          
          // Interactions (Only Comments)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showComments(context, post),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: Color(0xFF0C7489), size: 22),
                      const SizedBox(width: 8),
                      Text("${post.comments.length} comments", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isLongText) setState(() => post.isExpanded = !post.isExpanded);
                  },
                  child: Text(
                    post.description,
                    maxLines: post.isExpanded ? null : 2,
                    overflow: post.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
                  ),
                ),
                if (isLongText)
                  GestureDetector(
                    onTap: () => setState(() => post.isExpanded = !post.isExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        post.isExpanded ? "Show less" : "Read more...",
                        style: const TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final Post post;
  final VoidCallback onCommentAdded;
  const _CommentSheet({required this.post, required this.onCommentAdded});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      widget.post.comments.add(
        Comment(
          userName: "Adam Surname", 
          text: _commentController.text,
          avatarUrl: "https://i.pravatar.cc/150?u=adam",
        ),
      );
    });
    _commentController.clear();
    widget.onCommentAdded();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: widget.post.comments.isEmpty
                  ? const Center(child: Text("No comments yet. Be the first to write!"))
                  : ListView.builder(
                      controller: controller,
                      itemCount: widget.post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = widget.post.comments[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundImage: NetworkImage(comment.avatarUrl)),
                          title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(comment.text, style: const TextStyle(color: Colors.black87)),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE0E0E0), child: Icon(Icons.person, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _submitComment, 
                    child: const Text("Post", style: TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold))
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