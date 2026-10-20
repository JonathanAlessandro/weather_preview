import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../models/weather_location.dart';
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
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 20),
      CyclingScene(temperature: weather.temperature, weatherCode: weather.code,
          locationName: location.label, utcOffsetSeconds: weather.utcOffsetSeconds),
      const SizedBox(height: 20),
      DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: const [BoxShadow(color: Color(0x084F46E5),
              blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Temperatura atual', style: TextStyle(color: colors.onSurface,
                fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                child: Text('${_number(weather.temperature)}°C',
                    style: TextStyle(fontSize: 64, height: 1.1,
                        fontWeight: FontWeight.w800, color: colors.tertiary)))),
              const SizedBox(width: 12),
              SizedBox(width: 100, child: Column(children: [
                Icon(_icon(weather.code), size: 48, color: colors.primary),
                const SizedBox(height: 6),
                Text(weather.condition, textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600)),
              ])),
            ]),
            const SizedBox(height: 12),
            Text('Sensação térmica: ${_number(weather.feelsLike)}°C',
                style: TextStyle(fontSize: 16, color: colors.onSurface)),
            const SizedBox(height: 6),
            Text('Hoje: mínima ${_number(weather.minimum)}°C · '
                'máxima ${_number(weather.maximum)}°C',
                style: const TextStyle(color: Color(0xFF52627A), height: 1.4)),
          ]),
        ),
      ),
      const SizedBox(height: 24),
      const TituloSecao(titulo: 'Detalhes'),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
        final columns = largeText || constraints.maxWidth < 240 ? 1
            : constraints.maxWidth >= 480 ? 3 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          _detail('Umidade', Icons.water_drop_rounded, colors.primary,
              Color.lerp(colors.surface, colors.primary, 0.10)!, '${_number(weather.humidity)}%', width),
          _detail('Vento', Icons.air_rounded, colors.secondary,
              Color.lerp(colors.surface, colors.secondary, 0.10)!, '${_number(weather.wind)} km/h', width),
          _detail('Chance de chuva hoje', Icons.umbrella_rounded, colors.tertiary,
              Color.lerp(colors.surface, colors.tertiary, 0.10)!, '${_number(weather.rainChance)}%', width),
        ]);
      }),
      const SizedBox(height: 18),
      Text('Dados de ${_updated(weather)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF52627A), height: 1.4)),
    ]);
  }

  Widget _detail(String label, IconData icon, Color color, Color fill,
      String value, double width) {
    return SizedBox(width: width, child: DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF172B4D), height: 1.3)),
        ]),
      ),
    ));
  }
}
