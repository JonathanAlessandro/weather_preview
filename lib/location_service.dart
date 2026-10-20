import 'package:flutter/services.dart';

class WeatherLocation {
  const WeatherLocation({required this.latitude, required this.longitude,
    required this.label});

  static const santoAndre = WeatherLocation(latitude: -23.6639,
    longitude: -46.5383, label: 'Santo André, SP');

  final double latitude;
  final double longitude;
  final String label;
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
}

/// Consulta pontual, apenas enquanto o aplicativo está em uso no Android.
class LocationService {
  static const _channel = MethodChannel('weather_preview/location');

  Future<WeatherLocation> current() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('current');
      if (result == null) throw const FormatException('Localização vazia');
      final latitude = (result['latitude'] as num).toDouble();
      final longitude = (result['longitude'] as num).toDouble();
      if (!latitude.isFinite || !longitude.isFinite ||
          latitude.abs() > 90 || longitude.abs() > 180) {
        throw const FormatException('Coordenadas inválidas');
      }
      return WeatherLocation(latitude: latitude, longitude: longitude,
        label: result['label'] as String? ?? 'Localização atual');
    } on PlatformException catch (error) {
      throw LocationException(switch (error.code) {
        'permission_denied' => 'Localização não autorizada. Você pode permitir o acesso nas configurações do aplicativo.',
        'disabled' => 'Ative a localização do aparelho e tente novamente.',
        _ => 'Não foi possível obter sua localização. Tente novamente.',
      });
    } on MissingPluginException {
      throw const LocationException('Localização disponível somente no aplicativo Android.');
    } on FormatException {
      throw const LocationException('O aparelho retornou uma localização inválida.');
    }
  }
}
