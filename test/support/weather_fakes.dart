import 'package:weather_preview/models/weather_data.dart';
import 'package:weather_preview/models/weather_location.dart';
import 'package:weather_preview/services/location_service.dart';
import 'package:weather_preview/services/weather_service.dart';

Map<String, dynamic> fixture() => {
  'current': {
    'time': '2026-10-20T10:15',
    'temperature_2m': 21.0,
    'apparent_temperature': 20.0,
    'relative_humidity_2m': 75,
    'wind_speed_10m': 9.0,
    'weather_code': 3,
  },
  'daily': {
    'temperature_2m_min': [17.0],
    'temperature_2m_max': [25.0],
    'precipitation_probability_max': [60],
  },
};

class FakeWeatherService extends WeatherService {
  bool fail = false;
  int calls = 0;
  WeatherLocation? requestedLocation;

  @override
  Future<WeatherData> fetch({WeatherLocation location = WeatherLocation.santoAndre}) async {
    calls++;
    requestedLocation = location;
    if (fail) throw Exception('offline');
    return WeatherData.fromJson(fixture());
  }
}

class FakeLocationService extends LocationService {
  int calls = 0;
  WeatherLocation location = WeatherLocation.santoAndre;
  bool fail = false;

  @override
  Future<WeatherLocation> current() async {
    calls++;
    if (fail) throw const LocationException('Localização não autorizada.');
    return location;
  }
}

