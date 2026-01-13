import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // OpenStreetMap package
import 'package:latlong2/latlong.dart';      // Coordinates package
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart'; // ✅ Import Auth Service
import 'package:flutter_application_wondertrip/post_detail_screen.dart'; // ✅ To open details
import 'package:flutter_application_wondertrip/widgets/secure_image.dart'; // ✅ For list thumbnails

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AuthService _authService = AuthService();
  final MapController _mapController = MapController();
  
  List<Marker> _markers = [];
  List<Post> _verifiedPosts = []; // ✅ Store verified posts here
  LatLng? _userLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchVerifiedPosts();
  }

  // 1. FETCH & FILTER VERIFIED POSTS
  Future<void> _fetchVerifiedPosts() async {
    // Fetch all posts (Assuming getPosts returns the feed)
    // You might want a dedicated getVerifiedPosts() backend endpoint later for performance
    final allPosts = await _authService.getPosts();
    
    // ✅ Filter: Only Verified posts that have coordinates
    final verified = allPosts.where((p) => p.verified && p.coordinates.isNotEmpty).toList();

    List<Marker> newMarkers = [];

    for (var post in verified) {
      LatLng? position = _parseCoordinates(post.coordinates);
      if (position != null) {
        newMarkers.add(
          Marker(
            point: position,
            width: 60,
            height: 60,
            child: GestureDetector(
              onTap: () => _navigateToPost(post), // Tap marker to open details
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C7489),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.verified, color: Colors.white, size: 20),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF0C7489), size: 20),
                ],
              ),
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _verifiedPosts = verified;
        _markers = newMarkers;
        _isLoading = false;
      });
    }
  }

  // Helper: Parse "51.2, 19.3" string to LatLng
  LatLng? _parseCoordinates(String coordString) {
    try {
      final parts = coordString.split(',');
      if (parts.length == 2) {
        return LatLng(double.parse(parts[0].trim()), double.parse(parts[1].trim()));
      }
    } catch (e) {
      debugPrint("Error parsing coordinates for post: $e");
    }
    return null;
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    
    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_userLocation!, 13.0);
      });
    }
  }

  void _navigateToPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ LAYER 1: THE MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(51.7592, 19.4560), // Default fallback
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.wondertrip',
              ),
              MarkerLayer(markers: [
                ..._markers,
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
              ]),
            ],
          ),

          // 🔙 LAYER 2: BACK BUTTON
            Positioned(
            top: 50,
            left: 20,
            child: Material(
              elevation: 4, // ✅ Elevation goes here in Material
              shape: const CircleBorder(), // Keeps it round
              color: Colors.white, // Color goes here now
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black), 
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 📄 LAYER 3: DRAGGABLE SHEET (Pullable List)
          DraggableScrollableSheet(
            initialChildSize: 0.15, // Height when collapsed (just the handle/buttons)
            minChildSize: 0.15,     // Minimum height
            maxChildSize: 0.85,     // Maximum height (almost full screen)
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
                ),
                child: ListView(
                  controller: scrollController, // ✅ Attach controller here for drag physics
                  padding: EdgeInsets.zero,
                  children: [
                    // 1. Drag Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40, height: 5,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    // 2. Navigation Buttons (Discover / Favorites)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavButton(Icons.explore, "Discover", true),
                          _buildNavButton(Icons.favorite, "Favorites", false),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // 3. List of Verified Posts
                    if (_isLoading)
                      const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                    else if (_verifiedPosts.isEmpty)
                      const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No verified spots found yet.")))
                    else
                      ..._verifiedPosts.map((post) => _buildPostListItem(post)),
                    
                    const SizedBox(height: 20), // Bottom padding
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE3F2FD) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? const Color(0xFF0C7489) : Colors.grey, size: 20),
          const SizedBox(width: 8),
          Text(
            label, 
            style: TextStyle(
              color: isActive ? const Color(0xFF0C7489) : Colors.grey, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }

  Widget _buildPostListItem(Post post) {
    return ListTile(
      onTap: () => _navigateToPost(post),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 60, height: 60,
          child: SecurePostImage(photoPath: post.photoPath, fit: BoxFit.cover),
        ),
      ),
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(post.rating.toString()),
          const SizedBox(width: 10),
          const Icon(Icons.verified, color: Color(0xFF0C7489), size: 16),
          const Text(" Verified", style: TextStyle(color: Color(0xFF0C7489), fontSize: 12)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.location_searching, color: Colors.grey),
        onPressed: () {
          // Move map to this location
          LatLng? loc = _parseCoordinates(post.coordinates);
          if (loc != null) {
            _mapController.move(loc, 15.0);
          }
        },
      ),
    );
  }
}