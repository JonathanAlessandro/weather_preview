import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/scene/dog_gait.dart';

void main() {
  test('Atlas leva 1,33 s por passada e exibe as 16 poses na ordem', () {
    final seconds = DogGait.sceneDuration.inMicroseconds / 1000000;
    expect(seconds / DogGait.cyclesPerScene, closeTo(4 / 3, 0.0001));
    final frames = List.generate(16, (i) => DogGait.frameAt(
        (i + 0.5) / (DogGait.cyclesPerScene * DogGait.frameCount)));
    expect(frames, List.generate(16, (i) => i));
    expect(DogGait.frameAt(0), DogGait.frameAt(1));
  });

  test('Apoio mantém a pata no chão; avanço levanta e devolve ao apoio', () {
    Offset at(double cycle) => DogGait.pawOffset(cycle / DogGait.cyclesPerScene, 0);
    expect(at(0.1).dy, 0);
    expect(at(0.5).dy, 0);
    expect(at(0.5).dx, lessThan(at(0.1).dx));
    expect(at(0.8).dy, closeTo(-8, 0.0001));
    for (final boundary in [DogGait.supportFraction, 1.0]) {
      expect((at(boundary - 0.000001) - at(boundary + 0.000001)).distance,
          lessThan(0.001));
    }
  });

  test('Pares diagonais correm juntos e fecham o loop sem salto', () {
    for (var i = 0; i < 120; i++) {
      final phase = i / 120;
      expect(DogGait.pawOffset(phase, 0), DogGait.pawOffset(phase, 3));
      expect(DogGait.pawOffset(phase, 1), DogGait.pawOffset(phase, 2));
      expect(DogGait.frameAt(phase), inInclusiveRange(0, 15));
    }
    for (var leg = 0; leg < 4; leg++) {
      expect(DogGait.pawOffset(0, leg), DogGait.pawOffset(1, leg));
    }
  });
}
