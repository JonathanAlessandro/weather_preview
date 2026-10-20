import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'location_service.dart';

class LocationSearchService {
  Future<List<WeatherLocation>> search(String query) async {
    final name = query.trim();
    if (name.length < 2) return [];
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      return await (() async {
        final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
          'name': name, 'count': '10', 'language': 'pt', 'format': 'json',
        });
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw const HttpException('Busca de cidades indisponível.');
        }
        final body = await response.transform(utf8.decoder).join();
        return parseResults(jsonDecode(body) as Map<String, dynamic>);
      })().timeout(const Duration(seconds: 15));
    } finally {
      client.close(force: true);
    }
  }

  static List<WeatherLocation> parseResults(Map<String, dynamic> json) {
    final results = json['results'] as List? ?? [];
    return results.map((item) {
      final data = item as Map<String, dynamic>;
      final name = data['name'] as String;
      final parts = [name, data['admin1'] as String?, data['country'] as String?]
          .whereType<String>().where((part) => part.isNotEmpty).toSet();
      return WeatherLocation(
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        label: parts.join(', '),
      );
    }).toList();
  }
}
