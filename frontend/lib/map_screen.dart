import 'dart:math'; // Rastgele konum üretmek için
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // OpenStreetMap paketi
import 'package:latlong2/latlong.dart';      // Koordinat paketi
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Marker> _markers = [];
  
  // Seçilen yerin bilgilerini tutan değişkenler
  String? _selectedPlaceName;
  String? _selectedAddress;
  LatLng? _selectedLatLng;

  // Favori mekanları tutan liste
  final List<Map<String, dynamic>> _favorites = [];

  // Arama sonuçları ve başlangıç işaretçileri için veri listesi
  final List<Map<String, dynamic>> _allLocations = [
    {"lat": 51.7592, "lng": 19.4560, "name": "Manufaktura", "address": "Drewnowska 58, 91-002 Łódź"},
    {"lat": 51.7650, "lng": 19.4600, "name": "Old Town Park", "address": "Staromiejski Park, Łódź"},
    {"lat": 51.7610, "lng": 19.4540, "name": "Piotrkowska Street", "address": "ul. Piotrkowska, Łódź"},
    {"lat": 51.7480, "lng": 19.4530, "name": "Off Piotrkowska", "address": "Piotrkowska 138/140, Łódź"},
    {"lat": 51.7760, "lng": 19.4880, "name": "University of Lodz", "address": "Narutowicza 68, Łódź"},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialMarkers();
    _checkLocationPermission(shouldMove: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Bilgi panelini güncelleyen fonksiyon
  void _updateSelection(String name, String address, LatLng coords) {
    setState(() {
      _selectedPlaceName = name;
      _selectedAddress = address;
      _selectedLatLng = coords;
    });
  }

  // Arama fonksiyonu
  void _performSearch(String query) {
    if (query.isEmpty) return;

    final results = _allLocations.where((loc) => 
      loc['name'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();

    if (results.isNotEmpty) {
      final found = results.first;
      final point = LatLng(found['lat'], found['lng']);
      
      _mapController.move(point, 15.0);
      _updateSelection(found['name'], found['address'], point);
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found in Lodz.")),
      );
    }
  }

  // Haritaya dokunulduğunda manuel seçim yapar
  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    final String coordsLabel = "Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}";
    
    setState(() {
      _markers.removeWhere((m) => m.key == const Key('manual_selection'));
      _markers.add(
        Marker(
          key: const Key('manual_selection'),
          point: point,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on, 
            color: Color(0xFF119DA4), 
            size: 40
          ),
        ),
      );
      _updateSelection("Selected Location", coordsLabel, point);
    });
  }

  // Başlangıç işaretçilerini yükler
  void _loadInitialMarkers() {
    setState(() {
      _markers = _allLocations.map((place) {
        final point = LatLng(place['lat'], place['lng']);
        return Marker(
          point: point,
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _updateSelection(place['name'], place['address'], point),
            child: const Icon(
              Icons.location_on, 
              color: Color(0xFFFB8F67), 
              size: 40
            ),
          ),
        );
      }).toList();
    });
  }

  // Keşfet (Discover) butonu: Şehir merkezinde rastgele bir yer bulur
  void _moveToRandomLodzLocation() {
    final random = Random();
    double lat = 51.730 + random.nextDouble() * (51.790 - 51.730);
    double lng = 19.410 + random.nextDouble() * (19.500 - 19.410);
    LatLng randomPoint = LatLng(lat, lng);
    
    String randomAddress = "City Center Area (Lat: ${lat.toStringAsFixed(3)})";

    setState(() {
      _markers.removeWhere((m) => m.key == const Key('discovery_location'));
      _markers.add(
        Marker(
          key: const Key('discovery_location'),
          point: randomPoint,
          width: 45,
          height: 45,
          child: GestureDetector(
            onTap: () => _updateSelection("City Discovery", randomAddress, randomPoint),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: const Center(
                child: Icon(Icons.navigation, color: Color(0xFF0C7489), size: 25),
              ),
            ),
          ),
        ),
      );
      _updateSelection("City Discovery", randomAddress, randomPoint);
    });
    _mapController.move(randomPoint, 15.0);
  }

  // Mevcut konumu al ve odaklan
  Future<void> _checkLocationPermission({bool shouldMove = true}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final myPoint = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _markers.removeWhere((m) => m.key == const Key('user_location'));
        _markers.add(
          Marker(
            key: const Key('user_location'),
            point: myPoint,
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _updateSelection("My Location", "You are here!", myPoint),
              child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
            ),
          )
        );
        if (shouldMove) {
          _mapController.move(myPoint, 15.0);
          _updateSelection("My Location", "You are here!", myPoint);
        }
      });
    } catch (e) {
      debugPrint("Konum hatası: $e");
    }
  }

  // Favorilere ekleme onayı ve isim verme
  void _confirmAddFavorite() {
    if (_selectedPlaceName == null) return;
    final TextEditingController nameController = TextEditingController(text: _selectedPlaceName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Save to Favorites"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Name this place (e.g. Home, Office):"),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final String finalName = nameController.text.trim().isEmpty ? _selectedPlaceName! : nameController.text.trim();
              setState(() {
                _favorites.add({'name': finalName, 'address': _selectedAddress, 'latlng': _selectedLatLng});
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("'$finalName' saved!")));
            }, 
            child: const Text("Save", style: TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  // Favori silme onayı
  void _confirmRemoveFavorite(int index) {
    final String name = _favorites[index]['name'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Remove?"),
        content: Text("Delete '$name' from favorites?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() => _favorites.removeAt(index));
              Navigator.pop(context); // Diyalog kapat
              Navigator.pop(context); // Liste kapat
              _showFavoritesPopup(); // Listeyi tazele
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // Favori ismi düzenleme
  void _editFavoriteName(int index) {
    final TextEditingController editController = TextEditingController(text: _favorites[index]['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Rename"),
        content: TextField(controller: editController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() => _favorites[index]['name'] = editController.text.trim());
              Navigator.pop(context);
              Navigator.pop(context);
              _showFavoritesPopup();
            }, 
            child: const Text("Update")
          ),
        ],
      ),
    );
  }

  // Favoriler listesi pop-up
  void _showFavoritesPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Your Favorites"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _favorites.isEmpty
              ? const Center(child: Text("Empty list!"))
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final fav = _favorites[index];
                    return ListTile(
                      leading: const Icon(Icons.place, color: Color(0xFFFB8F67)),
                      title: Text(fav['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editFavoriteName(index)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => _confirmRemoveFavorite(index)),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _mapController.move(fav['latlng'], 15.0);
                        _updateSelection(fav['name'], fav['address'], fav['latlng']);
                      },
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ HARİTA KATMANI
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(51.7592, 19.4560), 
              initialZoom: 13.0,
              onTap: _handleMapTap, 
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_wondertrip',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // 🔍 ARAMA ÇUBUĞU
          Positioned(
            top: 55, left: 75, right: 70,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: "Search places...",
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0C7489)),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchController.clear()))
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // BUTONLAR: Geri ve Konum
          Positioned(top: 55, left: 20, child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)))),
          Positioned(top: 55, right: 20, child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.my_location), onPressed: () => _checkLocationPermission()))),

          // 📄 ALT PANEL
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.15,
            maxChildSize: 0.90,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(width: 80, height: 5, decoration: BoxDecoration(color: const Color(0xFF616161), borderRadius: BorderRadius.circular(100))),
                      const SizedBox(height: 25),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDesignButton(label: 'Discover', onTap: _moveToRandomLodzLocation),
                          _buildDesignButton(label: 'Favorites', onTap: _showFavoritesPopup),
                        ],
                      ),

                      // SEÇİLEN MEKAN KARTI
                      if (_selectedPlaceName != null) ...[
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.place, color: Color(0xFF0C7489)),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(_selectedPlaceName!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                    IconButton(icon: const Icon(Icons.favorite_border, color: Colors.red), onPressed: _confirmAddFavorite),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(_selectedAddress!, style: const TextStyle(fontSize: 14, color: Color(0xFF616161))),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 600), 
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesignButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.40,
            child: Container(
              width: 140, height: 35,
              decoration: ShapeDecoration(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
            ),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF616161), fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}