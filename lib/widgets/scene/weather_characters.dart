import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../scene/scene_weather.dart';
import '../../scene/dog_gait.dart';

/// Versões vetoriais locais: a roupa e o pelo acompanham as articulações.
class WeatherCharacters {
  static void cyclist(
    Canvas canvas,
    Rect bounds,
    double phase,
    CyclingOutfit outfit, {
    bool snow = false,
  }) {
    canvas.save();
    canvas.translate(bounds.left, bounds.top);
    canvas.scale(bounds.width / 150, bounds.height / 125);
    void stroke(Offset a, Offset b, Color color, double width) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    void dot(Offset p, double r, Color color) =>
        canvas.drawCircle(p, r, Paint()..color = color);
    const tire = Color(0xFF263445);
    const frame = Color(0xFF55A8C6);
    const pants = Color(0xFF283C58);
    const boots = Color(0xFF17283B);
    final coat = outfit == CyclingOutfit.raincoat
        ? const Color(0xFFFFC342)
        : const Color(0xFFC5574D);
    final crank = phase * math.pi * 16;
    for (final x in [29.0, 119.0]) {
      final center = Offset(x, 99);
      canvas.drawCircle(
        center,
        23,
        Paint()
          ..color = tire
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      for (var i = 0; i < 6; i++) {
        final angle = crank + i * math.pi / 3;
        stroke(
          center,
          center + Offset(math.cos(angle), math.sin(angle)) * 21,
          const Color(0xFFBDCBD3),
          1,
        );
      }
    }
    // Perna traseira, quadro e perna dianteira preservam a profundidade.
    final backFoot = Offset(
      72 - math.cos(crank) * 12,
      99 - math.sin(crank) * 12,
    );
    stroke(const Offset(64, 62), const Offset(48, 80), pants, 10);
    stroke(const Offset(48, 80), backFoot, pants, 9);
    stroke(backFoot, backFoot + const Offset(11, 1), boots, 6);
    for (final edge in [
      [const Offset(29, 99), const Offset(62, 65)],
      [const Offset(29, 99), const Offset(72, 99)],
      [const Offset(62, 65), const Offset(72, 99)],
      [const Offset(62, 65), const Offset(105, 66)],
      [const Offset(72, 99), const Offset(105, 66)],
      [const Offset(105, 66), const Offset(119, 99)],
    ]) {
      stroke(edge[0], edge[1], frame, 3);
    }
    stroke(const Offset(56, 62), const Offset(70, 62), tire, 4);
    stroke(const Offset(104, 67), const Offset(109, 55), tire, 3);
    stroke(const Offset(109, 55), const Offset(120, 54), tire, 4);
    final foot = Offset(72 + math.cos(crank) * 12, 99 + math.sin(crank) * 12);
    final knee = Offset(83 + math.cos(crank) * 5, 75 + math.sin(crank) * 6);
    stroke(const Offset(65, 62), knee, pants, 11);
    stroke(knee, foot, pants, 9);
    stroke(foot, foot + const Offset(11, 1), boots, 6);
    stroke(foot - const Offset(3, 0), foot + const Offset(13, 0), tire, 2);
    final bob = math.sin(crank * 2) * 0.8;
    canvas.save();
    canvas.translate(0, bob);
    final torso = Path()
      ..moveTo(58, 62)
      ..lineTo(66, 30)
      ..quadraticBezierTo(80, 24, 91, 35)
      ..lineTo(84, 65)
      ..close();
    canvas.drawPath(torso, Paint()..color = coat);
    stroke(const Offset(85, 36), const Offset(95, 49), coat, 12);
    stroke(const Offset(95, 49), const Offset(112, 55), coat, 10);
    dot(const Offset(115, 55), 4, boots); // Luvas.
    stroke(
      const Offset(74, 37),
      const Offset(71, 58),
      const Color(0x99FFFFFF),
      1,
    );
    dot(const Offset(85, 19), 12, const Color(0xFFD9A77F));
    dot(const Offset(92, 19), 1.2, tire);
    final hood = Path()
      ..moveTo(73, 29)
      ..quadraticBezierTo(66, 5, 83, 4)
      ..quadraticBezierTo(98, 4, 98, 14)
      ..lineTo(82, 12)
      ..lineTo(79, 28)
      ..close();
    canvas.drawPath(
      hood,
      Paint()..color = outfit == CyclingOutfit.raincoat ? coat : pants,
    );
    if (outfit == CyclingOutfit.winter) {
      stroke(
        const Offset(78, 31),
        const Offset(90, 31),
        const Color(0xFFE1B96F),
        5,
      );
      final scarf = Path()
        ..moveTo(78, 32)
        ..lineTo(61, 37 + math.sin(crank) * 3)
        ..lineTo(64, 31)
        ..close();
      canvas.drawPath(scarf, Paint()..color = const Color(0xFFE1B96F));
    } else {
      stroke(
        const Offset(68, 45),
        const Offset(82, 47),
        const Color(0xFFE7F0B2),
        3,
      );
    }
    if (snow) {
      stroke(
        const Offset(77, 6),
        const Offset(87, 6),
        const Color(0xFFEFF8FF),
        3,
      );
      stroke(
        const Offset(78, 30),
        const Offset(86, 32),
        const Color(0xFFD9EDF6),
        3,
      );
    }
    canvas.restore();
    canvas.restore();
  }

  static void dog(
    Canvas canvas,
    Rect bounds,
    double phase, {
    required bool wet,
    required bool snow,
  }) {
    canvas.save();
    canvas.translate(bounds.left, bounds.top);
    canvas.scale(bounds.width / 100, bounds.height / 75);
    final stride = DogGait.cycleAt(phase) * math.pi * 2;
    const bob = 0.0;
    final fur = wet ? const Color(0xFF18242D) : const Color(0xFF2B3039);
    final shine = wet ? const Color(0xFF647781) : const Color(0xFF444A55);
    void stroke(Offset a, Offset b, Color color, double width) =>
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = color
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round,
        );
    canvas.translate(0, bob);
    // Patas distantes primeiro; pares diagonais alternam apoio e avanço.
    for (final i in [0, 2, 1, 3]) {
      final hip = i < 2 ? 27.0 : 63.0;
      final root = Offset(hip, 43);
      final paw = Offset(hip, 68) + DogGait.pawOffset(phase, i);
      final delta = paw - root;
      final length = delta.distance;
      final bend = math.sqrt(math.max(0.0, 16 * 16 - length * length / 4));
      final normal = Offset(delta.dy, -delta.dx) / length;
      final knee = (root + paw) / 2 + normal * (i < 2 ? -bend : bend);
      final legColor = i.isEven ? Color.lerp(fur, shine, 0.18)! : fur;
      stroke(root, knee, legColor, wet ? 7 : 9);
      stroke(knee, paw, legColor, 6);
      stroke(paw, paw + const Offset(8, 0), legColor, 5);
    }
    stroke(const Offset(20, 34), Offset(8, 18 + math.sin(stride) * 4), fur, 9);
    final body = Rect.fromLTWH(14, wet ? 25 : 21, 60, wet ? 27 : 33);
    canvas.drawOval(body, Paint()..color = fur);
    canvas.drawOval(const Rect.fromLTWH(57, 17, 23, 35), Paint()..color = fur);
    canvas.drawOval(const Rect.fromLTWH(64, 9, 24, 24), Paint()..color = fur);
    canvas.drawOval(const Rect.fromLTWH(79, 21, 18, 11), Paint()..color = fur);
    canvas.drawOval(
      const Rect.fromLTWH(63, 15, 11, 24),
      Paint()..color = const Color(0xFF111B25),
    );
    canvas.drawCircle(
      const Offset(83, 18),
      1.5,
      Paint()..color = const Color(0xFFEAC58B),
    );
    stroke(
      const Offset(89, 31),
      const Offset(90, 36),
      const Color(0xFFCA8990),
      3,
    );
    if (wet) {
      // Mechas achatadas e reflexos frios dão aparência de pelo encharcado.
      for (var i = 0; i < 8; i++) {
        final x = 22.0 + i * 6;
        stroke(Offset(x, 29), Offset(x + 2, 44), shine, 1.2);
        final dripY = 49 + ((phase * 8 + i / 8) % 1) * 22;
        canvas.drawOval(
          Rect.fromLTWH(x, dripY, 1.5, 3),
          Paint()..color = const Color(0xAA9CCAD9),
        );
      }
    }
    if (snow) {
      // A neve acompanha o dorso e a cabeça durante a corrida.
      for (var i = 0; i < 9; i++) {
        final x = 21.0 + i * 5;
        final y = 24 - math.sin(i / 8 * math.pi) * 3;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 4),
          Paint()..color = const Color(0xFFE6F2FA),
        );
      }
      stroke(
        const Offset(72, 11),
        const Offset(81, 11),
        const Color(0xFFF7FCFF),
        4,
      );
    }
    canvas.restore();
  }
}
