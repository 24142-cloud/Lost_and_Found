import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/core/constants/firestore_keys.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.uid: uid,
      FirestoreKeys.name: name,
      FirestoreKeys.email: email,
      FirestoreKeys.phone: phone,
      FirestoreKeys.profileImage: profileImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[FirestoreKeys.uid] ?? '',
      name: map[FirestoreKeys.name] ?? '',
      email: map[FirestoreKeys.email] ?? '',
      phone: map[FirestoreKeys.phone] ?? '',
      profileImage: map[FirestoreKeys.profileImage] ?? '',
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }
}