import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // ✅ Import this
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/location_picker_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final AuthService _authService = AuthService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  LatLng? _selectedLocation;
  File? _imageFile;
  int _rating = 5;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // ✅ UPDATED: Pick AND Crop Image
  Future<void> _pickImage() async {
    // 1. Pick Image
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // 2. Crop Image immediately
      await _cropImage(File(pickedFile.path));
    }
  }

  // ✅ NEW: Crop Logic
  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      // Fixed Aspect Ratio to match your feed cards (e.g., 4:3 is standard for posts)
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3), 
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Photo',
          toolbarColor: const Color(0xFF0C7489), // Your App Color
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio4x3,
          lockAspectRatio: true, // Force the user to keep the rectangle shape
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Edit Photo',
          aspectRatioLockEnabled: true, // Force rectangle on iOS too
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialLocation: _selectedLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _imageFile == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields, pick a location, and add a photo")));
      return;
    }

    setState(() => _isLoading = true);

    String coordString = "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}";

    bool success = await _authService.publishPost(
      _titleController.text,
      _descController.text,
      _rating,
      coordString,
      _imageFile!,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post published successfully!")));
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to publish post.")));
      }
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int starValue = index + 1;
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = starValue;
            });
          },
          icon: Icon(
            starValue <= _rating ? Icons.star : Icons.star_border,
            color: starValue <= _rating ? Colors.amber : Colors.grey,
            size: 40,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Share a Moment", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Picker (Preview shows the exact crop)
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio( // ✅ Force the preview to match the crop ratio (4:3)
                aspectRatio: 4 / 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _imageFile != null 
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null,
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("Tap to add photo", style: TextStyle(color: Colors.grey)),
                            Text("(4:3 Ratio)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            
            // Helpful hint text
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    "This is exactly how it will appear in the feed.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 2. Text Fields
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: const Color(0xFFF6F6F6),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: const Color(0xFFF6F6F6),
              ),
            ),
            
            const SizedBox(height: 20),

            // 3. Location Picker
            GestureDetector(
              onTap: _pickLocation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Color(0xFF119DA4)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        _selectedLocation == null 
                          ? "Tap to select location" 
                          : "Location Selected",
                        style: TextStyle(
                          color: _selectedLocation == null ? Colors.grey : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_selectedLocation != null)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4. Rating
            const Center(child: Text("Rate your experience", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
            const SizedBox(height: 10),
            
            _buildStarRating(),

            const SizedBox(height: 30),

            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C7489),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Publish Post", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}