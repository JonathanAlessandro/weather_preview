import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../models/weather_location.dart';
import 'item_detalhe.dart';
import 'scene/cycling_scene.dart';
import 'titulo_secao.dart';

class WeatherReport extends StatelessWidget {
  const WeatherReport({super.key, required this.weather, required this.location});

  final WeatherData weather;
  final WeatherLocation location;

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
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 16),
      CyclingScene(temperature: weather.temperature, weatherCode: weather.code,
        locationName: location.label, utcOffsetSeconds: weather.utcOffsetSeconds),
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
    ]);
  }

  Widget _detail(String label, IconData icon, Color color, String value) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ItemDetalhe(icone: icon, cor: color, valor: value),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}
