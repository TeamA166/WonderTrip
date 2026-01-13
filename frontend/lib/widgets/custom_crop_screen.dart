import 'dart:io';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CustomCropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final double aspectRatio; 
  final bool isCircle;      

  const CustomCropScreen({
    super.key, 
    required this.imageBytes,
    this.aspectRatio = 1.0, 
    this.isCircle = false,  
  });

  @override
  State<CustomCropScreen> createState() => _CustomCropScreenState();
}

class _CustomCropScreenState extends State<CustomCropScreen> {
  final _controller = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // ✅ 1. PADDING: Keeps the image (and dots) away from screen edges
              child: Padding(
                padding: const EdgeInsets.all(40.0), 
                child: Crop(
                  image: widget.imageBytes,
                  controller: _controller,
                  onCropped: (image) async {
                    final tempDir = await getTemporaryDirectory();
                    final uniqueId = DateTime.now().millisecondsSinceEpoch;
                    final file = await File('${tempDir.path}/crop_$uniqueId.jpg').create();
                    await file.writeAsBytes(image);

                    if (mounted) Navigator.of(context).pop(file);
                  },
                  aspectRatio: widget.aspectRatio, 
                  withCircleUi: widget.isCircle,
                  
                  // ✅ 2. INTERACTIVE FALSE: 
                  // Locks the image in the center. 
                  // The user moves the BOX, not the IMAGE. 
                  // This ensures the box can never leave the padded area.
                  interactive: false,

                  // ✅ 3. INITIAL SIZE:
                  // Starts the box at 90% size so dots aren't on the edge immediately
                  initialSize: 0.9, 

                  baseColor: Colors.black,
                  maskColor: Colors.black.withOpacity(0.7),
                  radius: 0, 
                  
                  // Optional: Make dots easier to see
                  cornerDotBuilder: (size, edgeAlignment) => const DotControl(color: Color(0xFF0C7489)),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  _isCropping 
                    ? const CircularProgressIndicator(color: Color(0xFF0C7489))
                    : ElevatedButton(
                        onPressed: () {
                          setState(() => _isCropping = true);
                          _controller.crop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C7489),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}