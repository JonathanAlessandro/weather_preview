import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/main.dart';
import 'package:weather_preview/models/weather_location.dart';
import 'package:weather_preview/services/location_search_service.dart';
import 'package:weather_preview/widgets/location_search_dialog.dart';

import 'support/weather_fakes.dart' show FakeLocationService, FakeWeatherService;

const campinas = WeatherLocation(latitude: -22.9, longitude: -47.06,
    label: 'Campinas, São Paulo, Brasil');

class FakeSearchService extends LocationSearchService {
  Future<List<WeatherLocation>> Function(String) respond = (_) async => [campinas];

  @override
  Future<List<WeatherLocation>> search(String query) => respond(query);
}

void main() {
  test('Distingue cidades com mesmo nome e aceita resposta sem resultados', () {
    final locations = LocationSearchService.parseResults({'results': [
      {'name': 'Santa Maria', 'admin1': 'Rio Grande do Sul', 'country': 'Brasil',
        'latitude': -29.68, 'longitude': -53.8},
      {'name': 'Santa Maria', 'country': 'Portugal', 'latitude': 37, 'longitude': -25},
    ]});
    expect(locations.first.label, 'Santa Maria, Rio Grande do Sul, Brasil');
    expect(locations.last.label, 'Santa Maria, Portugal');
    expect(locations.first.latitude, -29.68);
    expect(locations.last.longitude, -25);
    expect(LocationSearchService.parseResults({}), isEmpty);
  });

  testWidgets('Busca cidade, mantém seleção ao atualizar e permite voltar ao GPS', (tester) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final weather = FakeWeatherService();
    final locator = FakeLocationService();
    await tester.pumpWidget(MyApp(service: weather, locationService: locator,
        searchService: FakeSearchService()));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Pesquisar cidade'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'Campinas');
    await tester.pump();
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    await tester.tap(find.text(campinas.label));
    await tester.pump(const Duration(milliseconds: 300));
    expect(weather.requestedLocation?.longitude, campinas.longitude);
    expect(find.text(campinas.label), findsOneWidget);
    // Uma atualização manual não deve tentar obter a posição do aparelho.
    locator.fail = true;
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Atualizar'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Atualizar'));
    await tester.pump();
    expect(weather.requestedLocation?.latitude, campinas.latitude);
    expect(find.textContaining('Localização não autorizada'), findsNothing);
    locator.fail = false;
    await tester.ensureVisible(find.text('Usar minha localização'));
    await tester.tap(find.text('Usar minha localização'));
    await tester.pump();
    expect(find.text(WeatherLocation.santoAndre.label), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Valida texto curto, informa busca vazia e permite repetir após erro', (tester) async {
    final service = FakeSearchService()..respond = (_) async => [];
    await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: LocationSearchDialog(service: service))));
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    expect(find.text('Digite pelo menos 2 caracteres.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Cidade');
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    expect(find.textContaining('Nenhuma cidade encontrada'), findsOneWidget);
    service.respond = (_) async => throw Exception('offline');
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    expect(find.textContaining('Não foi possível pesquisar'), findsOneWidget);
    service.respond = (_) async => [campinas];
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    expect(find.text(campinas.label), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Descarta resposta antiga quando uma nova pesquisa termina antes', (tester) async {
    final old = Completer<List<WeatherLocation>>();
    final service = FakeSearchService()
      ..respond = (query) => query == 'Antiga' ? old.future : Future.value([campinas]);
    await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: LocationSearchDialog(service: service))));
    await tester.enterText(find.byType(TextField), 'Antiga');
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Campinas');
    await tester.pump();
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    old.complete([WeatherLocation.santoAndre]);
    await tester.pump();
    expect(find.text(campinas.label), findsOneWidget);
    expect(find.text(WeatherLocation.santoAndre.label), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
