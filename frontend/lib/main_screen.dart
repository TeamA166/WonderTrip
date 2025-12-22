import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/map_screen.dart';
import 'package:flutter_application_wondertrip/place_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. KAYDIRILABİLİR ANA İÇERİK ---
            SingleChildScrollView(
              child: Container(
                width: 450,
                height: 1000, // Kaydırma alanı için yükseklik biraz artırıldı
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF6F6F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Stack(
                  children: [
                    // --- ANA İÇERİK KATMANI ---
                    Positioned(
                      left: 0,
                      top: 193,
                      child: Container(
                        width: 412,
                        height: 120,
                        decoration: const BoxDecoration(color: Color(0xFFF6F6F6)),
                      ),
                    ),

                    // 'Hi, Adam!' Başlığı
                    const Positioned(
                      left: 16,
                      top: 110,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Hi',
                              style: TextStyle(color: Color(0xFF212121), fontSize: 28, fontFamily: 'Roboto', fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: ', Adam!',
                              style: TextStyle(color: Color(0xFF212121), fontSize: 28, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Alt Başlık
                    const Positioned(
                      left: 16,
                      top: 149,
                      child: Text(
                        'Explore the Lodz',
                        style: TextStyle(color: Color(0xFF616161), fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
                      ),
                    ),

                    // --- DISCOVER NEARBY PLACES BÜTÜNÜ ---

                    // Discover nearby places Metni (left: 136, top: 210)
                    Positioned(
                      left: 136,
                      top: 210,
                      child: SizedBox(
                        width: 177,
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
                          child: const Text(
                            'Discover nearby places',
                            style: TextStyle(
                              color: Color(0xFF212121),
                              fontSize: 22,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Lodz, Poland Metni (left: 136, top: 272)
                    const Positioned(
                      left: 136,
                      top: 272,
                      child: Text(
                        'Lodz, Poland',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // Forward Arrow Konteyner (left: 372, top: 241)
                    Positioned(
                      left: 372,
                      top: 241,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
                        child: Container(
                          width: 16,
                          height: 32,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: const Stack(
                            children: [
                              Center(child: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF212121))),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Navigator İkon Konteyner (left: 39, top: 215)
                    Positioned(
                      left: 39,
                      top: 215,
                      child: Container(
                        width: 64,
                        height: 64,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0C7489),
                          shape: BoxShape.circle,
                        ),
                        child: const Stack(
                          children: [
                            Center(child: Icon(Icons.location_on, color: Colors.white, size: 30)),
                          ],
                        ),
                      ),
                    ),

                    // Must See Spots
                    const Positioned(
                      left: 21,
                      top: 352,
                      child: Text('Must See Spots!', style: TextStyle(color: Color(0xFF212121), fontSize: 22, fontFamily: 'Roboto', fontWeight: FontWeight.w600)),
                    ),
                    
                    Positioned(
                      left: 16,
                      top: 388,
                      child: const Text(
                        'Your Lodz adventure awaits',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // ✅ YATAY KAYDIRMA EKLENDİ: Must See Spots
                    Positioned(
                      left: 0,
                      top: 433,
                      width: 412,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildPlaceCard(context, "Manufaktura", "https://placehold.co/280x220/0C7489/FFFFFF.png?text=Manufaktura"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "Piotrkowska", "https://placehold.co/280x220/FB8F67/FFFFFF.png?text=Piotrkowska"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "Atlas Arena", "https://placehold.co/280x220/333333/FFFFFF.png?text=Atlas+Arena"),
                          ],
                        ),
                      ),
                    ),

                    // Travelers' posts
                    const Positioned(
                      left: 21,
                      top: 672,
                      child: Text("Travelers' posts!", style: TextStyle(color: Color(0xFF212121), fontSize: 22, fontFamily: 'Roboto', fontWeight: FontWeight.w600)),
                    ),

                    const Positioned(
                      left: 21,
                      top: 708,
                      child: Text(
                        'A favorite among travelers',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // ✅ YATAY KAYDIRMA EKLENDİ: Travelers' posts
                    Positioned(
                      left: 0,
                      top: 753,
                      width: 412,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        child: Row(
                          children: [
                            _buildPostCard("https://placehold.co/280x220/BC9B8F/FFFFFF.png"),
                            const SizedBox(width: 20),
                            _buildPostCard("https://placehold.co/280x220/E0E0E0/212121.png"),
                            const SizedBox(width: 20),
                            _buildPostCard("https://placehold.co/280x220/FB8F67/FFFFFF.png"),
                          ],
                        ),
                      ),
                    ),

                    // --- ÖZEL MENÜ TETİKLEYİCİ (48x48 Container - left: 16, top: 60) ---
                    Positioned(
                      left: 16,
                      top: 60,
                      child: GestureDetector(
                        onTap: () => setState(() => _isMenuOpen = true),
                        child: Container(
                          width: 48,
                          height: 48,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(),
                          child: const Stack(
                            children: [
                              Center(child: Icon(Icons.menu, color: Color(0xFF0C7489), size: 32)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. SABİT YAN MENÜ KATMANI (Overlay - Scroll Olmaz) ---
            if (_isMenuOpen) _buildSideMenuOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenuOverlay(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Boşluğa tıklayınca kapatma
          GestureDetector(
            onTap: () => setState(() => _isMenuOpen = false),
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),
          
          // Mavi Ana Gövde (Genişlik 300)
          Container(
            width: 300,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF0C7489)),
            child: Stack(
              children: [
                // Beyaz Profil Dairesi
                Positioned(
                  left: 29,
                  top: 39,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const ShapeDecoration(color: Color(0xFFF6F6F6), shape: OvalBorder()),
                  ),
                ),
                // Gri Profil Sınırı ve İkon
                Positioned(
                  left: 34,
                  top: 44,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF6F6F6),
                      shape: OvalBorder(side: const BorderSide(width: 4, color: Color(0xFFE0E0E0))),
                    ),
                    child: const Icon(Icons.person, size: 50, color: Color(0xFF0C7489)),
                  ),
                ),
                // Kullanıcı İsmi
                const Positioned(
                  left: 145,
                  top: 65,
                  child: Text(
                    'Adam',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
                  ),
                ),
                
                // Ayırıcı Çizgi
                Positioned(
                  left: 16,
                  top: 160,
                  child: Container(width: 260, height: 1, color: const Color(0xFF119DA4)),
                ),

                // Menü Maddeleri (İkonlarla Birlikte)
                Positioned(
                  left: 25,
                  top: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDrawerItem(Icons.home_rounded, 'Home', () => setState(() => _isMenuOpen = false)),
                      const SizedBox(height: 35),
                      _buildDrawerItem(Icons.map_outlined, 'Map', () {
                        setState(() => _isMenuOpen = false);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
                      }),
                      const SizedBox(height: 35),
                      _buildDrawerItem(Icons.person_outline_rounded, 'My Profile', () {}),
                      const SizedBox(height: 35),
                      _buildDrawerItem(Icons.settings_outlined, 'Setting', () {}),
                      
                      // ✅ LOG OUT - BİRAZ DAHA AŞAĞIYA ALINDI
                      const SizedBox(height: 195), 
                      Container(width: 250, height: 1, color: const Color(0xFF119DA4)),
                      const SizedBox(height: 35),
                      _buildDrawerItem(Icons.logout_rounded, 'Log Out', () {
                        Navigator.pushReplacementNamed(context, '/login');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Menü öğelerini (İkon + Metin) oluşturan yardımcı fonksiyon
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, String title, String url) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceDetailScreen())),
      child: Container(
        width: 280,
        height: 220,
        decoration: ShapeDecoration(
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent]),
          ),
          padding: const EdgeInsets.all(15),
          alignment: Alignment.bottomLeft,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
        ),
      ),
    );
  }

  Widget _buildPostCard(String url) {
    return Container(
      width: 280,
      height: 220,
      decoration: ShapeDecoration(
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}