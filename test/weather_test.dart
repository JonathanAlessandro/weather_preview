import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/main.dart';
import 'package:weather_preview/models/weather_data.dart';

import 'support/weather_fakes.dart';

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
    await tester.pumpWidget(MyApp(service: service, locationService: FakeLocationService()));
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
    await tester.pumpWidget(MyApp(service: service, locationService: FakeLocationService()));
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
