import 'package:flutter/material.dart';
import '../widgets/post_form.dart';


class AddPostPage extends StatelessWidget {
  const AddPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Post"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: PostForm(),

      ),
    );
  }
}