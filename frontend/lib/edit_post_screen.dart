import 'dart:io';
import 'dart:typed_data'; // ✅ Needed for reading bytes
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';
import 'package:flutter_application_wondertrip/location_picker_screen.dart';
import 'package:flutter_application_wondertrip/widgets/secure_image.dart';
// ✅ Import the Custom Cropper
import 'package:flutter_application_wondertrip/widgets/custom_crop_screen.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final AuthService _authService = AuthService();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  LatLng? _selectedLocation;
  File? _newImageFile; // If null, we keep the old photo
  late int _rating;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 1. Pre-fill Text Data
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _rating = widget.post.rating;

    // 2. Pre-fill Location
    _parseCoordinates(widget.post.coordinates);
  }

  void _parseCoordinates(String coordString) {
    try {
      if (coordString.isNotEmpty) {
        final parts = coordString.split(',');
        if (parts.length == 2) {
          double lat = double.parse(parts[0].trim());
          double lng = double.parse(parts[1].trim());
          _selectedLocation = LatLng(lat, lng);
        }
      }
    } catch (e) {
      debugPrint("Error parsing coordinates: $e");
    }
  }

  // ✅ UPDATED: Pick Image -> Custom Crop Screen
  Future<void> _pickImage() async {
    try {
      // 1. Pick
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      // 2. Read Bytes
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      if (!mounted) return;

      // 3. Navigate to Custom Cropper
      final File? croppedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomCropScreen(
            imageBytes: imageBytes,
            aspectRatio: 4 / 3, // ✅ Force 4:3 for Posts
            isCircle: false,    // ✅ Rectangle mode
          ),
        ),
      );

      // 4. Update State
      if (croppedFile != null) {
        setState(() {
          _newImageFile = croppedFile;
        });
      }
    } catch (e) {
      debugPrint("Pick/Crop error: $e");
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

  Future<void> _submitUpdate() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title, Description, and Location are required.")));
      return;
    }

    setState(() => _isLoading = true);

    String coordString = "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}";

    bool success = await _authService.updatePost(
      widget.post.id,
      _titleController.text,
      _descController.text,
      _rating,
      coordString,
      _newImageFile, // Pass null if keeping old photo
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post updated! It is now pending verification.")));
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update post.")));
      }
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int starValue = index + 1;
        return IconButton(
          onPressed: () => setState(() => _rating = starValue),
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
        title: const Text("Edit Post", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Picker (Shows OLD vs NEW)
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _newImageFile != null
                        ? Image.file(_newImageFile!, fit: BoxFit.cover) 
                        : Stack(
                            children: [
                              Positioned.fill(child: SecurePostImage(photoPath: widget.post.photoPath, fit: BoxFit.cover)), 
                              Container(
                                  color: Colors.black26, 
                                  child: const Center(child: Icon(Icons.edit, color: Colors.white, size: 40))
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(child: Text("Tap image to change (4:3 Ratio)", style: TextStyle(color: Colors.grey, fontSize: 12))),
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
                          ? "Select location" 
                          : "Location Selected",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4. Rating
            const Center(child: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))),
            const SizedBox(height: 10),
            _buildStarRating(),

            const SizedBox(height: 30),

            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C7489),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Post", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}