import 'dart:io';
import 'package:flutter/material.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import 'image_input.dart';
import 'post_type_selector.dart';

class PostForm extends StatefulWidget {
  const PostForm({super.key});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String description = '';
  String location = '';
  String contact = '';
  String type = 'lost';
  File? image;

  void submitForm() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    // مؤقتًا نطبع البيانات
    print(title);
    print(description);
    print(location);
    print(contact);
    print(type);
    print(image);

    // لاحقًا نربطها مع provider
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ImageInput(
              onImageSelected: (pickedImage) {
                image = pickedImage;
              },
            ),

            const SizedBox(height: 10),

            CustomTextField(
              hint: "Title",
              onSaved: (value) => title = value!,
            ),

            CustomTextField(
              hint: "Description",
              onSaved: (value) => description = value!,
            ),

            CustomTextField(
              hint: "Location",
              onSaved: (value) => location = value!,
            ),

            CustomTextField(
              hint: "Contact",
              onSaved: (value) => contact = value!,
            ),

            const SizedBox(height: 10),

            PostTypeSelector(
              onTypeSelected: (selectedType) {
                type = selectedType;
              },
            ),

            const SizedBox(height: 20),

            CustomButton(
              text: "Add Post",
              onPressed: submitForm,
            ),
          ],
        ),
      ),
    );
  }
}