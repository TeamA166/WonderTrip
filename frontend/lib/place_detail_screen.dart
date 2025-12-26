import 'package:flutter/material.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key});

  // Yorum yapma diyaloğu
  void _showCommentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Write a Comment"),
        content: const TextField(
          decoration: InputDecoration(
            hintText: "What do you think about this place?",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF119DA4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Post", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🖼️ Arka Plan Görseli
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55, // Ekranın %55'i
            child: Image.network(
              "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?q=80&w=1000", // Manufaktura benzeri bir görsel
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF0C7489),
                child: const Icon(Icons.image, color: Colors.white, size: 50),
              ),
            ),
          ),

          // 📄 Detay Paneli (Kaydırılabilir İçerik)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.48, // Görselle hafif iç içe geçme
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                child: Column(
                  children: [
                    // İçerik Alanı (Kaydırılabilir)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(30, 35, 30, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Başlık ve Puan
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Manufaktura',
                                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F7E1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.star, color: Color(0xFFCDC553), size: 18),
                                      SizedBox(width: 4),
                                      Text('4.7', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Konum
                            const Row(
                              children: [
                                Icon(Icons.location_on, color: Color(0xFF616161), size: 16),
                                SizedBox(width: 4),
                                Text('Łódź, Poland', style: TextStyle(color: Color(0xFF616161), fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 25),
                            // Açıklama
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'A historic 19th-century textile factory turned into a vibrant cultural, shopping, and entertainment complex featuring museums, a cinema, and over 300 stores... ',
                                    style: TextStyle(color: Color(0xFF616161), fontSize: 16, height: 1.5),
                                  ),
                                  TextSpan(
                                    text: 'See more',
                                    style: TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Gezginler
                            const Text('Recently visited by', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildAvatar("https://i.pravatar.cc/100?u=1"),
                                _buildAvatar("https://i.pravatar.cc/100?u=2"),
                                _buildAvatar("https://i.pravatar.cc/100?u=3"),
                                const SizedBox(width: 10),
                                const Text('+12 Travelers', style: TextStyle(color: Color(0xFF616161))),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    // Alt Butonlar (Sabit)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(Icons.comment_outlined, "Comment", () => _showCommentPopup(context)),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildActionButton(Icons.directions_outlined, "Directions", () {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Geri Butonu (Safe Area destekli)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey[300],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF119DA4),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}