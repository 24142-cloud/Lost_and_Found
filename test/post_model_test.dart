import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/models/post_model.dart';

void main() {
  test('PostModel serializes Firestore fields', () {
    final createdAt = DateTime(2026, 5, 25);
    final post = PostModel(
      id: 'post-1',
      title: 'Phone',
      description: 'Lost near market',
      category: 'Electronics',
      type: 'lost',
      imageUrl: '',
      location: 'Nouakchott Ouest - Ksar',
      wilaya: 'Nouakchott Ouest',
      district: 'Ksar',
      locationDescription: '',
      contact: '22200000000',
      userId: 'user-1',
      userName: 'Ahmed',
      status: 'open',
      createdAt: createdAt,
      date: '2026-05-25',
    );

    final map = post.toMap();

    expect(map['title'], 'Phone');
    expect(map['category'], 'Electronics');
    expect(map['postType'], 'lost');
    expect(map['wilaya'], 'Nouakchott Ouest');
    expect(map['district'], 'Ksar');
    expect(map['createdAt'], isA<Timestamp>());
  });

  test('PostModel uses server timestamp when createdAt is null', () {
    final post = PostModel(
      id: '',
      title: 'Keys',
      description: 'Found keys',
      category: 'Keys',
      type: 'found',
      imageUrl: '',
      location: 'Tevragh Zeina',
      contact: '22200000000',
      userId: 'user-1',
      userName: 'Mariam',
      status: 'open',
      createdAt: null,
      date: '2026-05-25',
    );

    expect(post.toMap()['createdAt'], isA<FieldValue>());
  });
}
