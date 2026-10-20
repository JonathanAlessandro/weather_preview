import 'package:flutter/foundation.dart';

import '../models/weather_data.dart';
import '../models/weather_location.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

/// Estado e coordenação da previsão, compartilhados pela tela do monólito.
class WeatherController extends ChangeNotifier {
  WeatherController({required WeatherService weatherService,
    required LocationService locationService})
      : _weatherService = weatherService, _locationService = locationService;

  final WeatherService _weatherService;
  final LocationService _locationService;
  WeatherData? _weather;
  WeatherLocation _place = WeatherLocation.santoAndre;
  bool _loading = false;
  bool _usingLocation = true;
  bool _disposed = false;
  String? _error;
  String? _locationMessage;

  WeatherData? get weather => _weather;
  WeatherLocation get place => _place;
  bool get loading => _loading;
  bool get usingLocation => _usingLocation;
  String? get error => _error;
  String? get locationMessage => _locationMessage;

  Future<void> refresh() => _update();
  Future<void> useCurrentLocation() => _update(locate: true);
  Future<void> selectLocation(WeatherLocation location) => _update(selectedPlace: location);

  Future<void> _update({bool locate = false, WeatherLocation? selectedPlace}) async {
    if (_loading || _disposed) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      var place = selectedPlace ?? _place;
      var usingLocation = selectedPlace == null && _usingLocation;
      String? locationMessage;
      if (selectedPlace == null && (locate || _usingLocation)) {
        try {
          place = await _locationService.current();
          usingLocation = true;
        } on LocationException catch (error) {
          usingLocation = false;
          locationMessage = '${error.message} Exibindo a previsão de ${_place.label}.';
        }
      }
      if (_disposed) return;
      final weather = await _weatherService.fetch(location: place);
      if (_disposed) return;
      // Publica cidade e dados juntos para nunca misturar locais diferentes.
      _weather = weather;
      _place = place;
      _usingLocation = usingLocation;
      if (locationMessage != null || usingLocation || selectedPlace != null) {
        _locationMessage = locationMessage;
      }
    } catch (_) {
      if (!_disposed) {
        _error = 'Não foi possível atualizar o clima. '
            'Verifique sua conexão e tente novamente.';
      }
    } finally {
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
