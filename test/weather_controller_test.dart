import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/controllers/weather_controller.dart';
import 'package:weather_preview/models/weather_data.dart';
import 'package:weather_preview/models/weather_location.dart';
import 'package:weather_preview/services/weather_service.dart';

import 'support/weather_fakes.dart';

class PendingWeatherService extends WeatherService {
  final response = Completer<WeatherData>();
  int calls = 0;

  @override
  Future<WeatherData> fetch({WeatherLocation location = WeatherLocation.santoAndre}) {
    calls++;
    return response.future;
  }
}

void main() {
  const selected = WeatherLocation(latitude: -22.9, longitude: -47.06,
      label: 'Campinas, São Paulo, Brasil');

  test('Selecionar cidade desativa GPS e atualizar mantém o local escolhido', () async {
    final weather = FakeWeatherService();
    final locator = FakeLocationService();
    final controller = WeatherController(weatherService: weather, locationService: locator);
    addTearDown(controller.dispose);
    await controller.refresh();
    expect(locator.calls, 1);
    await controller.selectLocation(selected);
    await controller.refresh();
    expect(controller.place, selected);
    expect(weather.requestedLocation, selected);
    expect(controller.usingLocation, isFalse);
    expect(locator.calls, 1);
    await controller.useCurrentLocation();
    expect(controller.place, WeatherLocation.santoAndre);
    expect(controller.usingLocation, isTrue);
    expect(locator.calls, 2);
  });

  test('Falha não mistura cidade escolhida com dados da consulta anterior', () async {
    final weather = FakeWeatherService();
    final controller = WeatherController(weatherService: weather,
        locationService: FakeLocationService());
    addTearDown(controller.dispose);
    await controller.refresh();
    final previous = controller.weather;
    weather.fail = true;
    await controller.selectLocation(selected);
    expect(controller.place, WeatherLocation.santoAndre);
    expect(controller.weather, same(previous));
    expect(controller.error, isNotNull);
    expect(controller.loading, isFalse);
    weather.fail = false;
    await controller.selectLocation(selected);
    expect(controller.place, selected);
    expect(controller.error, isNull);
  });

  test('Permissão negada usa alternativa e nova tentativa limpa o aviso', () async {
    final locator = FakeLocationService()..fail = true;
    final controller = WeatherController(weatherService: FakeWeatherService(),
        locationService: locator);
    addTearDown(controller.dispose);
    await controller.refresh();
    expect(controller.place, WeatherLocation.santoAndre);
    expect(controller.locationMessage, contains('não autorizada'));
    expect(controller.usingLocation, isFalse);
    locator.fail = false;
    locator.location = selected;
    await controller.useCurrentLocation();
    expect(controller.place, selected);
    expect(controller.locationMessage, isNull);
  });

  test('Ignora consulta duplicada e resposta recebida após descarte', () async {
    final weather = PendingWeatherService();
    final controller = WeatherController(weatherService: weather,
        locationService: FakeLocationService());
    var notifications = 0;
    controller.addListener(() => notifications++);
    final pending = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    expect(weather.calls, 1);
    await controller.refresh();
    expect(weather.calls, 1);
    expect(controller.loading, isTrue);
    final beforeDispose = notifications;
    controller.dispose();
    weather.response.complete(WeatherData.fromJson(fixture()));
    await pending;
    expect(controller.weather, isNull);
    expect(notifications, beforeDispose);
  });
}
