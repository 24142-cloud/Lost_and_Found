import 'dart:math';
import 'package:lost_and_found/models/post_model.dart';

class MatchingEngine {
  /// Computes potential matches for [currentPost] from [allPosts].
  ///
  /// Matching score:
  /// - Same category: +40 points
  /// - Same Wilaya: +25 points
  /// - Same district: +15 points
  /// - Similar title keywords: up to +20 points (calculated using Jaccard Similarity)
  ///
  /// Quality Rules:
  /// - If categories are different, the score is capped at 20% maximum.
  /// - Only matches with a score >= 25% are returned, which ensures that category-mismatched
  ///   items (capped at 20%) are completely filtered out from potential matches.
  ///
  /// Returns the top 5 highest scoring matches.
  static List<MapEntry<PostModel, int>> getMatches(
    PostModel currentPost,
    List<PostModel> allPosts,
  ) {
    final targetType = currentPost.type == 'lost' ? 'found' : 'lost';
    final matches = <MapEntry<PostModel, int>>[];

    for (final candidate in allPosts) {
      if (candidate.id == currentPost.id) continue;
      if (candidate.type != targetType) continue;
      if (candidate.status != 'open') continue;

      int score = 0;
      final isSameCategory = candidate.category == currentPost.category;

      // 1. Same Category (+40)
      if (isSameCategory) {
        score += 40;
      }

      // 2. Same Wilaya (+25)
      if (candidate.wilaya.isNotEmpty &&
          candidate.wilaya == currentPost.wilaya) {
        score += 25;
      }

      // 3. Same District (+15)
      if (candidate.district.isNotEmpty &&
          candidate.district == currentPost.district) {
        score += 15;
      }

      // 4. Keyword Similarity (+20) using Jaccard Similarity Coefficient
      final words1 = currentPost.title
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2)
          .toSet();
      final words2 = candidate.title
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2)
          .toSet();

      if (words1.isNotEmpty && words2.isNotEmpty) {
        final intersection = words1.intersection(words2);
        final union = words1.union(words2);
        final jaccard = intersection.length / union.length;
        score += (jaccard * 20).round();
      }

      // 5. Capping Rule: If categories are different, cap score at 20%
      if (!isSameCategory) {
        score = min(score, 20);
      }

      // 6. Relevance Filter: Only show matches with score >= 25
      if (score >= 25) {
        matches.add(MapEntry(candidate, score));
      }
    }

    // Sort by score descending
    matches.sort((a, b) => b.value.compareTo(a.value));

    // Return the top 5 matches
    return matches.take(5).toList();
  }
}
