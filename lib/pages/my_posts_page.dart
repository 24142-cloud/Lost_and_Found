import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/widgets/post_card.dart';
import 'package:lost_and_found/models/post_model.dart';
import 'package:lost_and_found/providers/post_provider.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  @override
  void initState() {
    super.initState();
    final postProvider = context.read<PostProvider>();
    Future.microtask(postProvider.fetchMyPosts);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.fetchMyPosts,
            color: AppColors.primary,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverHeader(context),
                if (provider.isLoading && provider.myPosts.isEmpty)
                  const SliverFillRemaining(
                    child: _MyPostsSkeletonLoader(),
                  )
                else if (provider.myPosts.isEmpty)
                  SliverFillRemaining(
                    child: _MyPostsEmptyState(message: l.text('noPostsYet')),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    sliver: SliverList.separated(
                      itemCount: provider.myPosts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final PostModel post = provider.myPosts[index];
                        return PostCard(
                          post: post,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: post,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    final l = AppLocalizations.of(context);
  return SliverToBoxAdapter(
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Back Button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),

              child: Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.text,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          /// Title
          Text(
            l.text('myPosts'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 8),

          /// Subtitle
          Text(
            l.text('messag_subTitle'),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.subtext,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          /// Small divider
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    ),
  );
}
}




class _MyPostsEmptyState extends StatelessWidget {
  final String message;
  const _MyPostsEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {

    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.article_outlined,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.subtext,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              child: Text(
                l.text('addPost'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPostsSkeletonLoader extends StatefulWidget {
  const _MyPostsSkeletonLoader();

  @override
  State<_MyPostsSkeletonLoader> createState() => _MyPostsSkeletonLoaderState();
}

class _MyPostsSkeletonLoaderState extends State<_MyPostsSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats skeleton
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      child: _skeletonBox(height: 80, radius: 16),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Card skeletons
              ...List.generate(4, (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _skeletonBox(height: 110, radius: 16),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _skeletonBox({required double height, double radius = 8}) {
    return Opacity(
      opacity: _animation.value,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
