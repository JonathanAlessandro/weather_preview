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
