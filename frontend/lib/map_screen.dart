import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Favoriler için basit bir bilgilendirme pop-up'ı
  void _showFavoritesPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Favorites"),
        content: const Text("Your favorites list is currently empty. Start exploring to add places!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ HARİTA GÖRÜNÜMÜ (MOCK)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://placehold.co/1000x1500/119DA4/FFFFFF.png?text=Google+Maps+View+of+Lodz"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Üst Butonlar (Geri Dönüş)
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

          // Alt Navigasyon Paneli
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
                  // Sürükleme göstergesi
                  Container(
                    width: 50, 
                    height: 5, 
                    decoration: BoxDecoration(
                      color: Colors.grey, 
                      borderRadius: BorderRadius.circular(10)
                    )
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

  // ✅ DEPRECATED DÜZELTİLDİ: withOpacity yerine withValues kullanıldı
  Widget _buildNavButton(IconData icon, String label, bool isActive, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.white.withValues(alpha: 0.8) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF616161)),
            const SizedBox(width: 8),
            Text(
              label, 
              style: const TextStyle(
                color: Color(0xFF616161), 
                fontWeight: FontWeight.w600
              )
            ),
          ],
        ),
      ),
    );
  }
}