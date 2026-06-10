import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/core/utils/matching_engine.dart';
import 'package:lost_and_found/models/post_model.dart';

void main() {
  group('MatchingEngine Quality Tests', () {
    final lostItem = PostModel(
      id: 'lost-1',
      title: 'Black leather wallet with keys',
      description: 'Lost wallet near mosque',
      category: 'Wallets and Money',
      type: 'lost',
      imageUrl: '',
      location: 'Nouakchott Ouest - Tevragh Zeina',
      wilaya: 'Nouakchott Ouest',
      district: 'Tevragh Zeina',
      contact: '22200000000',
      userId: 'user-1',
      userName: 'Ahmed',
      status: 'open',
      createdAt: DateTime.now(),
      date: '2026-06-10',
    );

    final foundItemBase = PostModel(
      id: 'found-1',
      title: 'Black leather wallet with keys', // Identical title for perfect match
      description: 'Found a wallet on the street',
      category: 'Wallets and Money',
      type: 'found',
      imageUrl: '',
      location: 'Nouakchott Ouest - Tevragh Zeina',
      wilaya: 'Nouakchott Ouest',
      district: 'Tevragh Zeina',
      contact: '22200000000',
      userId: 'user-2',
      userName: 'Sidi',
      status: 'open',
      createdAt: DateTime.now(),
      date: '2026-06-10',
    );

    test('Score 100 for perfect match', () {
      final matches = MatchingEngine.getMatches(lostItem, [foundItemBase]);
      expect(matches, hasLength(1));
      expect(matches.first.key.id, 'found-1');
      expect(matches.first.value, 100);
      // Category matches (+40)
      // Wilaya matches (+25)
      // District matches (+15)
      // Keywords match exactly (Jaccard = 1.0) (+20)
      // Total = 100
    });

    test('Score 87 for partial title keyword overlap', () {
      final partialKeywordFound = foundItemBase.copyWith(
        title: 'Leather Wallet found', // keywords: leather, wallet, found (Jaccard with lostItem is 2/6 = 0.33)
      );
      final matches = MatchingEngine.getMatches(lostItem, [partialKeywordFound]);
      expect(matches, hasLength(1));
      expect(matches.first.value, 87); // 40 + 25 + 15 + (0.33 * 20 = 7) = 87
    });

    test('Score 40 for same category only', () {
      final foundOtherLocation = foundItemBase.copyWith(
        id: 'found-other-loc',
        title: 'Unrelated title item', // no keyword matches
        wilaya: 'Adrar',
        district: 'Atar',
      );
      final matches = MatchingEngine.getMatches(lostItem, [foundOtherLocation]);
      expect(matches, hasLength(1));
      expect(matches.first.value, 40);
    });

    test('Category mismatch is capped at 20% and filtered out by relevance threshold', () {
      final keyPostCategoryMismatch = foundItemBase.copyWith(
        id: 'found-keys',
        title: 'Black leather wallet with keys', // shares identical keywords
        category: 'Keys', // Mismatched category!
      );

      final matches = MatchingEngine.getMatches(lostItem, [keyPostCategoryMismatch]);
      // The score before cap would be 0 (category) + 25 (wilaya) + 15 (district) + 20 (title) = 60
      // Because categories are different, the score is capped at 20%
      // Because 20% is less than the relevance threshold (25%), it is filtered out completely.
      expect(matches, isEmpty);
    });

    test('Lost matches only Found and vice versa', () {
      final lostOther = lostItem.copyWith(id: 'lost-2');
      final foundItem = foundItemBase;

      // 1. Lost item matching against other lost item should return no matches
      final lostMatches = MatchingEngine.getMatches(lostItem, [lostOther]);
      expect(lostMatches, isEmpty);

      // 2. Found item matching against lost item should work
      final foundMatches = MatchingEngine.getMatches(foundItem, [lostItem]);
      expect(foundMatches, hasLength(1));
      expect(foundMatches.first.key.id, 'lost-1');
    });

    test('Does not match closed posts', () {
      final closedFound = foundItemBase.copyWith(
        id: 'found-closed',
        status: 'closed',
      );
      final matches = MatchingEngine.getMatches(lostItem, [closedFound]);
      expect(matches, isEmpty);
    });

    test('Filters top 5 highest scoring matches in descending order', () {
      // Create 7 same-category found posts with different matching scores
      final match1 = foundItemBase.copyWith(id: 'm1'); // 100 pts
      
      final match2 = foundItemBase.copyWith(
        id: 'm2',
        title: 'Black leather wallet with keys', // 100 pts
      );
      
      final match3 = foundItemBase.copyWith(
        id: 'm3',
        title: 'Unrelated title item', // category (40) + wilaya (25) + district (15) = 80
      );

      final match4 = foundItemBase.copyWith(
        id: 'm4',
        title: 'Unrelated title item',
        district: 'Sebkha', // category (40) + wilaya (25) = 65
      );

      final match5 = foundItemBase.copyWith(
        id: 'm5',
        title: 'Unrelated title item',
        wilaya: 'Adrar',
        district: 'Atar', // category (40) = 40
      );

      final match6 = foundItemBase.copyWith(
        id: 'm6',
        title: 'Black wallet found', // category (40) + title keywords (Jaccard wallet/black with lostItem is 2/6 = 0.33) -> 0.33 * 20 = 7 pts -> 47 pts
        wilaya: 'Adrar',
        district: 'Atar',
      );

      final pool = [match5, match3, match1, match4, match6, match2];
      final matches = MatchingEngine.getMatches(lostItem, pool);

      // Should return top 5
      expect(matches, hasLength(5));

      // Order should be descending by score
      expect(matches[0].value, 100); // m1 or m2
      expect(matches[1].value, 100); // m1 or m2
      expect(matches[2].value, 80);  // m3
      expect(matches[3].value, 65);  // m4
      expect(matches[4].value, 47);  // m6 (higher than m5 which is 40)
    });
  });
}
