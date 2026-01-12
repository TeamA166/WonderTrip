import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_wondertrip/services/auth_service.dart';

class SecurePostImage extends StatefulWidget {
  final String photoPath;
  final double width;
  final double height;
  final BoxFit fit;

  const SecurePostImage({
    super.key,
    required this.photoPath,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
  });

  @override
  State<SecurePostImage> createState() => _SecurePostImageState();
}

class _SecurePostImageState extends State<SecurePostImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // ✅ ADDED: This detects when the list refreshes and data changes
  @override
  void didUpdateWidget(SecurePostImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the path is different, we must fetch the new image
    if (widget.photoPath != oldWidget.photoPath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    // Optional: Reset loading state immediately so UI shows spinner while fetching new image
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _imageBytes = null;
      });
    }

    if (widget.photoPath.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Using your existing logic exactly as requested
    final bytes = await AuthService().getPostImageBytes(widget.photoPath);

    if (mounted) {
      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
        _hasError = bytes == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF119DA4))),
      );
    }

    if (_hasError || _imageBytes == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[400],
        child: const Icon(Icons.broken_image, color: Colors.white, size: 50),
      );
    }

    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true, // Helps prevent white flashes between updates
    );
  }
}