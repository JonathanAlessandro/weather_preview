import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cenário dinâmico com animação de oito sprites locais do ciclista.
class CyclingScene extends StatefulWidget {
  const CyclingScene({
    super.key,
    required this.temperature,
    required this.weatherCode,
  });

  final double temperature;
  final int weatherCode;

  @override
  State<CyclingScene> createState() => _CyclingSceneState();
}

class _CyclingSceneState extends State<CyclingScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Timer? _clock;
  ui.Image? _sprite;
  bool _spriteError = false;
  DateTime _time = DateTime.now().toUtc().subtract(const Duration(hours: 3));

  @override
  void initState() {
    super.initState();
    _loadSprite();
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _time = DateTime.now().toUtc().subtract(const Duration(hours: 3));
      });
    });
  }

  Future<void> _loadSprite() async {
    try {
      final bytes = await rootBundle.load('assets/animations/cyclist-pedaling.png');
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(
        bytes.offsetInBytes, bytes.lengthInBytes,
      ));
      try {
        final frame = await codec.getNextFrame();
        if (!mounted) {
          frame.image.dispose();
          return;
        }
        setState(() => _sprite = frame.image);
      } finally {
        codec.dispose();
      }
    } catch (_) {
      if (mounted) setState(() => _spriteError = true);
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
    } else {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    _motion.dispose();
    _sprite?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = _time.hour + _time.minute / 60;
    final period = hour < 5 || hour >= 19
        ? 'Noite'
        : hour < 7
            ? 'Amanhecer'
            : hour >= 17
                ? 'Entardecer'
                : 'Dia';
    final climate = widget.temperature < 15
        ? 'Frio'
        : widget.temperature >= 28
            ? 'Calor'
            : 'Clima ameno';
    return Semantics(
      label: 'Rapaz pedalando em Santo André. $period. $climate. '
          '${widget.temperature.round()} graus Celsius.',
      image: true,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: _CyclingPainter(
                      motion: _motion,
                      sprite: _sprite,
                      hour: hour,
                      temperature: widget.temperature,
                      code: widget.weatherCode,
                    ),
                  ),
                ),
                if (_spriteError)
                  const Center(child: Text('Não foi possível carregar o ciclista.')),
                Positioned(
                  top: 16,
                  left: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xB3203044),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text('$period · $climate',
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CyclingPainter extends CustomPainter {
  _CyclingPainter({required this.motion, required this.hour,
    required this.temperature, required this.code, required this.sprite}) : super(repaint: motion);

  final Animation<double> motion;
  final ui.Image? sprite;
  final double hour;
  final double temperature;
  final int code;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 240);
    const bounds = Rect.fromLTWH(0, 0, 400, 240);
    final t = motion.value;
    final night = hour < 5 || hour >= 19;
    final twilight = !night && (hour < 7 || hour >= 17);
    final cold = temperature < 15;
    final hot = temperature >= 28;
    final rain = (code >= 51 && code <= 67) ||
        (code >= 80 && code <= 82) || code >= 95;
    final snow = (code >= 71 && code <= 77) || code == 85 || code == 86;
    final cloudy = code >= 2;
    final sky = night
        ? [const Color(0xFF101B3E), const Color(0xFF45537D)]
        : twilight
            ? [const Color(0xFF8465A6), const Color(0xFFFFC193)]
            : cold
                ? [const Color(0xFF83AFC9), const Color(0xFFDCE9F0)]
                : hot
                    ? [const Color(0xFF319EDE), const Color(0xFFFFE9A6)]
                    : [const Color(0xFF66BCE5), const Color(0xFFD4F2EA)];
    canvas.drawRect(bounds, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: sky,
    ).createShader(bounds));

    void line(Offset a, Offset b, Color color, double width) {
      canvas.drawLine(a, b, Paint()..color = color
        ..strokeWidth = width..strokeCap = StrokeCap.round);
    }
    void circle(Offset center, double radius, Color color) {
      canvas.drawCircle(center, radius, Paint()..color = color);
    }

    if (night) {
      for (var i = 0; i < 24; i++) {
        circle(Offset((i * 67.0 + 17) % 400, (i * 31.0) % 115 + 12),
            i.isEven ? 1.4 : 0.8, const Color(0xCCFFFFFF));
      }
      circle(const Offset(330, 48), 20, const Color(0xFFFFF2C9));
      circle(const Offset(339, 41), 19, sky.first);
    } else {
      circle(Offset(326, twilight ? 115 : 57), hot ? 28 : 22,
          const Color(0xFFFFDE89));
    }

    // Colinas e árvores em camadas para criar profundidade.
    for (var layer = 0; layer < 2; layer++) {
      final path = Path()..moveTo(0, 190);
      for (var x = 0; x <= 400; x += 4) {
        path.lineTo(x.toDouble(), 153 + layer * 20 +
            math.sin(x / 70 + layer * 2) * 15);
      }
      path..lineTo(400, 240)..lineTo(0, 240)..close();
      canvas.drawPath(path, Paint()..color = night
          ? (layer == 0 ? const Color(0xFF354C66) : const Color(0xFF24464A))
          : cold
              ? (layer == 0 ? const Color(0xFFA4BCC2) : const Color(0xFF749B9C))
              : (layer == 0 ? const Color(0xFF85BA9C) : const Color(0xFF4D977D)));
    }
    for (var i = 0; i < 6; i++) {
      final x = (i * 85 + 400 - t * 170) % 510 - 55;
      line(Offset(x, 184), Offset(x, 139), const Color(0xFF586B62), 5);
      circle(Offset(x, 133), 18, night ? const Color(0xFF244B4B)
          : cold ? const Color(0xFF83A9A5) : const Color(0xFF3B876A));
    }
    if (cloudy || cold) {
      for (var i = 0; i < (rain ? 5 : 3); i++) {
        final x = (i * 143 + 440 - t * 48) % 510 - 55;
        final y = 48.0 + (i % 2) * 36;
        final color = rain ? const Color(0xAA748795) : const Color(0xBBFFFFFF);
        circle(Offset(x, y), 16, color);
        circle(Offset(x + 19, y - 7), 23, color);
        circle(Offset(x + 40, y), 17, color);
      }
    }
    canvas.drawRect(const Rect.fromLTWH(0, 199, 400, 41),
        Paint()..color = night ? const Color(0xFF253043) : const Color(0xFF697B86));
    line(const Offset(0, 200), const Offset(400, 200), const Color(0xFFC4D6CF), 3);
    for (var i = 0; i < 8; i++) {
      final x = (i * 70 - t * 560) % 560 - 70;
      line(Offset(x, 223), Offset(x + 28, 223), const Color(0xBBDDE8D8), 3);
    }

    final image = sprite;
    if (image != null) {
      final frame = (t * 64).floor() % 8;
      final cellWidth = image.width / 4;
      final cellHeight = image.height / 2;
      final source = Rect.fromLTWH(
        (frame % 4) * cellWidth, (frame ~/ 4) * cellHeight,
        cellWidth, cellHeight,
      );
      final bob = math.sin(t * math.pi * 16) * 0.6;
      canvas.drawImageRect(image, source,
        Rect.fromLTWH(120, 4 + bob, 160, 160 * cellHeight / cellWidth),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    if (rain || snow) {
      for (var i = 0; i < 45; i++) {
        final x = (i * 73.0 - t * 120) % 420;
        final y = (i * 41.0 + t * 960) % 240;
        if (snow) {
          circle(Offset(x, y), 2, const Color(0xCCFFFFFF));
        } else {
          line(Offset(x, y), Offset(x - 4, y + 10), const Color(0x8879C9F2), 1.4);
        }
      }
    }
    if (code == 45 || code == 48) {
      canvas.drawRect(bounds, Paint()..color = const Color(0x44DCE8ED));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CyclingPainter oldDelegate) =>
      oldDelegate.hour != hour || oldDelegate.temperature != temperature ||
      oldDelegate.code != code || oldDelegate.motion != motion ||
      oldDelegate.sprite != sprite;
}
