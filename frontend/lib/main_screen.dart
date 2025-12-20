import 'package:flutter/material.dart';
// ✅ Dosya isimleri küçük harf ve alt çizgili (snake_case) olmalı
import 'package:flutter_application_wondertrip/map_screen.dart';
import 'package:flutter_application_wondertrip/place_detail_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Üst Kısım: Karşılama
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Hi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                              TextSpan(text: ', Adam!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: Color(0xFF212121))),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                    const Text('Explore the Lodz', style: TextStyle(fontSize: 20, color: Color(0xFF616161))),
                  ],
                ),
              ),

              // 2. Discover Nearby Places (Harita Geçişi)
              GestureDetector(
                onTap: () {
                  // ✅ Dosya isimleri düzeltildiğinde MapScreen sınıfı tanınacaktır
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
                        // ✅ withOpacity yerine yeni standart withValues kullanıldı
                        color: Colors.black.withValues(alpha: 0.05), 
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

              // 3. Must See Spots
              _buildSectionTitle("Must See Spots!", "Your Lodz adventure awaits"),
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _buildPlaceCard(context, "Manufaktura", "https://placehold.co/600x400/0C7489/FFFFFF.png?text=Manufaktura"),
                    _buildPlaceCard(context, "Piotrkowska", "https://placehold.co/600x400/FB8F67/FFFFFF.png?text=Piotrkowska"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 4. Travelers' posts
              _buildSectionTitle("Travelers' posts!", "A favorite among travelers"),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _buildPostCard("https://placehold.co/400x400/BC9B8F/FFFFFF.png"),
                    _buildPostCard("https://placehold.co/400x400/119DA4/FFFFFF.png"),
                    _buildPostCard("https://placehold.co/400x400/FB8F67/FFFFFF.png"),
                  ],
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

  Widget _buildPlaceCard(BuildContext context, String title, String imageUrl) {
    return GestureDetector(
      onTap: () {
        // ✅ Dosya isimleri düzeltildiğinde PlaceDetailScreen sınıfı tanınacaktır
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceDetailScreen()));
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter, 
              end: Alignment.topCenter, 
              colors: [
                Colors.black.withValues(alpha: 0.6), 
                Colors.transparent
              ]
            ),
          ),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.bottomLeft,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPostCard(String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }
}