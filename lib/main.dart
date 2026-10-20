import 'package:flutter/material.dart';

import 'weather_service.dart';
import 'widgets/cycling_scene.dart';
import 'widgets/item_detalhe.dart';
import 'widgets/titulo_secao.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.service});

  final WeatherService? service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: WeatherPage(service: service ?? WeatherService()),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key, required this.service});

  final WeatherService service;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherData? _weather;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = await widget.service.fetch();
      if (mounted) setState(() => _weather = weather);
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

  String _number(double value) => value.toStringAsFixed(0);

  String _updated(DateTime time) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(time.day)}/${pad(time.month)}/${time.year} '
        'às ${pad(time.hour)}:${pad(time.minute)} (horário de Brasília)';
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
            const Text('Santo André, SP',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
              CyclingScene(temperature: weather.temperature, weatherCode: weather.code),
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
              Text('Dados de ${_updated(weather.time)}'),
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
