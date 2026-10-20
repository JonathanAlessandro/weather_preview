import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../models/weather_location.dart';
import '../services/location_search_service.dart';
import '../widgets/location_header.dart';
import '../widgets/location_search_dialog.dart';
import '../widgets/weather_report.dart';

/// A tela apresenta o estado; consultas e seleção de local ficam no controlador.
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key, required this.controller, required this.searchService});

  final WeatherController controller;
  final LocationSearchService searchService;

  Future<void> _searchLocation(BuildContext context) async {
    final location = await showDialog<WeatherLocation>(
      context: context,
      builder: (_) => LocationSearchDialog(service: searchService),
    );
    if (context.mounted && location != null) await controller.selectLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final colors = Theme.of(context).colorScheme;
        final weather = controller.weather;
        final loading = controller.loading;
        final error = controller.error;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final horizontalPadding = screenWidth > 752 ? (screenWidth - 720) / 2 : 16.0;
        return Scaffold(
          appBar: AppBar(
            title: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.wb_sunny_rounded, color: colors.tertiary),
              SizedBox(width: 10),
              Text('WeatherApp'),
            ]),
            actions: [
              IconButton(tooltip: 'Atualizar previsão',
                  onPressed: loading ? null : controller.refresh,
                  icon: Icon(Icons.refresh_rounded, color: colors.primary)),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding,
                  20 + MediaQuery.paddingOf(context).bottom),
              children: [
                LocationHeader(location: controller.place, loading: loading,
                    message: controller.locationMessage,
                    onSearch: () => _searchLocation(context),
                    onUseCurrentLocation: controller.useCurrentLocation),
                if (loading) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  const Text('Consultando previsão…'),
                ],
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  if (weather != null)
                    const Text('Exibindo a última consulta; os dados podem estar desatualizados.'),
                ],
                if (weather != null)
                  WeatherReport(weather: weather, location: controller.place),
                const SizedBox(height: 16),
                ElevatedButton.icon(onPressed: loading ? null : controller.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(loading ? 'Atualizando…' : 'Atualizar')),
                const SizedBox(height: 12),
                const Text('Fonte: Open-Meteo · Dados meteorológicos por modelos '
                    'de previsão · open-meteo.com (CC BY 4.0)',
                    style: TextStyle(fontSize: 12, color: Color(0xFF52627A), height: 1.4)),
              ],
            ),
          ),
        );
      },
    );
  }
}
