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

  List<MapEntry<PostModel, int>> _getMatches(
    PostModel currentPost,
    List<PostModel> allPosts,
  ) {
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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text(l.text('postNotFound'))),
      );
    }

    final currentUser = context.read<AuthProvider>().firebaseUser;
    final canEdit = currentUser?.uid == post.userId;
    final postProvider = context.watch<PostProvider>();

    if (_isEditing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(l.text('edit')),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => setState(() => _isEditing = false),
          ),
        ),
        body: PostForm(
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(post: post, l: l),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                // Title & Badges
                _TitleSection(post: post, l: l),
                const SizedBox(height: 20),
                // Description
                _DescriptionSection(post: post, l: l),
                const SizedBox(height: 16),
                // Info Cards
                _InfoSection(post: post, l: l),
                const SizedBox(height: 24),
                // Potential Matches
                Consumer<PostProvider>(
                  builder: (context, postProvider, _) {
                    final matches = _getMatches(post, postProvider.posts);
                    if (matches.isEmpty) return const SizedBox.shrink();
                    return _MatchesSection(matches: matches, l: l);
                  },
                ),
                // Action Buttons for owner
                if (canEdit) ...[
                  const SizedBox(height: 12),
                  _OwnerActions(
                    l: l,
                    onEdit: () => setState(() => _isEditing = true),
                    onDelete: () async {
                      final confirmed = await _confirmDelete(context);
                      if (!confirmed || !context.mounted) return;
                      await context.read<PostProvider>().deletePost(post.id);
                      if (!context.mounted) return;
                      final error =
                          context.read<PostProvider>().errorMessage;
                      if (error == null) {
                        AppSnackbars.showSuccess(
                            context, l.text('postDeleted'));
                        Navigator.pop(context);
                      } else {
                        AppSnackbars.showError(context, error);
                      }
                    },
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero App Bar ──────────────────────────────────────────────────────────────

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.post, required this.l});
  final PostModel post;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl.isNotEmpty;

    return SliverAppBar(
      expandedHeight: hasImage ? 320 : 80,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: AppColors.primary);
                    },
                  ),
                  // Gradient overlay for legibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Type Badge bottom-left
                  Positioned(
                    bottom: 18,
                    left: 20,
                    child: _TypeBadge(type: post.type, l: l),
                  ),
                ],
              )
            : Container(
                color: AppColors.primary,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: _TypeBadge(type: post.type, l: l),
              ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.l});
  final String type;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final isLost = type == 'lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLost
            ? const Color(0xFFE15C4F)
            : const Color(0xFF3FA46A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            l.text(type).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Title Section ─────────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.post, required this.l});
  final PostModel post;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            height: 1.25,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ModernBadge(
              label: PostCategories.label(l, post.category),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              textColor: AppColors.primary,
              icon: Icons.label_outline_rounded,
            ),
            _ModernBadge(
              label: l.text(post.status),
              backgroundColor: post.status == 'open'
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.subtext.withOpacity(0.12),
              textColor: post.status == 'open'
                  ? AppColors.success
                  : AppColors.subtext,
              icon: post.status == 'open'
                  ? Icons.radio_button_checked_rounded
                  : Icons.check_circle_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernBadge extends StatelessWidget {
  const _ModernBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Description Section ───────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.post, required this.l});
  final PostModel post;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.text('description'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.subtext,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post.description,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.text,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.post, required this.l});
  final PostModel post;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(
          icon: Icons.location_on_outlined,
          label: l.text('location'),
          value: post.location,
          iconColor: const Color(0xFF0E6B78),
          iconBackground: const Color(0xFF0E6B78).withOpacity(0.1),
        ),
        const SizedBox(height: 10),
        _InfoCard(
          icon: Icons.phone_outlined,
          label: l.text('contact'),
          value: post.contact,
          iconColor: const Color(0xFF3FA46A),
          iconBackground: const Color(0xFF3FA46A).withOpacity(0.1),
        ),
        const SizedBox(height: 10),
        _InfoCard(
          icon: Icons.calendar_today_outlined,
          label: l.text('date'),
          value: post.date,
          iconColor: const Color(0xFFD4B06A),
          iconBackground: const Color(0xFFD4B06A).withOpacity(0.1),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBackground,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.subtext,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Matches Section ───────────────────────────────────────────────────────────

class _MatchesSection extends StatelessWidget {
  const _MatchesSection({required this.matches, required this.l});
  final List<MapEntry<PostModel, int>> matches;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('✨ ', style: TextStyle(fontSize: 16)),
            Text(
              l.text('potentialMatches'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${matches.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matches.length,
            clipBehavior: Clip.none,
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
  }
}

class _PotentialMatchCard extends StatelessWidget {
  const _PotentialMatchCard({required this.post, required this.score});
  final PostModel post;
  final int score;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/details', arguments: post),
      child: Container(
        width: 148,
        margin: const EdgeInsetsDirectional.only(end: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _MatchCardImage(imageUrl: post.imageUrl),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: score >= 70
                          ? AppColors.success
                          : score >= 50
                              ? AppColors.accent
                              : AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '$score%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: AppColors.subtext,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            post.wilaya,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.subtext,
                              fontWeight: FontWeight.w500,
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
        height: 90,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F4F5), Color(0xFFD0EBF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.primary,
          size: 22,
        ),
      );
    }

    return Image.network(
      imageUrl,
      height: 90,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 90,
          width: double.infinity,
          color: const Color(0xFFF0F0F0),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.subtext,
            size: 22,
          ),
        );
      },
    );
  }
}

// ─── Owner Actions ─────────────────────────────────────────────────────────────

class _OwnerActions extends StatelessWidget {
  const _OwnerActions({
    required this.l,
    required this.onEdit,
    required this.onDelete,
  });
  final AppLocalizations l;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.text('edit'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.text('delete'),
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Delete Dialog ─────────────────────────────────────────────────────────────

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.subtext,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        cancelLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        deleteLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}