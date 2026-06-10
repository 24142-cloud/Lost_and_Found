import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/widgets/empty_widget.dart';
import 'package:lost_and_found/core/widgets/loading_widget.dart';
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
      appBar: AppBar(title: Text(l.text('myPosts'))),
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.myPosts.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.myPosts.isEmpty) {
            return EmptyWidget(message: l.text('noPostsYet'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetchMyPosts,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              itemCount: provider.myPosts.length,
              itemBuilder: (context, index) {
                final PostModel post = provider.myPosts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostCard(
                    post: post,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/details',
                      arguments: post,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
