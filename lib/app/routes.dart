import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/add_post_page.dart';
import 'package:lost_and_found/pages/home_page.dart';
import 'package:lost_and_found/pages/login_page.dart';
import 'package:lost_and_found/pages/my_posts_page.dart';
import 'package:lost_and_found/pages/post_details_page.dart';
import 'package:lost_and_found/pages/register_page.dart';
import 'package:lost_and_found/pages/splash_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashPage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/home': (context) => const HomePage(),
    '/add-post': (context) => const AddPostPage(),
    '/details': (context) => const PostDetailsPage(),
    '/my-posts': (context) => const MyPostsPage(),
  };
}