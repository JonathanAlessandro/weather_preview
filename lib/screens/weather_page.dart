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
        final weather = controller.weather;
        final loading = controller.loading;
        final error = controller.error;
        return Scaffold(
          appBar: AppBar(
            title: const Text('WeatherApp'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
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
                ElevatedButton(onPressed: loading ? null : controller.refresh,
                    child: Text(loading ? 'Atualizando…' : 'Atualizar')),
                const SizedBox(height: 12),
                const Text('Fonte: Open-Meteo · Dados meteorológicos por modelos '
                    'de previsão · open-meteo.com (CC BY 4.0)',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
