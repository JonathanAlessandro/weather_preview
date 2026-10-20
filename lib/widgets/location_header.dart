import 'package:flutter/material.dart';

import '../models/weather_location.dart';
import 'titulo_secao.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key, required this.location, required this.loading,
    required this.onSearch, required this.onUseCurrentLocation, this.message});

  final WeatherLocation location;
  final bool loading;
  final VoidCallback onSearch;
  final VoidCallback onUseCurrentLocation;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const TituloSecao(titulo: 'Cidade'),
      Text(location.label,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      TextButton.icon(onPressed: loading ? null : onSearch,
          icon: const Icon(Icons.search), label: const Text('Pesquisar cidade')),
      TextButton.icon(onPressed: loading ? null : onUseCurrentLocation,
          icon: const Icon(Icons.my_location), label: const Text('Usar minha localização')),
      if (message != null) Text(message!),
    ]);
  }
}
