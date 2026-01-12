import 'dart:typed_data'; // ✅ Required for Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/map_screen.dart';
import 'package:flutter_application_wondertrip/place_detail_screen.dart';
import 'package:flutter_application_wondertrip/profile_screen.dart';
import 'package:flutter_application_wondertrip/my_posts_screen.dart';
import 'package:flutter_application_wondertrip/login_screen.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  String _firstName = "Traveler"; 
  String _email = "";
  
  // ✅ NEW: Variable to store the profile photo bytes
  Uint8List? _profilePhotoBytes; 

  List<Post> _verifiedPosts = [];
  List<Post> _unverifiedPosts = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // ✅ UPDATED: Fetch everything in parallel (Text + Image + Posts)
      final results = await Future.wait([
        _authService.getProfile(),            // Index 0: Map (Text Data)
        _authService.getProfileImageBytes(),  // Index 1: Uint8List (Photo)
        _authService.getVerifiedPosts(page: 1), // Index 2: List<Post>
        _authService.getUnverifiedPosts(page: 1)// Index 3: List<Post>
      ]);

      if (mounted) {
        setState(() {
          // 1. Handle Profile Text
          final profileData = results[0] as Map<String, dynamic>?;
          if (profileData != null) {
            _firstName = profileData['name'] ?? "Traveler"; // Corrected key to 'name'
            _email = profileData['email'] ?? "";
          }

          // 2. ✅ Handle Profile Photo
          _profilePhotoBytes = results[1] as Uint8List?;

          // 3. Handle Posts
          _verifiedPosts = results[2] as List<Post>;
          _unverifiedPosts = results[3] as List<Post>;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading main screen data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ HELPER: Create the image provider
    // If we have bytes, use MemoryImage. If not, return null (so we can show an Icon).
    final ImageProvider? profileImageProvider = _profilePhotoBytes != null 
        ? MemoryImage(_profilePhotoBytes!) 
        : null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F6F6),
      
      // --- RIGHT SIDE MENU (DRAWER) ---
      endDrawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF119DA4)),
              accountName: Text(_firstName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text(_email),
              // ✅ UPDATED: Show Photo or Initials
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: profileImageProvider, // Use the fetched image
                child: _profilePhotoBytes == null 
                    ? Text(_firstName.isNotEmpty ? _firstName[0].toUpperCase() : "T", 
                        style: const TextStyle(fontSize: 24, color: Color(0xFF119DA4)))
                    : null, // Hide child if image exists
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black87),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view, color: Colors.black87),
              title: const Text("My Page"),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPostsScreen()));
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: _handleLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER SECTION ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'Hi, ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                                TextSpan(text: '$_firstName!', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: Color(0xFF212121))),
                              ],
                            ),
                          ),
                          
                          // ✅ UPDATED: Top Right Profile Click Action
                          GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              backgroundImage: profileImageProvider, // Use the fetched image
                              child: _profilePhotoBytes == null
                                  ? const Icon(Icons.person, color: Colors.white) // Show icon if no image
                                  : null, // Hide icon if image exists
                            ),
                          ),
                        ],
                      ),
                      const Text('Explore the Lodz', style: TextStyle(fontSize: 20, color: Color(0xFF616161))),
                    ],
                  ),
                ),

                // ... (Rest of your UI: Discover Button, Must See Spots, etc.) ...
                // Paste the rest of your build body here (Discover Button, Lists, etc.)
                // It remains exactly the same as before.
                
                // Discover Nearby Places
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Color(0xFF119DA4), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Discover nearby places', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text('Lodz, Poland', style: TextStyle(color: Color(0xFF616161))),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFF616161), size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Must See Spots
                _buildSectionTitle("Must See Spots!", "Your Lodz adventure awaits"),
                SizedBox(
                  height: 250,
                  child: _verifiedPosts.isEmpty 
                    ? const Center(child: Text("No verified spots yet.")) 
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _verifiedPosts.length,
                        itemBuilder: (context, index) => _buildPlaceCard(context, _verifiedPosts[index]),
                      ),
                ),

                const SizedBox(height: 30),

                // Travelers' posts
                _buildSectionTitle("Travelers' posts!", "A favorite among travelers"),
                SizedBox(
                  height: 200,
                  child: _unverifiedPosts.isEmpty 
                    ? const Center(child: Text("No traveler posts yet."))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _unverifiedPosts.length,
                        itemBuilder: (context, index) => _buildPostCard(_unverifiedPosts[index]),
                      ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionTitle(String title, String subTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(subTitle, style: const TextStyle(fontSize: 16, color: Color(0xFF616161))),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceDetailScreen())),
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Positioned.fill(child: SecurePostImage(photoPath: post.photoPath, fit: BoxFit.cover)),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 15, left: 15, right: 15,
                child: Text(post.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned.fill(child: SecurePostImage(photoPath: post.photoPath, fit: BoxFit.cover)),
            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(post.rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}