import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Import this
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _commentController = TextEditingController();
  
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isFavorited = false;
  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkFavoriteStatus();
  }
  Future<void> _checkFavoriteStatus() async {
    bool fav = await _authService.isPostFavorited(widget.post.id);
    if (mounted) setState(() => _isFavorited = fav);
  }
  Future<void> _toggleFavorite() async {
    setState(() => _isFavorited = !_isFavorited);

    bool serverState = await _authService.toggleFavorite(widget.post.id);
    
    if (mounted && serverState != _isFavorited) {
      setState(() => _isFavorited = serverState);
    }
  }

  Future<void> _loadComments() async {
    final comments = await _authService.getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    bool success = await _authService.addComment(widget.post.id, _commentController.text.trim());

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus(); 
        _loadComments(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to post comment")));
      }
    }
  }

  // ✅ LOGIC: Open Google Maps
  Future<void> _openMaps() async {
    // 1. Get coordinates (e.g. "51.75, 19.45")
    final String coords = widget.post.coordinates;
    
    if (coords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No location data available for this post.")));
      return;
    }

    // 2. Create Google Maps URL
    // removing spaces to be safe
    final cleanCoords = coords.replaceAll(" ", "");
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$cleanCoords");

    // 3. Launch
    try {
      if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch maps';
      }
    } catch (e) {
      debugPrint("Maps Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open Google Maps.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.post.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // ✅ NEW: Favorite Heart Button
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.black,
              size: 28,
            ),
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 10), // Spacing
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Post Image
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: SecurePostImage(photoPath: widget.post.photoPath, fit: BoxFit.cover),
                  ),

                  // 2. Post Details
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating & Verification Row
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text("${widget.post.rating}/5", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (widget.post.verified)
                              const Chip(label: Text("Verified", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF119DA4))
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        Text(widget.post.description, style: const TextStyle(fontSize: 16, color: Colors.black87)),

                        const SizedBox(height: 20),

                        // ✅ 3. "Go There" Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _openMaps,
                            icon: const Icon(Icons.map, color: Colors.white),
                            label: const Text("Go There", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C7489),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(thickness: 1),
                  
                  // 4. Comments Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  // 5. Comments List
                    _isLoading 
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    : _comments.isEmpty
                        ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No comments yet. Be the first!")))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                                final comment = _comments[index];

                                // 🔍 DEBUG PRINT: This will show up in your "Debug Console"
                                print("COMMENT DEBUG -> User: ${comment.userName} | PhotoPath: '${comment.userPhotoPath}'");

                                return ListTile(
                                leading: SecureAvatar(
                                    photoPath: comment.userPhotoPath, 
                                    size: 40,
                                ),
                                title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(comment.content),
                                );
                            },
                            ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 6. Add Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFFF1F4F8),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0C7489),
                    child: _isSending 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendComment,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}