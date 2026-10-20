import 'package:flutter/material.dart';

import 'weather_service.dart';
import 'location_service.dart';
import 'location_search_service.dart';
import 'widgets/location_search_dialog.dart';
import 'widgets/cycling_scene.dart';
import 'widgets/item_detalhe.dart';
import 'widgets/titulo_secao.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.service, this.locationService, this.searchService});

  final WeatherService? service;
  final LocationService? locationService;
  final LocationSearchService? searchService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: WeatherPage(service: service ?? WeatherService(),
        locationService: locationService ?? LocationService(),
        searchService: searchService ?? LocationSearchService()),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key, required this.service, required this.locationService, required this.searchService});

  final WeatherService service;
  final LocationService locationService;
  final LocationSearchService searchService;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherData? _weather;
  bool _loading = false;
  String? _error;
  String? _locationMessage;
  WeatherLocation _place = WeatherLocation.santoAndre;
  bool _usingLocation = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh({bool locate = false, WeatherLocation? selectedPlace}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var place = selectedPlace ?? _place;
      var usingLocation = selectedPlace == null && _usingLocation;
      String? locationMessage;
      if (selectedPlace == null && (locate || _usingLocation)) {
        try {
          place = await widget.locationService.current();
          usingLocation = true;
        } on LocationException catch (error) {
          usingLocation = false;
          locationMessage = '${error.message} Exibindo a previsão de ${_place.label}.';
        }
      }
      final weather = await widget.service.fetch(location: place);
      if (mounted) {
        setState(() {
          _weather = weather;
          _place = place;
          _usingLocation = usingLocation;
          if (locationMessage != null || usingLocation || selectedPlace != null) {
            _locationMessage = locationMessage;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível atualizar o clima. '
              'Verifique sua conexão e tente novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _searchLocation() async {
    final location = await showDialog<WeatherLocation>(
      context: context,
      builder: (_) => LocationSearchDialog(service: widget.searchService),
    );
    if (mounted && location != null) await _refresh(selectedPlace: location);
  }

  String _number(double value) => value.toStringAsFixed(0);

  String _updated(WeatherData weather) {
    final time = weather.time;
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(time.day)}/${pad(time.month)}/${time.year} '
        'às ${pad(time.hour)}:${pad(time.minute)} (${weather.timezone})';
  }

  IconData _icon(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny;
    if (code == 2 || code == 3) return Icons.cloud;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 95) return Icons.thunderstorm;
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return Icons.ac_unit;
    }
    return Icons.water_drop;
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weather;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherApp'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const TituloSecao(titulo: 'Cidade'),
            Text(_place.label,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: _loading ? null : _searchLocation,
              icon: const Icon(Icons.search),
              label: const Text('Pesquisar cidade'),
            ),
            TextButton.icon(
              onPressed: _loading ? null : () => _refresh(locate: true),
              icon: const Icon(Icons.my_location),
              label: const Text('Usar minha localização'),
            ),
            if (_locationMessage != null) Text(_locationMessage!),
            if (_loading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const Text('Consultando previsão…'),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              if (weather != null)
                const Text('Exibindo a última consulta; os dados podem estar desatualizados.'),
            ],
            if (weather != null) ...[
              const SizedBox(height: 16),
              CyclingScene(temperature: weather.temperature, weatherCode: weather.code,
                locationName: _place.label, utcOffsetSeconds: weather.utcOffsetSeconds),
              const Divider(),
              const TituloSecao(titulo: 'Temperatura atual'),
              Text('${_number(weather.temperature)}°C',
                  style: const TextStyle(fontSize: 48,
                      fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              Text('Sensação térmica: ${_number(weather.feelsLike)}°C',
                  style: const TextStyle(fontSize: 16)),
              Text('Hoje: mínima ${_number(weather.minimum)}°C · '
                  'máxima ${_number(weather.maximum)}°C'),
              const Divider(),
              const TituloSecao(titulo: 'Condição do tempo'),
              Icon(_icon(weather.code), size: 80, color: Colors.blue),
              Center(child: Text(weather.condition,
                  style: const TextStyle(fontSize: 20))),
              const Divider(),
              const TituloSecao(titulo: 'Detalhes'),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 24,
                runSpacing: 16,
                children: [
                  _detail('Umidade', Icons.water_drop, Colors.blue,
                      '${_number(weather.humidity)}%'),
                  _detail('Vento', Icons.air, Colors.teal,
                      '${_number(weather.wind)} km/h'),
                  _detail('Chance de chuva hoje', Icons.umbrella, Colors.indigo,
                      '${_number(weather.rainChance)}%'),
                ],
              ),
              const Divider(),
              Text('Dados de ${_updated(weather)}'),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _refresh,
              child: Text(_loading ? 'Atualizando…' : 'Atualizar'),
            ),
            const SizedBox(height: 12),
            const Text('Fonte: Open-Meteo · Dados meteorológicos por modelos '
                'de previsão · open-meteo.com (CC BY 4.0)',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, IconData icon, Color color, String value) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ItemDetalhe(icone: icon, cor: color, valor: value),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}
