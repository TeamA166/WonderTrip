import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/map_screen.dart';
import 'package:flutter_application_wondertrip/place_detail_screen.dart';
// Import your services and widgets
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart'; // Ensure this file exists

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
  
  // State Variables
  bool _isLoading = true;
  String _firstName = "Traveler"; // Default name
  List<Post> _verifiedPosts = [];
  List<Post> _unverifiedPosts = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // 1. Fetch Profile to get Name
      final profile = await _authService.getProfile(); // You might need to add this method back to AuthService if missing
      
      // 2. Fetch Verified Posts (Must See)
      final verified = await _authService.getVerifiedPosts(page: 1);
      
      // 3. Fetch Unverified Posts (Travelers' Posts)
      final unverified = await _authService.getUnverifiedPosts(page: 1);

      if (mounted) {
        setState(() {
          if (profile != null) {
            _firstName = profile['first_name'] ?? "Traveler";
          }
          _verifiedPosts = verified;
          _unverifiedPosts = unverified;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading main screen data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
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
                          // Profile Icon (Optional: Connect to ProfileScreen)
                          GestureDetector(
                            // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const Text('Explore the Lodz', style: TextStyle(fontSize: 20, color: Color(0xFF616161))),
                    ],
                  ),
                ),

                // 2. Discover Nearby Places Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // Fixed for compatibility
                          blurRadius: 10
                        )
                      ],
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

                // 3. Must See Spots (VERIFIED POSTS)
                _buildSectionTitle("Must See Spots!", "Your Lodz adventure awaits"),
                SizedBox(
                  height: 250,
                  child: _verifiedPosts.isEmpty 
                    ? const Center(child: Text("No verified spots yet.")) 
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _verifiedPosts.length,
                        itemBuilder: (context, index) {
                          return _buildPlaceCard(context, _verifiedPosts[index]);
                        },
                      ),
                ),

                const SizedBox(height: 30),

                // 4. Travelers' posts (UNVERIFIED POSTS)
                _buildSectionTitle("Travelers' posts!", "A favorite among travelers"),
                SizedBox(
                  height: 200,
                  child: _unverifiedPosts.isEmpty 
                    ? const Center(child: Text("No traveler posts yet."))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: _unverifiedPosts.length,
                        itemBuilder: (context, index) {
                          return _buildPostCard(_unverifiedPosts[index]);
                        },
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

  // --- WIDGET FOR VERIFIED POSTS ---
  Widget _buildPlaceCard(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () {
        // Pass the post data to detail screen if needed
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceDetailScreen()));
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(10),
        // Use Stack to layer Image, Gradient, and Text
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // 1. The Secure Image
              Positioned.fill(
                child: SecurePostImage(
                  photoPath: post.photoPath, 
                  fit: BoxFit.cover,
                ),
              ),
              
              // 2. Gradient Overlay (To make text readable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, 
                      end: Alignment.topCenter, 
                      colors: [
                        Colors.black.withOpacity(0.7), 
                        Colors.transparent
                      ]
                    ),
                  ),
                ),
              ),

              // 3. Text Title
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Text(
                  post.title, 
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET FOR UNVERIFIED POSTS ---
  Widget _buildPostCard(Post post) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Just the image for traveler posts (similar to Instagram grid)
            Positioned.fill(
              child: SecurePostImage(
                photoPath: post.photoPath,
                fit: BoxFit.cover,
              ),
            ),
            // Optional: Add rating badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      post.rating.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
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