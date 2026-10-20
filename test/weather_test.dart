import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/main.dart';
import 'package:weather_preview/weather_service.dart';

Map<String, dynamic> fixture() => {
  'current': {
    'time': '2026-10-20T10:15',
    'temperature_2m': 21.0,
    'apparent_temperature': 20.0,
    'relative_humidity_2m': 75,
    'wind_speed_10m': 9.0,
    'weather_code': 3,
  },
  'daily': {
    'temperature_2m_min': [17.0],
    'temperature_2m_max': [25.0],
    'precipitation_probability_max': [60],
  },
};

class FakeWeatherService extends WeatherService {
  bool fail = false;
  int calls = 0;

  @override
  Future<WeatherData> fetch() async {
    calls++;
    if (fail) throw Exception('offline');
    return WeatherData.fromJson(fixture());
  }
}

void main() {
  test('Converte campos atuais, previsão diária e condição WMO', () {
    final weather = WeatherData.fromJson(fixture());
    expect(weather.temperature, 21);
    expect(weather.feelsLike, 20);
    expect(weather.humidity, 75);
    expect(weather.wind, 9);
    expect(weather.minimum, 17);
    expect(weather.maximum, 25);
    expect(weather.rainChance, 60);
    expect(weather.condition, 'Nublado');
    expect(weather.time.hour, 10);
  });

  testWidgets('Carrega clima e mantém consulta anterior se atualização falhar', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = FakeWeatherService();
    await tester.pumpWidget(MyApp(service: service));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('21°C'), findsOneWidget);
    expect(find.text('Nublado'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    service.fail = true;
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Atualizar'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Atualizar'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.calls, 2);
    expect(find.textContaining('Não foi possível'), findsOneWidget);
    expect(find.text('21°C'), findsOneWidget);
  });

  testWidgets('Erro inicial permite tentar novamente', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = FakeWeatherService()..fail = true;
    await tester.pumpWidget(MyApp(service: service));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Não foi possível'), findsOneWidget);
    expect(find.text('21°C'), findsNothing);
    service.fail = false;
    await tester.tap(find.widgetWithText(ElevatedButton, 'Atualizar'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('21°C'), findsOneWidget);
    expect(find.textContaining('Não foi possível'), findsNothing);
  });
}
