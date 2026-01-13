import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/login_screen.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
// ✅ FIXED IMPORT (Removed old cropper, added custom screen)
import 'package:flutter_application_wondertrip/widgets/custom_crop_screen.dart';
import 'package:flutter_application_wondertrip/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false; 
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final results = await Future.wait([
        _authService.getProfile(),
        _authService.getProfileImageBytes(),
      ]);

      if (mounted) {
        setState(() {
          final userData = results[0] as Map<String, dynamic>?;
          _profileImageBytes = results[1] as Uint8List?;
          
          if (userData != null) {
            _nameController.text = userData['name'] ?? "";
            _surnameController.text = userData['surname'] ?? "";
            _emailController.text = userData['email'] ?? "";
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSaveChanges() async {
    setState(() => _isSaving = true);

    bool success = await _authService.updateProfile(
      _nameController.text.trim(),
      _surnameController.text.trim(),
      _emailController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile.")),
        );
      }
    }
  }

  // ✅ NEW IMAGE PICKER LOGIC (Using CustomCropScreen)
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    try {
      // 1. Pick Image from Gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000, 
      );

      if (pickedFile == null) return;

      // 2. Read bytes for our custom cropper
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      if (!mounted) return;

      // 3. Navigate to Custom Crop Screen (Buttons at bottom)
      final File? croppedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomCropScreen(imageBytes: imageBytes),
        ),
      );

      if (croppedFile == null) return; // User cancelled

      setState(() => _isLoading = true);

      // 4. Upload the result
      bool success = await _authService.uploadProfilePhoto(croppedFile);

      if (success) {
        await _loadProfileData(); 
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile photo updated!")));
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to upload photo.")));
        }
      }
    } catch (e) {
      debugPrint("Pick Image Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF119DA4)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER SECTION ---
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Teal Curved Background
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF119DA4),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.elliptical(200, 30),
                            bottomRight: Radius.elliptical(200, 30),
                          ),
                        ),
                      ),
                      
                      // Back Button
                      Positioned(
                        top: topPadding + 10, left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      
                      // Avatar & Camera Button
                      Positioned(
                        bottom: 40,
                        child: Stack(
                          children: [
                            // 1. The Avatar Image
                            Container(
                              width: 110, height: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey[300], shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                image: _profileImageBytes != null
                                    ? DecorationImage(image: MemoryImage(_profileImageBytes!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: _profileImageBytes == null
                                  ? Text(_nameController.text.isNotEmpty ? _nameController.text[0] : "U", style: const TextStyle(fontSize: 40, color: Colors.black54))
                                  : null,
                              alignment: Alignment.center,
                            ),
                            
                            // 2. The Camera Button
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUploadImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0C7489),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // --- NAME DISPLAY ---
                  const SizedBox(height: 10),
                  Text(
                    "${_nameController.text} ${_surnameController.text}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(_emailController.text, style: const TextStyle(fontSize: 14, color: Colors.grey)),

                  const SizedBox(height: 30),

                  // --- EDITABLE FORM SECTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 15),

                        _buildEditableTile("Name", _nameController),
                        _buildEditableTile("Surname", _surnameController),
                        _buildEditableTile("Email", _emailController),
                        
                        _buildStaticTile("Password", "********", onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                        }),
                        
                        _buildStaticTile("Log Out", "", onTap: _handleLogout, isLogout: true),
                        
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleSaveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C7489),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: _isSaving 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableTile(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Enter value",
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.edit, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStaticTile(String label, String value, {VoidCallback? onTap, bool isLogout = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isLogout ? Colors.black87 : Colors.black87)),
            if (value.isNotEmpty)
              Text(value, style: const TextStyle(fontSize: 15, color: Colors.grey)),
            Icon(Icons.arrow_forward_ios, size: 16, color: isLogout ? Colors.black54 : Colors.grey),
          ],
        ),
      ),
    );
  }
}