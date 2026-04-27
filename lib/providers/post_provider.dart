import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found/core/services/post_service.dart';
import 'package:lost_and_found/core/services/storage_service.dart';
import 'package:lost_and_found/models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();
  final StorageService _storageService = StorageService();

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
      _posts = await _postService.getPosts();
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _myPosts = [];
        notifyListeners();
        return;
      }

      _myPosts = await _postService.getMyPosts(user.uid);
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
    required String type,
    required String location,
    required String contact,
    required String userId,
    required String userName,
    required String date,
    File? imageFile,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      String imageUrl = '';

      if (imageFile != null) {
        imageUrl = await _storageService.uploadImage(imageFile);
      }

      final post = PostModel(
        id: '',
        title: title,
        description: description,
        type: type,
        imageUrl: imageUrl,
        location: location,
        contact: contact,
        userId: userId,
        userName: userName,
        status: 'open',
        createdAt: DateTime.now(),
        date: date,
      );

      await _postService.addPost(post);
      await fetchPosts();
      await fetchMyPosts();
      return true;
    } catch (e) {
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
      await _postService.deletePost(postId);
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}