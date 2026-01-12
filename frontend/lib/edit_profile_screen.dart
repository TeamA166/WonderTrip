import 'package:flutter/material.dart';
import 'verification_screen.dart';
// Not: Gerçek cihazdan resim seçmek için pubspec.yaml dosyasına 'image_picker' eklenmelidir.

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: "Adam");
  final TextEditingController _surnameController = TextEditingController(text: "Surname");
  final String _currentEmail = "adam@mail.com";
  String _selectedGender = "Male";
  
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  // Fotoğraf seçme simülasyonu
  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Opening Gallery... (Please install 'image_picker' for full functionality)"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // İsim/Soyisim için pop-up düzenleyici
  void _showEditDialog(String title, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit $title"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Enter $title",
                filled: true,
                fillColor: const Color(0xFFE9EDF2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {}); 
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Color(0xFF0C7489), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Cinsiyet Seçim Paneli
  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Gender", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildGenderOption("Male"),
              _buildGenderOption("Female"),
              _buildGenderOption("Prefer not to say"),
              // ✅ 4. Seçenek Eklendi: Not Specified (Belirtilmedi)
              _buildGenderOption("Not specified"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(String gender) {
    return ListTile(
      title: Text(gender),
      leading: Radio<String>(
        value: gender,
        groupValue: _selectedGender,
        activeColor: const Color(0xFF0C7489),
        onChanged: (value) {
          setState(() => _selectedGender = value!);
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() => _selectedGender = gender);
        Navigator.pop(context);
      },
    );
  }

  // Log Out onay pop-up fonksiyonu
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
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

  void _startVerificationFlow(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change $title"),
        content: Text("A verification code will be sent to $_currentEmail. Do you want to proceed?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => VerificationScreen(email: _currentEmail)
                ),
              );
            },
            child: const Text("Verify", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C7489))),
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
        height: size.height, 
        width: size.width,
        child: Stack(
          children: [
            // 1. Üst Gradient Oval Alan
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
                  child: const Center(child: Icon(Icons.arrow_back_ios_new, size: 18)),
                ),
              ),
            ),

            // 3. Profil Resmi Alanı
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.10,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: const ShapeDecoration(color: Color(0xFFE0E0E0), shape: OvalBorder()),
                      child: Center(
                        child: _imagePath == null 
                          ? const Text('P', style: TextStyle(color: Color(0xFF616161), fontSize: 48, fontWeight: FontWeight.w600))
                          : const Icon(Icons.person, size: 70, color: Color(0xFF616161)), 
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF0C7489),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. İsim ve Soyisim
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.28,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '${_nameController.text} ${_surnameController.text}',
                      style: const TextStyle(color: Color(0xFF212121), fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10), 
                    Text(_currentEmail, style: const TextStyle(color: Color(0xFF616161), fontSize: 14)),
                  ],
                ),
              ),
            ),

            // 5. Bilgi Başlığı ve Listesi
            Positioned(
              left: 16,
              right: 16,
              top: size.height * 0.36,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                  const SizedBox(height: 10),
                  _buildClickableRow("Name", _nameController.text, () => _showEditDialog("Name", _nameController)),
                  _buildClickableRow("Surname", _surnameController.text, () => _showEditDialog("Surname", _surnameController)),
                  _buildClickableRow("Gender", _selectedGender, _showGenderPicker),
                  _buildClickableRow("Email", _currentEmail, () => _startVerificationFlow("Email")),
                  _buildClickableRow("Password", "********", () => _startVerificationFlow("Password")),
                  _buildClickableRow("Log Out", "", _showLogoutConfirmation),
                ],
              ),
            ),

            // 6. Kaydet Butonu
            Positioned(
              bottom: size.height * 0.05, 
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!")));
                  Navigator.pop(context);
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(color: const Color(0xFF0C7489), borderRadius: BorderRadius.circular(28)),
                  child: const Center(
                    child: Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableRow(String label, String value, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10), 
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 48,
        decoration: ShapeDecoration(
          color: const Color(0xFFE9EDF2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label, 
              style: TextStyle(
                color: isDestructive ? Colors.red : const Color(0xFF212121), 
                fontSize: 16, 
                fontWeight: FontWeight.w600
              )
            ),
            Row(
              children: [
                if (value.isNotEmpty)
                  Text(value, style: const TextStyle(color: Color(0xFF616161), fontSize: 14)),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios, 
                  size: 14, 
                  color: isDestructive ? Colors.red : const Color(0xFF212121)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}