import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingResult {
  const GeocodingResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}

class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<GeocodingResult>> search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': '$trimmedQuery, Mauritania',
      'format': 'jsonv2',
      'limit': '5',
    });

    final response = await _client
        .get(uri, headers: const {'User-Agent': 'DalahLostAndFound/1.0'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Location search failed.');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.map((item) {
      final map = item as Map<String, dynamic>;
      return GeocodingResult(
        displayName: map['display_name'] as String? ?? '',
        latitude: double.tryParse(map['lat'] as String? ?? '') ?? 0,
        longitude: double.tryParse(map['lon'] as String? ?? '') ?? 0,
      );
    }).toList();
  }
}
