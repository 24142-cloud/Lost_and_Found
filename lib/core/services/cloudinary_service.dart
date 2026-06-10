import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

abstract class ImageUploadRepository {
  Future<String> uploadImage(XFile image);
  Future<void> deleteImageByUrl(String imageUrl);
}

class CloudinaryService implements ImageUploadRepository {
  CloudinaryService({http.Client? client}) : _client = client ?? http.Client();

  static const _cloudName = 'dgt8xqyqe';
  static const _apiKey = '893213539947135';
  static const _apiSecret = 'MfZcDbNMP2ANXKEnvMM8C_IE5pk';
  static const _folder = 'dalah/post_images';

  final http.Client _client;

  Uri get _uploadUri =>
      Uri.https('api.cloudinary.com', '/v1_1/$_cloudName/image/upload');

  Uri get _destroyUri =>
      Uri.https('api.cloudinary.com', '/v1_1/$_cloudName/image/destroy');

  @override
  Future<String> uploadImage(XFile image) async {
    debugPrint('Cloudinary upload start');
    debugPrint('Selected image: ${image.path}');

    try {
      final bytes = await image.readAsBytes();
      debugPrint('File size: ${bytes.length} bytes');

      final timestamp = _timestamp();
      final signature = _signature({'folder': _folder, 'timestamp': timestamp});

      final request = http.MultipartRequest('POST', _uploadUri)
        ..fields['api_key'] = _apiKey
        ..fields['timestamp'] = timestamp
        ..fields['folder'] = _folder
        ..fields['signature'] = signature
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: image.name.isNotEmpty ? image.name : 'post_image.jpg',
          ),
        );

      final response = await _client.send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Cloudinary upload failure: ${response.statusCode}');
        debugPrint('Cloudinary upload response: $responseBody');
        throw Exception(_cloudinaryErrorMessage(responseBody));
      }

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final secureUrl = data['secure_url'] as String?;

      if (secureUrl == null || secureUrl.isEmpty) {
        debugPrint('Cloudinary upload failure: missing secure_url');
        debugPrint('Cloudinary upload response: $responseBody');
        throw Exception('Cloudinary did not return a secure image URL.');
      }

      debugPrint('Cloudinary upload success');
      debugPrint('Generated URL: $secureUrl');
      return secureUrl;
    } catch (e, stackTrace) {
      debugPrint('Cloudinary upload failure: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('Image upload failed: $e');
    }
  }

  @override
  Future<void> deleteImageByUrl(String imageUrl) async {
    final publicId = _publicIdFromUrl(imageUrl);
    if (publicId == null) return;

    try {
      final timestamp = _timestamp();
      final signature = _signature({
        'public_id': publicId,
        'timestamp': timestamp,
      });

      final response = await _client.post(
        _destroyUri,
        body: {
          'api_key': _apiKey,
          'timestamp': timestamp,
          'public_id': publicId,
          'signature': signature,
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Cloudinary delete failure: ${response.statusCode}');
        debugPrint('Cloudinary delete response: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Cloudinary delete failure: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _timestamp() =>
      (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

  String _signature(Map<String, String> params) {
    final payload = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final serialized = payload
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    return sha1.convert(utf8.encode('$serialized$_apiSecret')).toString();
  }

  String _cloudinaryErrorMessage(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      final message = error?['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
    } catch (_) {}

    return 'Cloudinary upload failed.';
  }

  String? _publicIdFromUrl(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return null;

    final uploadIndex = uri.pathSegments.indexOf('upload');
    if (uploadIndex == -1 || uploadIndex + 1 >= uri.pathSegments.length) {
      return null;
    }

    final publicIdSegments = uri.pathSegments.skip(uploadIndex + 1).toList();
    if (publicIdSegments.isNotEmpty &&
        RegExp(r'^v\d+$').hasMatch(publicIdSegments.first)) {
      publicIdSegments.removeAt(0);
    }

    if (publicIdSegments.isEmpty) return null;
    final publicIdWithExtension = publicIdSegments.join('/');
    final extensionIndex = publicIdWithExtension.lastIndexOf('.');
    if (extensionIndex <= 0) return publicIdWithExtension;
    return publicIdWithExtension.substring(0, extensionIndex);
  }
}
