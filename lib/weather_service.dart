import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'location_service.dart';

class WeatherData {
  const WeatherData({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.code,
    required this.minimum,
    required this.maximum,
    required this.rainChance,
    this.utcOffsetSeconds = -10800,
    this.timezone = 'America/Sao_Paulo',
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    double value(String key) => (current[key] as num).toDouble();
    double day(String key) => ((daily[key] as List).first as num).toDouble();
    return WeatherData(
      time: DateTime.parse(current['time'] as String),
      temperature: value('temperature_2m'),
      feelsLike: value('apparent_temperature'),
      humidity: value('relative_humidity_2m'),
      wind: value('wind_speed_10m'),
      code: (current['weather_code'] as num).toInt(),
      minimum: day('temperature_2m_min'),
      maximum: day('temperature_2m_max'),
      rainChance: day('precipitation_probability_max'),
      utcOffsetSeconds: (json['utc_offset_seconds'] as num?)?.toInt() ?? -10800,
      timezone: json['timezone'] as String? ?? 'America/Sao_Paulo',
    );
  }

  final DateTime time;
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double wind;
  final int code;
  final double minimum;
  final double maximum;
  final double rainChance;
  final int utcOffsetSeconds;
  final String timezone;

  String get condition => switch (code) {
    0 => 'Céu limpo',
    1 => 'Predominantemente limpo',
    2 => 'Parcialmente nublado',
    3 => 'Nublado',
    45 || 48 => 'Nevoeiro',
    51 || 53 || 55 || 56 || 57 => 'Garoa',
    61 || 63 || 65 || 66 || 67 => 'Chuva',
    71 || 73 || 75 || 77 || 85 || 86 => 'Neve',
    80 || 81 || 82 => 'Pancadas de chuva',
    95 || 96 || 99 => 'Trovoadas',
    _ => 'Condição indisponível',
  };
}

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
