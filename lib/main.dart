import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/app/app.dart';
import 'package:lost_and_found/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}