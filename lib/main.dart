import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/add_post_page.dart';
import 'package:lost_and_found/app/app.dart';
import 'package:lost_and_found/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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