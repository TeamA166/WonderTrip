import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/map_screen.dart';
import 'package:flutter_application_wondertrip/place_detail_screen.dart';
import 'package:flutter_application_wondertrip/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isMenuOpen = false;

  // Çıkış onay diyaloğu (İngilizce)
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out of Wonder Trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text("Yes, Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
                height: 1100, // İçerik arttığı için yükseklik biraz artırıldı
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    // Arka Plan Katmanı
                    Positioned(
                      left: 0,
                      top: 193,
                      child: Container(
                        width: 412,
                        height: 120,
                        decoration: const BoxDecoration(color: Color(0xFFF6F6F6)),
                      ),
                    ),

                    // Başlık Bloğu
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

                    const Positioned(
                      left: 16,
                      top: 149,
                      child: Text(
                        'Explore the Lodz',
                        style: TextStyle(color: Color(0xFF616161), fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
                      ),
                    ),

                    // Discover Nearby Places Bölümü
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

                    Positioned(
                      left: 372,
                      top: 241,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
                        child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF212121)),
                      ),
                    ),

                    Positioned(
                      left: 39,
                      top: 215,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0C7489),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 30),
                      ),
                    ),

                    const Positioned(
                      left: 21,
                      top: 352,
                      child: Text('Must See Spots!', style: TextStyle(color: Color(0xFF212121), fontSize: 22, fontFamily: 'Roboto', fontWeight: FontWeight.w600)),
                    ),
                    
                    const Positioned(
                      left: 16,
                      top: 388,
                      child: Text(
                        'Your Lodz adventure awaits',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // --- Must See Spots Listesi (10 Mekan) ---
                    Positioned(
                      left: 0,
                      top: 433,
                      width: 412,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildPlaceCard(context, "Manufaktura", "assets/images/manufaktura1.png"), // Sadece buraya 1 eklendi
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "EC1 Łódź", "assets/images/ec1.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "City Museum", "assets/images/city_museum.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "Textile Museum", "assets/images/textile_museum.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "Księży Młyn", "assets/images/ksiezy_mlyn.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "MS1 Art Museum", "assets/images/ms1.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "MS2 Art Museum", "assets/images/ms2.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "Cinema Museum", "assets/images/cinema_museum.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "Jewish Cemetery", "assets/images/jewish_cemetery.png"),
                            const SizedBox(width: 20),
                            _buildPlaceCard(context, "Herbst Palace", "assets/images/herbst_palace.png"),
                          ],
                        ),
                      ),
                    ),

                    const Positioned(
                      left: 21,
                      top: 680,
                      child: Text("Travelers' posts!", style: TextStyle(color: Color(0xFF212121), fontSize: 22, fontFamily: 'Roboto', fontWeight: FontWeight.w600)),
                    ),

                    const Positioned(
                      left: 21,
                      top: 715,
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

                    Positioned(
                      left: 0,
                      top: 760,
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

                    // Sol Üst Menü Butonu
                    Positioned(
                      left: 16,
                      top: 60,
                      child: GestureDetector(
                        onTap: () => setState(() => _isMenuOpen = true),
                        child: const Icon(Icons.menu, color: Color(0xFF0C7489), size: 32),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. SABİT YAN MENÜ KATMANI ---
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
          GestureDetector(
            onTap: () => setState(() => _isMenuOpen = false),
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),
          
          Container(
            width: 300,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF0C7489)),
            child: Stack(
              children: [
                Positioned(
                  left: 29,
                  top: 39,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const ShapeDecoration(color: Color(0xFFF6F6F6), shape: OvalBorder()),
                  ),
                ),
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
                const Positioned(
                  left: 145,
                  top: 65,
                  child: Text(
                    'Adam',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'Roboto', fontWeight: FontWeight.w600),
                  ),
                ),
                
                Positioned(
                  left: 16,
                  top: 160,
                  child: Container(width: 260, height: 1, color: const Color(0xFF119DA4)),
                ),

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
                      _buildDrawerItem(Icons.person_outline_rounded, 'My Page', () {}),
                      const SizedBox(height: 35),
                      _buildDrawerItem(Icons.settings_outlined, 'Settings', () {
                        setState(() => _isMenuOpen = false);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      }),
                      
                      const SizedBox(height: 195), 
                      Container(width: 250, height: 1, color: const Color(0xFF119DA4)),
                      const SizedBox(height: 35),
                      _buildDrawerItem(Icons.logout_rounded, 'Log Out', () {
                        _showLogoutConfirmation(context);
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

  // Mekan kartı tasarımı (Asset desteği ve hata yönetimi ile)
  Widget _buildPlaceCard(BuildContext context, String title, String assetPath) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlaceDetailScreen())),
      child: Container(
        width: 280,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Ana Görsel: Asset üzerinden yükleme denemesi
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Görsel yüklenemezse debug bilgisini ekrana yansıtıyoruz
                  debugPrint("Asset Error for '$assetPath': $error");
                  return Container(
                    color: const Color(0xFF0C7489).withValues(alpha: 0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, color: Color(0xFF0C7489), size: 40),
                          const SizedBox(height: 8),
                          Text(
                            "Not Found:\n${assetPath.split('/').last}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF0C7489)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Alt Kısımdaki Başlık Alanı (Gradient ile)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(15),
                alignment: Alignment.bottomLeft,
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                ),
              ),
            ],
          ),
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