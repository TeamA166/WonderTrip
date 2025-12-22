import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // OpenStreetMap package
import 'package:latlong2/latlong.dart';      // Coordinates package
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller to move the map programmatically
  final MapController _mapController = MapController();
  
  // Your "Backend" Data Markers
  List<Marker> _markers = [];
  
  // User's current location (initially null)
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _fetchLocationsFromBackend();
  }

  // 1. MOCK BACKEND DATA
  void _fetchLocationsFromBackend() {
    // Simulating data from your database
    List<Map<String, dynamic>> backendData = [
      {"lat": 51.7592, "lng": 19.4560, "name": "Manufaktura"},
      {"lat": 51.7650, "lng": 19.4600, "name": "Old Town Park"},
    ];

    setState(() {
      _markers = backendData.map((place) {
        return Marker(
          point: LatLng(place['lat'], place['lng']),
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on, 
            color: Colors.orange, 
            size: 40
          ),
        );
      }).toList();
    });
  }

  // 2. GET USER LOCATION
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get the position
    Position position = await Geolocator.getCurrentPosition();
    
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      
      // Optional: Add a blue marker for the user
      _markers.add(
        Marker(
          point: _userLocation!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.my_location, 
            color: Colors.blue, // Blue dot for user
            size: 30
          ),
        )
      );
      
      // Move map to user
      _mapController.move(_userLocation!, 14.0);
    });
  }

  void _showFavoritesPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Favorites"),
        content: const Text("List is empty!"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ OPEN STREET MAP WIDGET
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(51.7592, 19.4560), // Lodz Default
              initialZoom: 13.0,
            ),
            children: [
              // 1. The Map Tiles (The actual visual map)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_wondertrip', // Required by OSM policy
              ),
              
              // 2. The Pins (Markers)
              MarkerLayer(markers: _markers),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black), 
                onPressed: () => Navigator.pop(context)
              ),
            ),
          ),

          // Bottom Navigation (Your existing UI)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50, height: 5, 
                    decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavButton(Icons.explore, "Discover", true, null),
                      _buildNavButton(Icons.favorite, "Favorites", false, _showFavoritesPopup),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.8) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF616161)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF616161), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}