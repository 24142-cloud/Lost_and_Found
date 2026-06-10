import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/core/services/cloudinary_service.dart';
import 'package:lost_and_found/core/services/post_service.dart';
import 'package:lost_and_found/models/post_model.dart';
import 'package:lost_and_found/providers/post_provider.dart';

void main() {
  test('addPost returns true and updates local lists', () async {
    final posts = _FakePostRepository();
    final provider = PostProvider(
      postService: posts,
      imageUploadService: _FakeImageUploadRepository(),
    );

    final success = await provider.addPost(
      title: 'Bag',
      description: 'Lost black bag',
      category: 'Bag',
      type: 'lost',
      location: 'Nouakchott Ouest - Ksar',
      wilaya: 'Nouakchott Ouest',
      district: 'Ksar',
      locationDescription: '',
      contact: '22200000000',
      userId: 'user-1',
      userName: 'Aicha',
      date: '2026-05-25',
    );

    expect(success, isTrue);
    expect(provider.posts, hasLength(1));
    expect(provider.myPosts, hasLength(1));
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('addPost cleans uploaded image when Firestore create fails', () async {
    final uploader = _FakeImageUploadRepository(
      uploadedUrl: 'https://image.test/1',
    );
    final provider = PostProvider(
      postService: _FakePostRepository(shouldFailAdd: true),
      imageUploadService: uploader,
    );

    final success = await provider.addPost(
      title: 'Bag',
      description: 'Lost black bag',
      category: 'Bag',
      type: 'lost',
      location: 'Nouakchott Ouest - Ksar',
      wilaya: 'Nouakchott Ouest',
      district: 'Ksar',
      locationDescription: '',
      contact: '22200000000',
      userId: 'user-1',
      userName: 'Aicha',
      date: '2026-05-25',
      imageFile: XFile.fromData(
        Uint8List.fromList(<int>[1, 2, 3]),
        name: 'test-image.jpg',
        mimeType: 'image/jpeg',
      ),
    );

    expect(success, isFalse);
    expect(uploader.deletedUrls, contains('https://image.test/1'));
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNotNull);
  });
}

class _FakePostRepository implements PostRepository {
  _FakePostRepository({this.shouldFailAdd = false});

  final bool shouldFailAdd;
  final List<PostModel> posts = [];

  @override
  Future<String> addPost(PostModel post) async {
    if (shouldFailAdd) throw Exception('create failed');

    final id = 'post-${posts.length + 1}';
    posts.add(post.copyWith(id: id));
    return id;
  }

  @override
  Future<void> deletePost(String postId) async {
    posts.removeWhere((post) => post.id == postId);
  }

  @override
  Future<PostModel?> getPost(String postId) async {
    for (final post in posts) {
      if (post.id == postId) return post;
    }

    return null;
  }

  @override
  Future<List<PostModel>> getMyPosts(String userId) async {
    return posts.where((post) => post.userId == userId).toList();
  }

  @override
  Future<List<PostModel>> getPosts() async {
    return List<PostModel>.from(posts);
  }

  @override
  Future<List<PostModel>> getPostsByType(String type) async {
    return posts.where((post) => post.type == type).toList();
  }

  @override
  Stream<List<PostModel>> getPostsStream() {
    return Stream.value(posts);
  }

  @override
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {}
}

class _FakeImageUploadRepository implements ImageUploadRepository {
  _FakeImageUploadRepository({this.uploadedUrl = ''});

  final String uploadedUrl;
  final List<String> deletedUrls = [];

  @override
  Future<void> deleteImageByUrl(String imageUrl) async {
    deletedUrls.add(imageUrl);
  }

  @override
  Future<String> uploadImage(XFile image) async {
    return uploadedUrl;
  }
}
