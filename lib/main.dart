import 'package:flutter/material.dart';
import 'pages/add_post_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AddPostPage(),
// Scaffold(
//         appBar: AppBar(
//           title: const Text('Mon App'),
//         ),
//         body: const Center(
//           child: Text('Hi'),
//         ),
//       ),
    );
  }
}