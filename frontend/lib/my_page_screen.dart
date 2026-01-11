import 'package:flutter/material.dart';

// --- Data Models ---
class Post {
  final String id;
  final String imageUrl;
  final String title;
  String description;
  final String profileName;
  final List<Comment> comments;
  final DateTime date; 
  bool isExpanded;

  Post({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.profileName,
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

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // Initial mock data
  final List<Post> _myPosts = [
    Post(
      id: "1",
      imageUrl: "https://placehold.co/600x400/BC9B8F/FFFFFF.png?text=Rose+Passage",
      title: "The Rose Passage",
      profileName: "Adam Surname",
      description: "Step off Piotrkowska into a courtyard hidden in mirrors. This stunning mosaic turns a gray alley into a crystal palace. A shimmering hidden gem in the heart of industrial Łódź. It is a must-see place for everyone visiting the city.",
      date: DateTime.now().subtract(const Duration(days: 3)), 
      comments: [
        Comment(userName: "Elena", text: "So beautiful! ✨", avatarUrl: "https://i.pravatar.cc/150?u=elena"),
        Comment(userName: "Marcus", text: "I need to visit this place ASAP.", avatarUrl: "https://i.pravatar.cc/150?u=marcus"),
      ],
    ),
  ];

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _addNewPost(Post post) {
    setState(() {
      // ✅ Yeni gelen postun en üste gitmesi için insert(0, ...) kullanıldı
      _myPosts.insert(0, post); 
    });
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                _myPosts.removeWhere((post) => post.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted")));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editPostDescription(Post post) {
    final TextEditingController editController = TextEditingController(text: post.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Description"),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (confirmContext) => AlertDialog(
                  title: const Text("Save Changes"),
                  content: const Text("Do you want to save the changes?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(confirmContext), child: const Text("No")),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          post.description = editController.text;
                        });
                        Navigator.pop(confirmContext);
                        Navigator.pop(context);
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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

  void _openAddPostScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPostScreen(onSave: _addNewPost)),
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
          'MY PAGE',
          style: TextStyle(color: Color(0xFF0C7489), fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Color(0xFF0C7489), size: 28),
            onPressed: _openAddPostScreen,
          ),
        ],
      ),
      body: _myPosts.isEmpty 
        ? _buildEmptyState() 
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: _myPosts.length,
            itemBuilder: (context, index) => _buildPostCard(_myPosts[index]),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.image_search, size: 80, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'This place looks empty. Add something new!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF616161), fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _openAddPostScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C7489),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text("Create First Post", style: TextStyle(color: Colors.white)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10, 
            offset: const Offset(0, 5)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, color: Color(0xFF0C7489)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.profileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      post.title, 
                      style: const TextStyle(color: Color(0xFFFB8F67), fontSize: 13, fontWeight: FontWeight.w600)
                    ),
                    Text(_formatDate(post.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey, size: 20),
                  onPressed: () => _editPostDescription(post),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDelete(post.id),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.network(post.imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF0C7489)), 
                  onPressed: () => _showComments(context, post),
                ),
                const SizedBox(width: 4),
                Text(
                  "${post.comments.length} comments",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isLongText) {
                      setState(() {
                        post.isExpanded = !post.isExpanded;
                      });
                    }
                  },
                  child: Text(
                    post.description,
                    maxLines: post.isExpanded ? null : 3,
                    overflow: post.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
                  ),
                ),
                if (isLongText)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        post.isExpanded = !post.isExpanded;
                      });
                    },
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

class AddPostScreen extends StatefulWidget {
  final Function(Post) onSave;
  const AddPostScreen({super.key, required this.onSave});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      appBar: AppBar(
        title: const Text("Create Post", style: TextStyle(color: Color(0xFF0C7489))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0C7489)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () { /* Image Picker Logic */ },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF0C7489).withValues(alpha: 0.3)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 50, color: Color(0xFF0C7489)),
                    SizedBox(height: 10),
                    Text("Click to upload photo", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Spot Name (e.g. Rose Passage)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "What's special about this place?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    widget.onSave(Post(
                      id: DateTime.now().toString(),
                      imageUrl: "https://placehold.co/600x400/0C7489/FFFFFF.png?text=New+Adventure",
                      title: _titleController.text,
                      description: _descController.text,
                      profileName: "Adam Surname",
                      comments: [],
                      date: DateTime.now(), 
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C7489)),
                child: const Text("Share Post", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
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
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
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