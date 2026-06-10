import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lost_and_found/core/constants/firestore_keys.dart';
import 'package:lost_and_found/models/post_model.dart';

abstract class PostRepository {
  Future<String> addPost(PostModel post);
  Future<List<PostModel>> getPosts();
  Future<List<PostModel>> getPostsByType(String type);
  Future<List<PostModel>> getMyPosts(String userId);
  Stream<List<PostModel>> getPostsStream();
  Future<void> deletePost(String postId);
  Future<void> updatePost(String postId, Map<String, dynamic> data);
  Future<PostModel?> getPost(String postId);
}

class PostService implements PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection(FirestoreKeys.posts);

  @override
  Future<String> addPost(PostModel post) async {
    debugPrint('PostService.addPost saved userId=${post.userId}');
    final doc = await _postsCollection.add(post.toMap());
    final savedDoc = await doc.get();
    debugPrint(
      'PostService.addPost document=${doc.id} fields=${savedDoc.data()?.keys.toList()}',
    );
    return doc.id;
  }

  @override
  Future<List<PostModel>> getPosts() async {
    final snapshot = await _postsCollection
        .orderBy(FirestoreKeys.createdAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<PostModel>> getPostsByType(String type) async {
    final snapshot = await _postsCollection
        .where(FirestoreKeys.type, isEqualTo: type)
        .orderBy(FirestoreKeys.createdAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<PostModel>> getMyPosts(String userId) async {
    debugPrint(
      'PostService.getMyPosts query: posts where ${FirestoreKeys.userId} == $userId',
    );
    final snapshot = await _postsCollection
        .where(FirestoreKeys.userId, isEqualTo: userId)
        .get();

    final posts = snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
    posts.sort((a, b) {
      final aCreatedAt = a.createdAt;
      final bCreatedAt = b.createdAt;
      if (aCreatedAt == null && bCreatedAt == null) return 0;
      if (aCreatedAt == null) return 1;
      if (bCreatedAt == null) return -1;
      return bCreatedAt.compareTo(aCreatedAt);
    });
    debugPrint('PostService.getMyPosts returned ${posts.length} posts');

    return posts;
  }

  @override
  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy(FirestoreKeys.createdAt, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PostModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  @override
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _postsCollection.doc(postId).update(data);
  }

  @override
  Future<PostModel?> getPost(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists || doc.data() == null) return null;

    return PostModel.fromMap(doc.id, doc.data()!);
  }
}
