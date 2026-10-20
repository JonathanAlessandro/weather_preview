import 'dart:math' as math;
import 'dart:ui';

/// Um trote leve: seis passadas nos oito segundos do relógio da cena.
/// Compartilhado pelo atlas e pelas versões vetoriais de chuva e neve.
class DogGait {
  static const sceneDuration = Duration(seconds: 8);
  static const cyclesPerScene = 6;
  static const frameCount = 16;
  static const supportFraction = 0.6;

  static double cycleAt(double scenePhase) => (scenePhase * cyclesPerScene) % 1;

  static int frameAt(double scenePhase) =>
      (cycleAt(scenePhase) * frameCount).floor();

  /// Os pares diagonais se alternam. Durante o apoio, a pata permanece no
  /// chão e recua; no avanço, descreve um arco com velocidade vertical suave.
  static Offset pawOffset(double scenePhase, int leg) {
    final offset = leg == 0 || leg == 3 ? 0.0 : 0.5;
    final cycle = (cycleAt(scenePhase) + offset) % 1;
    if (cycle < supportFraction) {
      return Offset(11 - 22 * cycle / supportFraction, 0);
    }
    final progress = (cycle - supportFraction) / (1 - supportFraction);
    final eased = progress * progress * (3 - 2 * progress);
    final lift = math.sin(progress * math.pi);
    return Offset(-11 + 22 * eased, -8 * lift * lift);
  }
}
