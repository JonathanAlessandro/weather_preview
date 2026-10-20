import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/scene_weather.dart';
import 'package:weather_preview/widgets/weather_characters.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Neve acompanha os códigos WMO, mesmo com temperatura positiva', () {
    for (final code in [71, 73, 75, 77, 85, 86]) {
      final weather = SceneWeather(temperature: 3, code: code);
      expect(weather.snow, isTrue);
      expect(weather.rain, isFalse);
      expect(weather.outfit, CyclingOutfit.winter);
      expect(weather.description, contains('neve no pelo'));
    }
  });

  test('Chuva, garoa e trovoadas usam impermeável e pelo molhado', () {
    for (final code in [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99]) {
      final weather = SceneWeather(temperature: 10, code: code);
      expect(weather.rain, isTrue);
      expect(weather.snow, isFalse);
      expect(weather.outfit, CyclingOutfit.raincoat);
      expect(weather.description, contains('pelo molhado'));
    }
  });

  test('Frio seco muda a roupa sem inventar precipitação', () {
    const cold = SceneWeather(temperature: -3, code: 0);
    expect(cold.outfit, CyclingOutfit.winter);
    expect(cold.snow, isFalse);
    expect(cold.rain, isFalse);
    for (final temperature in [15.0, 28.0, 35.0]) {
      expect(SceneWeather(temperature: temperature, code: 0).outfit, CyclingOutfit.regular);
    }
    expect(const SceneWeather(temperature: 18, code: 45).rain, isFalse);
  });

  Future<List<int>> render(double phase, {required bool snow}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    WeatherCharacters.cyclist(canvas, const Rect.fromLTWH(0, 0, 150, 125), phase,
        snow ? CyclingOutfit.winter : CyclingOutfit.raincoat, snow: snow);
    WeatherCharacters.dog(canvas, const Rect.fromLTWH(150, 50, 100, 75), phase,
        wet: !snow, snow: snow);
    final picture = recorder.endRecording();
    final image = await picture.toImage(250, 125);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return bytes!.buffer.asUint8List().toList();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }

  test('Roupa, neve e pelo molhado são desenhados e acompanham a animação', () async {
    final winter = await render(0, snow: true);
    final wet = await render(0, snow: false);
    final moving = await render(0.02, snow: true);
    expect(winter.any((pixel) => pixel != 0), isTrue);
    expect(winter, isNot(orderedEquals(wet)));
    expect(winter, isNot(orderedEquals(moving)));
  });
}
