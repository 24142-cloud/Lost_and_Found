import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_and_found/core/constants/firestore_keys.dart';
import 'package:lost_and_found/core/constants/post_categories.dart';

class PostModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type; // lost أو found
  final String imageUrl;
  final String location;
  final String wilaya;
  final String district;
  final String locationDescription;
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
    this.category = PostCategories.other,
    required this.type,
    required this.imageUrl,
    required this.location,
    this.wilaya = '',
    this.district = '',
    this.locationDescription = '',
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
      FirestoreKeys.postType: type,
      FirestoreKeys.category: PostCategories.filterValue(category),
      FirestoreKeys.imageUrl: imageUrl,
      FirestoreKeys.location: location,
      FirestoreKeys.wilaya: wilaya,
      FirestoreKeys.district: district,
      FirestoreKeys.locationDescription: locationDescription,
      FirestoreKeys.contact: contact,
      FirestoreKeys.phoneNumber: contact,
      FirestoreKeys.userId: userId,
      FirestoreKeys.userName: userName,
      FirestoreKeys.status: status,
      FirestoreKeys.createdAt: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      FirestoreKeys.date: date,
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? imageUrl,
    String? location,
    String? wilaya,
    String? district,
    String? locationDescription,
    String? contact,
    String? userId,
    String? userName,
    String? status,
    DateTime? createdAt,
    String? date,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      wilaya: wilaya ?? this.wilaya,
      district: district ?? this.district,
      locationDescription: locationDescription ?? this.locationDescription,
      contact: contact ?? this.contact,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
    );
  }

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    final wilaya = map[FirestoreKeys.wilaya] ?? '';
    final district = map[FirestoreKeys.district] ?? '';
    final locationDescription = map[FirestoreKeys.locationDescription] ?? '';
    final legacyLocation = map[FirestoreKeys.location] ?? '';

    return PostModel(
      id: id,
      title: map[FirestoreKeys.title] ?? '',
      description: map[FirestoreKeys.description] ?? '',
      category: PostCategories.filterValue(map[FirestoreKeys.category]),
      type: map[FirestoreKeys.postType] ?? map[FirestoreKeys.type] ?? '',
      imageUrl: map[FirestoreKeys.imageUrl] ?? '',
      location: legacyLocation.isNotEmpty
          ? legacyLocation
          : _buildLocation(wilaya, district, locationDescription),
      wilaya: wilaya,
      district: district,
      locationDescription: locationDescription,
      contact:
          map[FirestoreKeys.phoneNumber] ?? map[FirestoreKeys.contact] ?? '',
      userId: map[FirestoreKeys.userId] ?? '',
      userName: map[FirestoreKeys.userName] ?? '',
      status: map[FirestoreKeys.status] ?? 'open',
      createdAt: map[FirestoreKeys.createdAt] is Timestamp
          ? (map[FirestoreKeys.createdAt] as Timestamp).toDate()
          : null,
      date: map[FirestoreKeys.date] ?? '',
    );
  }

  static String _buildLocation(
    String wilaya,
    String district,
    String locationDescription,
  ) {
    return [
      wilaya,
      district,
      locationDescription,
    ].where((part) => part.trim().isNotEmpty).join(' - ');
  }

  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromMap(doc.id, data);
  }
}
