import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/app/routes.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/providers/post_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lost & Found',
        routes: AppRoutes.routes,
        initialRoute: '/',
      ),
    );
  }
}