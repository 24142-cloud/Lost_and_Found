import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/providers/post_provider.dart';
import 'package:lost_and_found/widgets/post_form.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';

class AddPostPage extends StatelessWidget {
  const AddPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final authProvider = context.read<AuthProvider>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium Hero App Bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient base
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                        ],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 80,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.18),
                      ),
                    ),
                  ),
                  // Title & subtitle
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l.text('addPost'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.text('addPostSubtitle'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Form Body ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: PostForm(
              isLoading: postProvider.isLoading,
              onSubmit: (data) async {
                final user = authProvider.firebaseUser;
                if (user == null) {
                  AppSnackbars.showError(context, l.text('genericError'));
                  return;
                }

                final success = await context.read<PostProvider>().addPost(
                      title: data.title,
                      description: data.description,
                      category: data.category,
                      type: data.type,
                      location: data.location,
                      wilaya: data.wilaya,
                      district: data.district,
                      locationDescription: data.locationDescription,
                      contact: data.contact,
                      userId: user.uid,
                      userName: authProvider.appUser?.name ??
                          user.email ??
                          'User',
                      date: data.date,
                      imageFile: data.imageFile,
                    );

                if (!context.mounted) return;
                if (success) {
                  if (data.imageFile != null) {
                    AppSnackbars.showSuccess(
                        context, l.text('imageUploaded'));
                  }
                  AppSnackbars.showSuccess(context, l.text('postCreated'));
                  Navigator.pop(context);
                } else {
                  AppSnackbars.showError(
                    context,
                    context.read<PostProvider>().errorMessage ??
                        l.text('genericError'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
