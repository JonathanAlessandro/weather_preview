import 'package:flutter/material.dart';

import 'controllers/weather_controller.dart';
import 'screens/weather_page.dart';
import 'services/location_search_service.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';

/// Único ponto de entrada: cria e conecta as partes do aplicativo monolítico.
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.service, this.locationService, this.searchService});

  final WeatherService? service;
  final LocationService? locationService;
  final LocationSearchService? searchService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WeatherController _controller;
  late final LocationSearchService _searchService;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(
      weatherService: widget.service ?? WeatherService(),
      locationService: widget.locationService ?? LocationService(),
    );
    _searchService = widget.searchService ?? LocationSearchService();
    _controller.refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: WeatherPage(controller: _controller, searchService: _searchService),
    );
  }
}
