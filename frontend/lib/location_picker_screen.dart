import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng _currentCenter = const LatLng(51.7592, 19.4560); // Default Lodz
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _currentCenter = widget.initialLocation!;
    } else {
      _locateUser();
    }
  }

  Future<void> _locateUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location services are disabled.")));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    
    if (mounted) {
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentCenter, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _currentCenter);
            },
            child: const Text("CONFIRM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      
      body: Stack(
        children: [
          // 1. The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 13.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _currentCenter = camera.center ?? _currentCenter;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.wondertrip', 
              ),
            ],
          ),
          
          // 2. The Center Pin (Fixed)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40), 
              child: Icon(Icons.location_on, color: Colors.red, size: 50),
            ),
          ),
          
          // 3. Bottom Controls Container (Aligned Properly)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // COORDINATES BOX (Expanded to take available space)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Selected Location", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          "${_currentCenter.latitude.toStringAsFixed(5)}, ${_currentCenter.longitude.toStringAsFixed(5)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 15),

                // MY LOCATION BUTTON (Next to the box)
                FloatingActionButton(
                  onPressed: _locateUser,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}