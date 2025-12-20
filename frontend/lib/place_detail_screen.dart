import 'package:flutter/material.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key});

  void _showCommentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Write a Comment"),
        content: const TextField(
          decoration: InputDecoration(hintText: "What do you think about this place?"),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF119DA4)),
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
      body: Stack(
        children: [
          // 🖼️ Üst Görsel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 450,
            child: Image.network("https://placehold.co/800x1000/0C7489/FFFFFF.png?text=Manufaktura", fit: BoxFit.cover),
          ),

          // Alt Detay Paneli
          Positioned(
            top: 410,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Manufaktura', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFF6F7E1), borderRadius: BorderRadius.circular(10)),
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
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF616161), size: 16),
                      SizedBox(width: 4),
                      Text('Łódź, Poland', style: TextStyle(color: Color(0xFF616161))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'A historic 19th-century textile factory turned into a vibrant cultural, shopping, and entertainment complex featuring museums... ',
                          style: TextStyle(color: Color(0xFF616161), fontSize: 16),
                        ),
                        TextSpan(text: 'See more', style: TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Gezgin Avatarları
                  Row(
                    children: [
                      _buildAvatar("https://i.pravatar.cc/100?u=1"),
                      _buildAvatar("https://i.pravatar.cc/100?u=2"),
                      _buildAvatar("https://i.pravatar.cc/100?u=3"),
                      const SizedBox(width: 10),
                      const Text('+12 Travelers', style: TextStyle(color: Color(0xFF616161))),
                    ],
                  ),

                  const Spacer(),

                  // Aksiyon Butonları
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(Icons.comment, "Comment", () => _showCommentPopup(context)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildActionButton(Icons.directions, "Directions", () {}),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Geri Butonu
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: CircleAvatar(radius: 18, backgroundImage: NetworkImage(url)),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF119DA4),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              // ✅ withOpacity yerine withValues kullanıldı (Hata düzeltildi)
              color: Colors.black.withValues(alpha: 0.1), 
              blurRadius: 4, 
              offset: const Offset(0, 2)
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}