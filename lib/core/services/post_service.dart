import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/core/constants/firestore_keys.dart';
import 'package:lost_and_found/models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection(FirestoreKeys.posts);

  Future<void> addPost(PostModel post) async {
    await _postsCollection.add(post.toMap());
  }

  Future<List<PostModel>> getPosts() async {
    final snapshot = await _postsCollection
        .orderBy(FirestoreKeys.createdAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<PostModel>> getPostsByType(String type) async {
    final snapshot = await _postsCollection
        .where(FirestoreKeys.type, isEqualTo: type)
        .orderBy(FirestoreKeys.createdAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<PostModel>> getMyPosts(String userId) async {
    final snapshot = await _postsCollection
        .where(FirestoreKeys.userId, isEqualTo: userId)
        .orderBy(FirestoreKeys.createdAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy(FirestoreKeys.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _postsCollection.doc(postId).update(data);
  }
}