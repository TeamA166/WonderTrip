import 'package:flutter/material.dart';
import 'legal_screens.dart';
import 'edit_profile_screen.dart';
import 'my_page_screen.dart';
import 'travelers_posts_screen.dart'; // ✅ TravelersPostsScreen için import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Profil bilgileri için değişkenler
  String name = "Adam";
  String surname = "Surname";

  // Dil seçim pop-up'ı
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.language, color: Color(0xFF0C7489)),
            SizedBox(width: 10),
            Text("Language"),
          ],
        ),
        content: const Text(
          "Currently, English is the only supported language in Wonder Trip. We are working on adding more languages soon!",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Çıkış yapma onayı
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out from Wonder Trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text("Yes, Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // 1. Üst Alan Gradient Oval Tasarım
            Positioned(
              left: -size.width * 0.05,
              top: -size.height * 0.15,
              child: Container(
                width: size.width * 1.1,
                height: size.height * 0.4,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.50, -0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [Color(0xFF085C6C), Color(0xFF0C7489), Color(0xFF4FA3B3)],
                  ),
                  shape: OvalBorder(),
                ),
              ),
            ),

            // 2. Geri Butonu
            Positioned(
              left: 16,
              top: 52,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFCFC8C8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Center(child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black)),
                ),
              ),
            ),

            // 3. Profil Görseli
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.12,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const ShapeDecoration(color: Color(0xFFE0E0E0), shape: OvalBorder()),
                  child: const Center(
                    child: Text('P', style: TextStyle(color: Color(0xFF616161), fontSize: 48, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),

            // 4. Kullanıcı Bilgisi
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.32,
              child: Center(
                child: Text('$name, $surname',
                    style: const TextStyle(color: Color(0xFF212121), fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),

            // 5. Ayarlar Menüsü
            Positioned(
              left: 16,
              right: 16,
              top: size.height * 0.38,
              bottom: 0,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuButton('Language', value: 'English', onTap: _showLanguageDialog),
                  const SizedBox(height: 12),
                  _buildMenuButton('Edit Profile', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  }),
                  const SizedBox(height: 12),
                  
                  // My Page Navigation
                  _buildMenuButton('My Page', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPageScreen()));
                  }),
                  const SizedBox(height: 12),
                  
                  // Traveler’s Posts Navigation
                  _buildMenuButton('Traveler’s Posts', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TravelersPostsScreen()));
                  }),
                  
                  const SizedBox(height: 12),
                  _buildMenuButton('Privacy Policy', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                  }),
                  const SizedBox(height: 12),
                  _buildMenuButton('Terms of Service', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()));
                  }),
                  const SizedBox(height: 12),
                  _buildMenuButton('Log Out', onTap: _showLogoutConfirmation),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menü butonlarını oluşturan yardımcı widget
  Widget _buildMenuButton(String title, {String? value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: ShapeDecoration(
          color: const Color(0xFFE9EDF2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, 
              style: const TextStyle(
                color: Color(0xFF212121), 
                fontSize: 16, 
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600
              )
            ),
            Row(
              children: [
                if (value != null) Text(value, style: const TextStyle(color: Color(0xFF616161), fontSize: 14)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF212121)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}