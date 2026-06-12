import 'package:flutter/material.dart';
import 'package:lost_and_found/core/constants/app_colors.dart';
import 'package:lost_and_found/core/constants/post_categories.dart';
import 'package:lost_and_found/core/localization/app_localizations.dart';
import 'package:lost_and_found/models/post_model.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap});

  final PostModel post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostImageSection(post: post, l: l),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 📝 TITLE
                  Text(
                    post.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.text,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  /// 📍 LOCATION
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primary, size: 14),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          post.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.subtext,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// 📄 DESCRIPTION (رجعناه)
                  Text(
                    post.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.subtext,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  /// 🏷 CATEGORY + ACTIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          PostCategories.label(l, post.category),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border_rounded,
                                size: 18, color: AppColors.subtext),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostImageSection extends StatelessWidget {
  const _PostImageSection({
    required this.post,
    required this.l,
  });

  final PostModel post;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        post.imageUrl.isEmpty
            ? Container(
                height: 180,
                color: const Color(0xFFF0EDE8),
                child: const Center(
                  child: Icon(Icons.image_outlined,
                      color: AppColors.primary, size: 48),
                ),
              )
            : Hero(
                tag: post.id,
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: const Color(0xFFF0EDE8),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.primary, size: 40),
                      ),
                    ),
                  ),
                ),
              ),

        /// 🔴🟢 STATUS BADGE
        Positioned(
          top: 12,
          right: 12,
          child: _StatusBadge(type: post.type, l: l),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.type,
    required this.l,
  });

  final String type;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final isLost = type == 'lost';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isLost ? AppColors.secondary : AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        l.text(type),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}