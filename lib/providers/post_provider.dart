import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found/core/constants/firestore_keys.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found/core/services/cloudinary_service.dart';
import 'package:lost_and_found/core/services/post_service.dart';
import 'package:lost_and_found/models/post_model.dart';

class PostProvider extends ChangeNotifier {
  PostProvider({
    PostRepository? postService,
    ImageUploadRepository? imageUploadService,
  }) : _postService = postService ?? PostService(),
       _imageUploadService = imageUploadService ?? CloudinaryService();

  final PostRepository _postService;
  final ImageUploadRepository _imageUploadService;

  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> _posts = [];
  List<PostModel> _myPosts = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PostModel> get posts => _posts;
  List<PostModel> get myPosts => _myPosts;

  Future<void> fetchPosts() async {
    _setLoading(true);
    _clearError();

    try {
      await _loadPosts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPostsByType(String type) async {
    _setLoading(true);
    _clearError();

    try {
      _posts = await _postService.getPostsByType(type);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyPosts() async {
    _setLoading(true);
    _clearError();

    try {
      await _loadMyPosts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addPost({
    required String title,
    required String description,
    required String category,
    required String type,
    required String location,
    required String wilaya,
    required String district,
    required String locationDescription,
    required String contact,
    required String userId,
    required String userName,
    required String date,
    XFile? imageFile,
  }) async {
    _setLoading(true);
    _clearError();
    var uploadedImageUrl = '';
    var postCreated = false;

    try {
      final currentUid = _currentFirebaseUid();
      debugPrint('PostProvider.addPost currentUser.uid=$currentUid');
      debugPrint('PostProvider.addPost saved userId=$userId');

      if (imageFile != null) {
        debugPrint('Selected image: ${imageFile.path}');
        uploadedImageUrl = await _imageUploadService.uploadImage(imageFile);
      }

      final post = PostModel(
        id: '',
        title: title,
        description: description,
        category: category,
        type: type,
        imageUrl: uploadedImageUrl,
        location: location,
        wilaya: wilaya,
        district: district,
        locationDescription: locationDescription,
        contact: contact,
        userId: userId,
        userName: userName,
        status: 'open',
        createdAt: null,
        date: date,
      );

      await _postService.addPost(post);
      debugPrint('Firestore post created');
      postCreated = true;
      await _refreshPostsAfterWrite(fallbackUserId: userId);
      notifyListeners();
      return true;
    } catch (e) {
      if (!postCreated && uploadedImageUrl.isNotEmpty) {
        await _tryDeleteImage(uploadedImageUrl);
      }
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePost({
    required String postId,
    required String title,
    required String description,
    required String category,
    required String type,
    required String location,
    required String wilaya,
    required String district,
    required String locationDescription,
    required String contact,
    required String status,
    required String date,
    String imageUrl = '',
    XFile? imageFile,
  }) async {
    _setLoading(true);
    _clearError();
    var uploadedImageUrl = '';

    try {
      var nextImageUrl = imageUrl;

      if (imageFile != null) {
        debugPrint('Selected image: ${imageFile.path}');
        uploadedImageUrl = await _imageUploadService.uploadImage(imageFile);
        nextImageUrl = uploadedImageUrl;
      }

      await _postService.updatePost(postId, {
        FirestoreKeys.title: title,
        FirestoreKeys.description: description,
        FirestoreKeys.type: type,
        FirestoreKeys.postType: type,
        FirestoreKeys.category: category,
        FirestoreKeys.imageUrl: nextImageUrl,
        FirestoreKeys.location: location,
        FirestoreKeys.wilaya: wilaya,
        FirestoreKeys.district: district,
        FirestoreKeys.locationDescription: locationDescription,
        FirestoreKeys.contact: contact,
        FirestoreKeys.phoneNumber: contact,
        FirestoreKeys.status: status,
        FirestoreKeys.date: date,
      });
      debugPrint('Firestore post updated');

      if (uploadedImageUrl.isNotEmpty && imageUrl.isNotEmpty) {
        await _tryDeleteImage(imageUrl);
      }

      await _refreshPostsAfterWrite();
      notifyListeners();
      return true;
    } catch (e) {
      if (uploadedImageUrl.isNotEmpty) {
        await _tryDeleteImage(uploadedImageUrl);
      }
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePost(String postId) async {
    _setLoading(true);
    _clearError();

    try {
      final post = _findCachedPost(postId);
      await _postService.deletePost(postId);

      if (post?.imageUrl.isNotEmpty ?? false) {
        await _tryDeleteImage(post!.imageUrl);
      }

      _posts.removeWhere((post) => post.id == postId);
      _myPosts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadPosts() async {
    _posts = await _postService.getPosts();
  }

  Future<void> _loadMyPosts({String? fallbackUserId}) async {
    final currentUid = _currentFirebaseUid();
    final userId = fallbackUserId ?? currentUid;
    debugPrint('PostProvider.fetchMyPosts currentUser.uid=$currentUid');
    debugPrint(
      'PostProvider.fetchMyPosts query: posts where ${FirestoreKeys.userId} == $userId',
    );

    if (userId == null) {
      _myPosts = [];
      debugPrint('PostProvider.fetchMyPosts returned 0 posts');
      return;
    }

    _myPosts = await _postService.getMyPosts(userId);
    debugPrint('PostProvider.fetchMyPosts returned ${_myPosts.length} posts');
  }

  Future<void> _refreshPostsAfterWrite({String? fallbackUserId}) async {
    try {
      await _loadPosts();
      await _loadMyPosts(fallbackUserId: fallbackUserId);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  PostModel? _findCachedPost(String postId) {
    for (final post in [..._posts, ..._myPosts]) {
      if (post.id == postId) return post;
    }

    return null;
  }

  Future<void> _tryDeleteImage(String imageUrl) async {
    try {
      await _imageUploadService.deleteImageByUrl(imageUrl);
    } catch (_) {}
  }

  String? _currentFirebaseUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
