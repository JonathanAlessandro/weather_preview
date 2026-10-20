import 'package:flutter/material.dart';

import '../models/weather_location.dart';

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
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Icon(Icons.location_on_rounded, size: 18, color: colors.primary),
        const SizedBox(width: 6),
        Text('Cidade', style: TextStyle(color: colors.primary,
            fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
      const SizedBox(height: 6),
      Text(location.label, style: TextStyle(fontSize: 28,
          height: 1.15, fontWeight: FontWeight.w800, color: colors.onSurface)),
      const SizedBox(height: 16),
      Wrap(spacing: 10, runSpacing: 10, children: [
        FilledButton.icon(onPressed: loading ? null : onSearch,
            icon: const Icon(Icons.search_rounded), label: const Text('Pesquisar cidade')),
        FilledButton.icon(onPressed: loading ? null : onUseCurrentLocation,
            style: FilledButton.styleFrom(backgroundColor: colors.secondary,
                foregroundColor: Colors.white),
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('Usar minha localização')),
      ]),
      if (message != null) ...[
        const SizedBox(height: 12),
        Text(message!, style: TextStyle(color: colors.onSurface, height: 1.4)),
      ],
    ]);
  }
}
