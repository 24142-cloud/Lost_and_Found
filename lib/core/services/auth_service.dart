import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lost_and_found/core/constants/firestore_keys.dart';
import 'package:lost_and_found/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final trimmedName = name.trim();

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('User creation failed.');
    }

    try {
      await user.updateDisplayName(trimmedName);

      final userModel = UserModel(
        uid: user.uid,
        name: trimmedName,
        email: email,
        phone: phone.trim(),
        profileImage: '',
      );

      await _firestore
          .collection(FirestoreKeys.users)
          .doc(user.uid)
          .set(userModel.toMap());
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {}

      throw Exception('Failed to create user profile. Please try again.');
    }

    return userCredential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[AuthService] Login email: $email');
    debugPrint(
      '[AuthService] Current auth user before login: '
      '${_formatUser(_auth.currentUser)}',
    );

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
        '[AuthService] Current auth user after login: '
        '${_formatUser(_auth.currentUser)}',
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] Login failed code: ${e.code}');
      debugPrint('[AuthService] Login failed message: ${e.message}');
      debugPrint(
        '[AuthService] Current auth user after login failure: '
        '${_formatUser(_auth.currentUser)}',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(FirestoreKeys.users)
        .doc(user.uid)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(doc.data()!);
  }

  String _formatUser(User? user) {
    if (user == null) return 'null';
    return 'uid=${user.uid}, email=${user.email}';
  }
}
