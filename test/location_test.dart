import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/location_service.dart';
import 'package:weather_preview/main.dart';
import 'package:weather_preview/weather_service.dart';

import 'weather_test.dart' show FakeLocationService, FakeWeatherService, fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('weather_preview/location');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Converte coordenadas recebidas do Android', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'current');
      return {'latitude': -22.9, 'longitude': -43.2, 'label': 'Rio de Janeiro, RJ'};
    });
    final location = await LocationService().current();
    expect(location.latitude, -22.9);
    expect(location.longitude, -43.2);
    expect(location.label, 'Rio de Janeiro, RJ');
  });

  test('Permissão negada informa como liberar o acesso', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'permission_denied');
    });
    await expectLater(LocationService().current(), throwsA(isA<LocationException>()
        .having((e) => e.message, 'mensagem', contains('configurações'))));
  });

  test('Usa fuso e deslocamento UTC retornados pela previsão', () {
    final data = fixture()..addAll({'utc_offset_seconds': 32400, 'timezone': 'Asia/Tokyo'});
    final weather = WeatherData.fromJson(data);
    expect(weather.utcOffsetSeconds, 32400);
    expect(weather.timezone, 'Asia/Tokyo');
  });

  testWidgets('Consulta posição e mantém cidade anterior em falha de previsão', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = FakeWeatherService();
    final locator = FakeLocationService()
      ..location = const WeatherLocation(latitude: -22.9, longitude: -43.2,
          label: 'Rio de Janeiro, RJ');
    await tester.pumpWidget(MyApp(service: service, locationService: locator));
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.requestedLocation?.latitude, -22.9);
    expect(service.requestedLocation?.longitude, -43.2);
    expect(find.text('Rio de Janeiro, RJ'), findsOneWidget);
    locator.location = const WeatherLocation(latitude: -3.1, longitude: -60,
        label: 'Manaus, AM');
    service.fail = true;
    await tester.tap(find.text('Usar minha localização'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Rio de Janeiro, RJ'), findsOneWidget);
    expect(find.text('Manaus, AM'), findsNothing);
    expect(find.text('21°C'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Permissão negada usa Santo André e permite nova tentativa', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = FakeWeatherService();
    final locator = FakeLocationService()..fail = true;
    await tester.pumpWidget(MyApp(service: service, locationService: locator));
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.requestedLocation, WeatherLocation.santoAndre);
    expect(find.textContaining('Localização não autorizada'), findsOneWidget);
    locator.fail = false;
    locator.location = const WeatherLocation(latitude: -3.1, longitude: -60,
        label: 'Manaus, AM');
    await tester.tap(find.text('Usar minha localização'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Manaus, AM'), findsOneWidget);
    expect(find.textContaining('Localização não autorizada'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
