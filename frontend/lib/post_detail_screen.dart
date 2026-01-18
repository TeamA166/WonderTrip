import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';
import 'package:flutter_application_wondertrip/user_profile_screen.dart';

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

  late bool _isLiked;
  late int _likeCount;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    // Initialize with local data first for speed
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
    _isBookmarked = widget.post.isFavorited;
    
    // Then fetch fresh data from server
    _loadComments();
    _syncRealStatus();
  }

Future<void> _syncRealStatus() async {
    final results = await Future.wait([
      _authService.isPostLiked(widget.post.id),
      _authService.isPostFavorited(widget.post.id),
      _authService.getLikeCount(widget.post.id), // ✅ No more type error
    ]);

    if (mounted) {
      setState(() {
        _isLiked = results[0] as bool;
        _isBookmarked = results[1] as bool;
        _likeCount = results[2] as int;
      });
    }
  }

  Future<void> _handleLike() async {
    // 1. Optimistic Update (Instant feedback for user)
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });

    // 2. Send Request
    bool success = await _authService.toggleLike(widget.post.id);

    // 3. Re-sync with server to ensure accuracy
    if (success) {
      int realCount = await _authService.getLikeCount(widget.post.id);
      if (mounted) {
        setState(() {
          _likeCount = realCount;
        });
      }
    } else {
      // Revert if failed
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
           if (_isLiked) {
            _likeCount++;
          } else {
            _likeCount--;
          }
        });
      }
    }
  }

  Future<void> _handleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    await _authService.toggleFavorite(widget.post.id);
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

  Future<void> _openMaps() async {
    final String coords = widget.post.coordinates;
    if (coords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No location data available.")));
      return;
    }
    final cleanCoords = coords.replaceAll(" ", "");
    final Uri googleMapsUrl = Uri.parse("http://maps.google.com/maps?q=$cleanCoords?q=$cleanCoords");
    try {
      if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch maps';
      }
    } catch (e) {
      debugPrint("Maps Error: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps application.")));
      }
    }
  }

  void _openFullScreenImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageView(photoPath: widget.post.photoPath),
      ),
    );
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // ✅ IMAGE STACK
                  Stack(
                    children: [
                      // 1. The Image
                      GestureDetector(
                        onTap: _openFullScreenImage,
                        child: Hero(
                          tag: widget.post.photoPath,
                          child: SizedBox(
                            height: 350,
                            width: double.infinity,
                            child: SecurePostImage(photoPath: widget.post.photoPath, fit: BoxFit.cover),
                          ),
                        ),
                      ),

                      // 2. Bookmark Icon (Top Right)
                      Positioned(
                        top: 15,
                        right: 15,
                        child: GestureDetector(
                          onTap: _handleBookmark,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),

                      // 3. Like Icon & Count (Bottom Left)
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: GestureDetector(
                          onTap: _handleLike,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: _isLiked ? Colors.redAccent : Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "$_likeCount",
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ✅ 4. Rating (Bottom Right)
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.post.rating}/5",
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 5. Author Profile Row
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(
                            userId: widget.post.userId, 
                            userName: widget.post.userName,
                            userPhotoPath: widget.post.userPhotoPath
                          )
                        )
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      color: Colors.white,
                      child: Row(
                        children: [
                          SecureAvatar(photoPath: widget.post.userPhotoPath, size: 45),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.post.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const Text("Author", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1),

                  // 6. Post Details
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // Verification Badge (If applicable)
                        if (widget.post.verified)
                          Row(
                            children: const [
                              Chip(
                                label: Text("Verified Traveler", style: TextStyle(color: Colors.white)),
                                backgroundColor: Color(0xFF119DA4),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),

                        if (widget.post.verified) const SizedBox(height: 10),

                        Text(widget.post.description, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4)),

                        const SizedBox(height: 20),

                        // "Go There" Button
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
                  
                  // 7. Comments Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  // 8. Comments List
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

          // 9. Add Comment Input
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

class FullScreenImageView extends StatelessWidget {
  final String photoPath;

  const FullScreenImageView({super.key, required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: photoPath,
            child: SecurePostImage(
              photoPath: photoPath,
              fit: BoxFit.contain, 
            ),
          ),
        ),
      ),
    );
  }
}