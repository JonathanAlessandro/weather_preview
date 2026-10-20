import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/widgets/scene/cycling_painter.dart';
import 'package:weather_preview/widgets/scene/cycling_scene.dart';
import 'package:weather_preview/widgets/scene/sprite_registration.dart';

Future<ui.Image> load(String path) async {
  final bytes = await rootBundle.load(path);
  final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Coleira estável mantém as patas no mesmo plano nas 16 poses', () async {
    final dog = await load('assets/animations/newfoundland-trot-v2.png');
    addTearDown(dog.dispose);
    final bytes = (await dog.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final rgba = bytes.buffer.asUint8List();
    final anchors = collarAnchors(rgba, dog.width, dog.height);
    expect(anchors.length, 16);
    final ground = <double>[];
    for (var frame = 0; frame < 16; frame++) {
      final left = ((frame % 4) * dog.width / 4).floor();
      final top = ((frame ~/ 4) * dog.height / 4).floor();
      var bottom = 0;
      for (var y = 0; y < (dog.height / 4).ceil(); y += 2) {
        for (var x = 0; x < (dog.width / 4).ceil(); x += 2) {
          if (rgba[((top + y) * dog.width + left + x) * 4 + 3] > 128) {
            bottom = math.max(bottom, y);
          }
        }
      }
      ground.add(174 + (bottom - anchors[frame].dy) * 110 / (dog.width / 4));
    }
    expect(ground.reduce(math.max) - ground.reduce(math.min), lessThan(3));
    expect(ground.every((y) => y > 215 && y < 225), isTrue);
  });

  testWidgets('Cena preserva proporções em telas estreitas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: CyclingScene(
                  temperature: 21,
                  weatherCode: 0,
                  time: DateTime(2026, 10, 20, 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final painter = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is CyclingPainter,
    );
    final size = tester.getSize(painter);
    expect(size.width / size.height, closeTo(400 / 240, .001));
    await tester.pumpWidget(const SizedBox());
  });

  test('Renderiza prévias reais do novo cenário', () async {
    final rider = await load('assets/animations/cyclist-pedaling.png');
    final dog = await load('assets/animations/newfoundland-trot-v2.png');
    final art = await load('assets/scenery/urban-streets-v2.png');
    addTearDown(() {
      rider.dispose();
      dog.dispose();
      art.dispose();
    });
    final bytes = (await dog.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final anchors = collarAnchors(
      bytes.buffer.asUint8List(),
      dog.width,
      dog.height,
    );
    final directory = Directory('build/scene-previews')
      ..createSync(recursive: true);
    for (final entry in {
      0: 'Centro',
      8: 'Bairro residencial',
      15: 'Avenida arborizada',
    }.entries) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      CyclingPainter(
        motion: AlwaysStoppedAnimation(entry.key / 192),
        hour: 12,
        temperature: 21,
        code: 0,
        sprite: rider,
        dogSprite: dog,
        dogAnchors: anchors,
        backdrop: art,
        environment: entry.value,
      ).paint(canvas, const Size(800, 480));
      final picture = recorder.endRecording();
      final output = await picture.toImage(800, 480);
      final png = await output.toByteData(format: ui.ImageByteFormat.png);
      File('${directory.path}/scene-${entry.key}.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
      output.dispose();
      picture.dispose();
    }
  });
}
