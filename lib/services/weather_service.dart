import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/weather_data.dart';
import '../models/weather_location.dart';

class WeatherService {
  Future<WeatherData> fetch({WeatherLocation location = WeatherLocation.santoAndre}) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      return await (() async {
        final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
          'latitude': location.latitude.toString(),
          'longitude': location.longitude.toString(),
          'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,'
              'wind_speed_10m,weather_code',
          'daily': 'temperature_2m_min,temperature_2m_max,'
              'precipitation_probability_max',
          'timezone': 'auto',
          'forecast_days': '1',
          'temperature_unit': 'celsius',
          'wind_speed_unit': 'kmh',
        });
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw const HttpException('Serviço de clima indisponível.');
        }
        final body = await response.transform(utf8.decoder).join();
        return WeatherData.fromJson(jsonDecode(body) as Map<String, dynamic>);
      })().timeout(const Duration(seconds: 20));
    } finally {
      client.close(force: true);
    }
  }
}
