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

  Future<void> _loadImage() async {
    if (widget.photoPath.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

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
        child: const Center(child: CircularProgressIndicator()),
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
    );
  }
}