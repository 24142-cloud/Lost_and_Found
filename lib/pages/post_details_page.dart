import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/constants/post_categories.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/core/utils/snackbars.dart';
import 'package:lost_and_found/models/post_model.dart';
import 'package:lost_and_found/providers/auth_provider.dart';
import 'package:lost_and_found/providers/post_provider.dart';
import 'package:lost_and_found/widgets/post_form.dart';
import 'package:lost_and_found/core/utils/matching_engine.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({super.key});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final postProvider = context.read<PostProvider>();
      if (postProvider.posts.isEmpty) {
        postProvider.fetchPosts();
      }
    });
  }

  List<MapEntry<PostModel, int>> _getMatches(PostModel currentPost, List<PostModel> allPosts) {
    return MatchingEngine.getMatches(currentPost, allPosts);
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (context) => DeletePostConfirmationDialog(
            title: l.text('confirmDeleteTitle'),
            message: l.text('confirmDeleteMessage'),
            cancelLabel: l.text('cancel'),
            deleteLabel: l.text('delete'),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final post = ModalRoute.of(context)?.settings.arguments as PostModel?;
    if (post == null) {
      return Scaffold(body: Center(child: Text(l.text('postNotFound'))));
    }

    final currentUser = context.read<AuthProvider>().firebaseUser;
    final canEdit = currentUser?.uid == post.userId;
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.text('details')),
        actions: [
          if (canEdit)
            IconButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              tooltip: l.text('edit'),
              icon: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_outlined,
              ),
            ),
          if (canEdit)
            IconButton(
              onPressed: () async {
                final confirmed = await _confirmDelete(context);
                if (!confirmed || !context.mounted) return;

                await context.read<PostProvider>().deletePost(post.id);
                if (!context.mounted) return;
                final error = context.read<PostProvider>().errorMessage;
                if (error == null) {
                  AppSnackbars.showSuccess(context, l.text('postDeleted'));
                  Navigator.pop(context);
                } else {
                  AppSnackbars.showError(context, error);
                }
              },
              tooltip: l.text('delete'),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: _isEditing
          ? PostForm(
              initialPost: post,
              isLoading: postProvider.isLoading,
              onSubmit: (data) async {
                final success = await context.read<PostProvider>().updatePost(
                  postId: post.id,
                  title: data.title,
                  description: data.description,
                  category: data.category,
                  type: data.type,
                  location: data.location,
                  wilaya: data.wilaya,
                  district: data.district,
                  locationDescription: data.locationDescription,
                  contact: data.contact,
                  status: data.status,
                  date: data.date,
                  imageUrl: data.imageUrl,
                  imageFile: data.imageFile,
                );

                if (!context.mounted) return;
                if (success) {
                  if (data.imageFile != null) {
                    AppSnackbars.showSuccess(context, l.text('imageUploaded'));
                  }
                  AppSnackbars.showSuccess(context, l.text('postUpdated'));
                  Navigator.pop(context);
                } else {
                  AppSnackbars.showError(
                    context,
                    context.read<PostProvider>().errorMessage ??
                        l.text('genericError'),
                  );
                }
              },
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                if (post.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      post.imageUrl,
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 220,
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        );
                      },
                    ),
                  ),
                if (post.imageUrl.isNotEmpty) const SizedBox(height: 18),
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        '${l.text(post.type)} - ${l.text(post.status)}',
                      ),
                    ),
                    Chip(label: Text(PostCategories.label(l, post.category))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    post.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        title: post.location,
                      ),
                      const Divider(height: 1, indent: 56),
                      _DetailRow(
                        icon: Icons.call_outlined,
                        title: post.contact,
                      ),
                      const Divider(height: 1, indent: 56),
                      _DetailRow(
                        icon: Icons.calendar_month_outlined,
                        title: post.date,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Consumer<PostProvider>(
                  builder: (context, postProvider, _) {
                    final matches = _getMatches(post, postProvider.posts);
                    if (matches.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.text('potentialMatches'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final entry = matches[index];
                              return _PotentialMatchCard(
                                post: entry.key,
                                score: entry.value,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _PotentialMatchCard extends StatelessWidget {
  const _PotentialMatchCard({
    required this.post,
    required this.score,
  });

  final PostModel post;
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 140,
      margin: const EdgeInsetsDirectional.only(end: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/details',
              arguments: post,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _MatchCardImage(imageUrl: post.imageUrl),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$score%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        post.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.subtext,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              post.wilaya,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchCardImage extends StatelessWidget {
  const _MatchCardImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 70,
        width: double.infinity,
        color: const Color(0xFFF3EEE8),
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.primary,
          size: 18,
        ),
      );
    }

    return Image.network(
      imageUrl,
      height: 70,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 70,
          width: double.infinity,
          color: const Color(0xFFF3EEE8),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.primary,
            size: 18,
          ),
        );
      },
    );
  }
}

class DeletePostConfirmationDialog extends StatelessWidget {
  const DeletePostConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.deleteLabel,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(deleteLabel),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
