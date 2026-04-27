import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function(File pickedImage) onImageSelected;

  const ImageInput({
    super.key,
    required this.onImageSelected,
  });

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _imageFile;
  bool _isLoading = false; // ✅ loader

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    setState(() {
      _isLoading = true; // ⏳ شروع loading
    });

    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final image = File(pickedFile.path);

      setState(() {
        _imageFile = image;
        _isLoading = false;
      });

      widget.onImageSelected(image);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(), // ⏳ loader UI
                )
              : _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : const Center(
                      child: Text("No image selected"),
                    ),
        ),

        const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text("Choose Image"),
        ),

        // ❌ Bouton supprimer (affiché فقط إذا كاينة صورة)
        if (_imageFile != null)
          TextButton.icon(
            onPressed: _removeImage,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              "Remove Image",
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}