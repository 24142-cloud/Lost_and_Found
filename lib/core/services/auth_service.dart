import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('User creation failed.');
    }

    await user.updateDisplayName(name);

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email.trim(),
      phone: phone,
      profileImage: '',
    );

    await _firestore
        .collection(FirestoreKeys.users)
        .doc(user.uid)
        .set(userModel.toMap());

    return userCredential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
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
}