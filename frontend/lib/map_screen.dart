import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/post_detail_screen.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AuthService _authService = AuthService();
  final MapController _mapController = MapController();
  
  // Data Lists
  List<Post> _verifiedPosts = [];
  List<Post> _favoritePosts = [];
  
  // State
  String _activeTab = "discover"; // 'discover' or 'favorites'
  List<Marker> _markers = [];
  LatLng? _userLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadData();
  }

  // Load BOTH lists initially so switching is fast
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 1. Fetch Verified
    final allPosts = await _authService.getPosts();
    final verified = allPosts.where((p) => p.verified && p.coordinates.isNotEmpty).toList();

    // 2. Fetch Favorites
    final favorites = await _authService.getFavoritePosts();
    // Filter favorites to ensure they have coordinates (just in case)
    final validFavorites = favorites.where((p) => p.coordinates.isNotEmpty).toList();

    if (mounted) {
      setState(() {
        _verifiedPosts = verified;
        _favoritePosts = validFavorites;
        _isLoading = false;
        _updateMarkers(); // Generate markers for the default tab
      });
    }
  }

  // Generate markers based on the Active Tab
  void _updateMarkers() {
    List<Post> targetList = _activeTab == "discover" ? _verifiedPosts : _favoritePosts;
    List<Marker> newMarkers = [];

    for (var post in targetList) {
      LatLng? position = _parseCoordinates(post.coordinates);
      if (position != null) {
        newMarkers.add(
          Marker(
            point: position,
            width: 60,
            height: 60,
            child: GestureDetector(
              onTap: () => _navigateToPost(post),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _activeTab == "discover" ? const Color(0xFF0C7489) : Colors.red, // Blue for verified, Red for favs
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _activeTab == "discover" ? Icons.verified : Icons.favorite, // Different Icons
                      color: Colors.white, 
                      size: 20
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down, 
                    color: _activeTab == "discover" ? const Color(0xFF0C7489) : Colors.red, 
                    size: 20
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    
    // Add User Location Marker if available
    if (_userLocation != null) {
      newMarkers.add(
        Marker(
          point: _userLocation!,
          width: 50,
          height: 50,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  // Switch Tab Logic
  void _switchTab(String tabName) {
    if (_activeTab != tabName) {
      setState(() {
        _activeTab = tabName;
        _updateMarkers(); // Refresh markers immediately
      });
    }
  }

  LatLng? _parseCoordinates(String coordString) {
    try {
      final parts = coordString.split(',');
      if (parts.length == 2) {
        return LatLng(double.parse(parts[0].trim()), double.parse(parts[1].trim()));
      }
    } catch (e) {
      debugPrint("Error parsing coordinates: $e");
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
        _updateMarkers(); // Re-add markers to include user location
      });
    }
  }

  void _navigateToPost(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
    // Refresh data when returning (in case user unfavorited something)
    _loadData(); 
  }

  @override
  Widget build(BuildContext context) {
    // Determine which list to show in the bottom sheet
    List<Post> activeList = _activeTab == "discover" ? _verifiedPosts : _favoritePosts;

    return Scaffold(
      body: Stack(
        children: [
          // 1. MAP LAYER
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(51.7592, 19.4560),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.wondertrip',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // 2. BACK BUTTON
          Positioned(
            top: 50,
            left: 20,
            child: Material(
              elevation: 4,
              shape: const CircleBorder(),
              color: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black), 
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. BOTTOM SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.25, // Start slightly taller to see buttons clearly
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40, height: 5,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    // TABS (Discover vs Favorites)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavButton(Icons.explore, "Discover", _activeTab == "discover", () => _switchTab("discover")),
                          _buildNavButton(Icons.favorite, "Favorites", _activeTab == "favorites", () => _switchTab("favorites")),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // LIST
                    if (_isLoading)
                      const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                    else if (activeList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(30), 
                        child: Center(
                          child: Text(
                            _activeTab == "discover" 
                            ? "No verified spots found." 
                            : "You haven't favorited any places yet.",
                            style: const TextStyle(color: Colors.grey),
                          )
                        )
                      )
                    else
                      ...activeList.map((post) => _buildPostListItem(post)),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Updated Button to support Taps
  Widget _buildNavButton(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
            ? (_activeTab == "discover" ? const Color(0xFFE3F2FD) : const Color(0xFFFFEBEE)) // Blue tint vs Red tint
            : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isActive 
                ? (_activeTab == "discover" ? const Color(0xFF0C7489) : Colors.red) 
                : Colors.grey, 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              label, 
              style: TextStyle(
                color: isActive 
                  ? (_activeTab == "discover" ? const Color(0xFF0C7489) : Colors.red) 
                  : Colors.grey, 
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
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
          // Show "Verified" label only if it IS verified
          if (post.verified) ...[
            const Icon(Icons.verified, color: Color(0xFF0C7489), size: 16),
            const Text(" Verified", style: TextStyle(color: Color(0xFF0C7489), fontSize: 12)),
          ]
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.location_searching, color: Colors.grey),
        onPressed: () {
          LatLng? loc = _parseCoordinates(post.coordinates);
          if (loc != null) {
            _mapController.move(loc, 15.0);
          }
        },
      ),
    );
  }
}