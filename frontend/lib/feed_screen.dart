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
  final ScrollController _scrollController = ScrollController();

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    
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
        if (posts.length < 10) _hasMore = false; 
      });
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);

    int nextPage = _currentPage + 1;
    final newPosts = await _authService.getFeed(page: nextPage);

    if (mounted) {
      setState(() {
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(newPosts);
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
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: _posts.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return FeedPostCard(post: _posts[index]);
                      },
                    ),
            ),
    );
  }
}

class FeedPostCard extends StatefulWidget {
  final Post post;
  const FeedPostCard({super.key, required this.post});

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  late bool _isLiked;
  late int _likeCount;
  late bool _isBookmarked; 

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
    _isBookmarked = widget.post.isFavorited;
  }

  Future<void> _handleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });
    await AuthService().toggleLike(widget.post.id);
  }

  Future<void> _handleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    await AuthService().toggleFavorite(widget.post.id);
  }

  void _goToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: widget.post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 3,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ 1. MODERN IMAGE STACK (Image + Overlay Buttons)
          Stack(
            children: [
              // Image (Tap to open details)
              GestureDetector(
                onTap: _goToDetails, 
                child: SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: SecurePostImage(photoPath: widget.post.photoPath, fit: BoxFit.cover),
                ),
              ),

              // Overlay: Bookmark (Top Right)
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
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Overlay: Like & Count (Bottom Left)
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
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$_likeCount",
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ✅ 2. FOOTER (User Info & Details)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Row
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(
                          userId: widget.post.userId,
                          userName: widget.post.userName,
                          userPhotoPath: widget.post.userPhotoPath,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SecureAvatar(photoPath: widget.post.userPhotoPath, size: 36),
                      const SizedBox(width: 10),
                        Expanded(
                        child: Text(
                          widget.post.userName, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      // Rating & Comment Icon
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(" ${widget.post.rating}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: _goToDetails,
                        child: const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 22),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Title
                Text(widget.post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                
                // Description (Truncated)
                Text(
                  widget.post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}