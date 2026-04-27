import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/core/constants/firestore_keys.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String type; // lost أو found
  final String imageUrl;
  final String location;
  final String contact;
  final String userId;
  final String userName;
  final String status; // open / closed
  final DateTime? createdAt;
  final String date;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.imageUrl,
    required this.location,
    required this.contact,
    required this.userId,
    required this.userName,
    required this.status,
    required this.createdAt,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.title: title,
      FirestoreKeys.description: description,
      FirestoreKeys.type: type,
      FirestoreKeys.imageUrl: imageUrl,
      FirestoreKeys.location: location,
      FirestoreKeys.contact: contact,
      FirestoreKeys.userId: userId,
      FirestoreKeys.userName: userName,
      FirestoreKeys.status: status,
      FirestoreKeys.createdAt:
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      FirestoreKeys.date: date,
    };
  }

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      title: map[FirestoreKeys.title] ?? '',
      description: map[FirestoreKeys.description] ?? '',
      type: map[FirestoreKeys.type] ?? '',
      imageUrl: map[FirestoreKeys.imageUrl] ?? '',
      location: map[FirestoreKeys.location] ?? '',
      contact: map[FirestoreKeys.contact] ?? '',
      userId: map[FirestoreKeys.userId] ?? '',
      userName: map[FirestoreKeys.userName] ?? '',
      status: map[FirestoreKeys.status] ?? 'open',
      createdAt: map[FirestoreKeys.createdAt] is Timestamp
          ? (map[FirestoreKeys.createdAt] as Timestamp).toDate()
          : null,
      date: map[FirestoreKeys.date] ?? '',
    );
  }

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromMap(doc.id, data);
  }
}