import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/services/image_picker_service.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onChanged,
    this.initialImageUrl = '',
  });

  final ValueChanged<XFile?> onChanged;
  final String initialImageUrl;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePickerService();
  Uint8List? _imageBytes;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage();
    if (!mounted) return;

    debugPrint('Selected image: ${image?.path ?? 'none'}');
    final imageBytes = await image?.readAsBytes();
    if (!mounted) return;

    setState(() => _imageBytes = imageBytes);
    widget.onChanged(image);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasImage =
        _imageBytes != null || widget.initialImageUrl.isNotEmpty;

    return Semantics(
      button: true,
      label: l.text('selectImage'),
      child: GestureDetector(
        onTap: _pickImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: hasImage ? 200 : 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: hasImage
                ? Colors.black
                : AppColors.primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasImage
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: hasImage
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage ? _buildPreview() : _buildUploadPlaceholder(l),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    Widget img;
    if (_imageBytes != null) {
      img = Image.memory(_imageBytes!, fit: BoxFit.cover,
          width: double.infinity, height: double.infinity);
    } else {
      img = Image.network(
        widget.initialImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_not_supported_outlined,
                size: 36, color: Colors.white54),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        img,
        // Tap-to-change overlay
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(AppLocalizations l) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.text('selectImage'),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'JPG, PNG — optional',
            style: TextStyle(
              color: AppColors.subtext.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
