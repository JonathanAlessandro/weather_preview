class WeatherLocation {
  const WeatherLocation({required this.latitude, required this.longitude,
    required this.label});

  static const santoAndre = WeatherLocation(latitude: -23.6639,
    longitude: -46.5383, label: 'Santo André, SP');

  final double latitude;
  final double longitude;
  final String label;
}
