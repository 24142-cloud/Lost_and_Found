class AppRoutes {
  static final routes = {
    '/': (context) => const SplashPage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/home': (context) => const HomePage(),
    '/add-post': (context) => const AddPostPage(),
    '/details': (context) => const PostDetailsPage(),
    '/my-posts': (context) => const MyPostsPage(),
  };
}