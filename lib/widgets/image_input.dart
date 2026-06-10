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

class _ImageInputState extends State<ImageInput> {
  final _picker = ImagePickerService();
  Uint8List? _imageBytes;

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
    Widget preview = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColors.primary,
          size: 34,
        ),
        const SizedBox(height: 8),
        Text(
          l.text('selectImage'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    if (_imageBytes != null) {
      preview = Image.memory(_imageBytes!, fit: BoxFit.cover);
    } else if (widget.initialImageUrl.isNotEmpty) {
      preview = Image.network(
        widget.initialImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported_outlined, size: 36);
        },
      );
    }

    return Semantics(
      button: true,
      label: l.text('selectImage'),
      child: InkWell(
        onTap: _pickImage,
        child: Container(
          height: 170,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(child: preview),
        ),
      ),
    );
  }
}
