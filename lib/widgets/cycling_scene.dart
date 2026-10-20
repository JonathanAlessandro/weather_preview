import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cenário dinâmico com animação de sprites locais do ciclista e de um Terra Nova.
class CyclingScene extends StatefulWidget {
  const CyclingScene({
    super.key,
    required this.temperature,
    required this.weatherCode,
    this.time,
  });

  final double temperature;
  final int weatherCode;

  /// Horário de Brasília fixo para prévias; por padrão acompanha o relógio.
  final DateTime? time;

  @override
  State<CyclingScene> createState() => _CyclingSceneState();
}

class _CyclingSceneState extends State<CyclingScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Timer? _clock;
  ui.Image? _sprite;
  ui.Image? _dogSprite;
  String _environment = 'Automático';
  bool _spriteError = false;
  bool _dogSpriteError = false;
  DateTime _time = DateTime.now().toUtc().subtract(const Duration(hours: 3));

  @override
  void initState() {
    super.initState();
    _loadSprite('assets/animations/cyclist-pedaling.png');
    _loadSprite('assets/animations/newfoundland-running.png', dog: true);
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _time = DateTime.now().toUtc().subtract(const Duration(hours: 3));
      });
    });
  }

  Future<void> _loadSprite(String asset, {bool dog = false}) async {
    try {
      final bytes = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(
        bytes.offsetInBytes, bytes.lengthInBytes,
      ));
      try {
        final frame = await codec.getNextFrame();
        if (!mounted) {
          frame.image.dispose();
          return;
        }
        setState(() {
          if (dog) {
            _dogSprite = frame.image;
          } else {
            _sprite = frame.image;
          }
        });
      } finally {
        codec.dispose();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (dog) {
            _dogSpriteError = true;
          } else {
            _spriteError = true;
          }
        });
      }
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
    _dogSprite?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = widget.time ?? _time;
    final hour = time.hour + time.minute / 60;
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
    final environment = _environment == 'Automático'
        ? (hour >= 7 && hour < 12
            ? 'Centro'
            : hour >= 12 && hour < 17
                ? 'Avenida arborizada'
                : 'Bairro residencial')
        : _environment;
    final scene = Semantics(
      label: 'Rapaz pedalando com um cachorro Terra Nova correndo ao lado em Santo André. $environment. $period. $climate. '
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
                      dogSprite: _dogSprite,
                      environment: environment,
                      hour: hour,
                      temperature: widget.temperature,
                      code: widget.weatherCode,
                    ),
                  ),
                ),
                if (_dogSpriteError)
                  const Positioned(bottom: 8, right: 8,
                    child: Text('Não foi possível carregar o cachorro.',
                      style: TextStyle(color: Colors.white, fontSize: 11))),
                if (_spriteError)
                  const Center(child: Text('Não foi possível carregar o ciclista.')),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xB3203044),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text('$environment · $period · $climate',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        scene,
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Automático', 'Centro', 'Bairro residencial', 'Avenida arborizada'].map((name) {
            return ChoiceChip(
              label: Text(name),
              selected: _environment == name,
              onSelected: (_) => setState(() => _environment = name),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CyclingPainter extends CustomPainter {
  _CyclingPainter({required this.motion, required this.hour,
    required this.temperature, required this.code, required this.sprite, required this.dogSprite, required this.environment}) : super(repaint: motion);

  final Animation<double> motion;
  final ui.Image? sprite;
  final ui.Image? dogSprite;
  final String environment;
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
    // Interpolação por minuto evita saltos de cor entre os períodos.
    final daylight = hour < 5 || hour >= 19
        ? 0.0
        : hour < 7
            ? (hour - 5) / 2
            : hour > 17
                ? (19 - hour) / 2
                : 1.0;
    final warmth = twilight ? math.sin(daylight * math.pi) : 0.0;
    Color lit(Color day, Color dark) => Color.lerp(dark, day, daylight)!;
    final sky = [
      Color.lerp(lit(cold ? const Color(0xFF83AFC9) : const Color(0xFF66BCE5),
          const Color(0xFF101B3E)), const Color(0xFFAD789E), warmth)!,
      Color.lerp(lit(hot ? const Color(0xFFFFE9A6) : const Color(0xFFD4F2EA),
          const Color(0xFF45537D)), const Color(0xFFFFC193), warmth)!,
    ];
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

    _paintCity(canvas, t, daylight);
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
        Paint()..color = lit(const Color(0xFF697B86), const Color(0xFF253043)));
    line(const Offset(0, 200), const Offset(400, 200), const Color(0xFFC4D6CF), 3);
    for (var i = 0; i < 9; i++) {
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
    final dog = dogSprite;
    if (dog != null) {
      // Dezesseis quadros por segundo: duas passadas completas por segundo.
      final frame = (t * 128).floor() % 8;
      final cellWidth = dog.width / 4;
      final cellHeight = dog.height / 2;
      final source = Rect.fromLTWH(
        (frame % 4) * cellWidth, (frame ~/ 4) * cellHeight,
        cellWidth, cellHeight,
      );
      canvas.drawImageRect(dog, source,
        Rect.fromLTWH(276, 75, 110, 110 * cellHeight / cellWidth),
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

  void _paintCity(Canvas canvas, double t, double daylight) {
    Color lit(Color day, Color dark) => Color.lerp(dark, day, daylight)!;
    void rect(double x, double y, double w, double h, Color color) {
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = color);
    }
    void line(double x, double y, double x2, double y2, Color color,
        [double width = 2]) {
      canvas.drawLine(Offset(x, y), Offset(x2, y2),
          Paint()..color = color..strokeWidth = width);
    }
    final window = lit(const Color(0xFFABCBD4), const Color(0xFFFFD98A));
    final shadow = lit(const Color(0xFF567C91), const Color(0xFF28354E));

    // Cada camada percorre um número inteiro de módulos por ciclo:
    // a paisagem fecha o loop sem emendas e mantém profundidade.
    for (var i = 0; i < 13; i++) {
      final x = i * 40.0 - t * 80 - 40;
      final height = 42.0 + (i % 2) * 22;
      rect(x, 181 - height, 32, height,
          lit(const Color(0xFF92ADB9), const Color(0xFF34445E)));
      rect(x + 4, 181 - height + 6, 24, 3, shadow);
    }

    final residential = environment == 'Bairro residencial';
    final avenue = environment == 'Avenida arborizada';
    for (var i = 0; i < 9; i++) {
      final x = i * 80.0 - t * 160 - 80;
      final height = residential ? 38.0 : avenue ? 66.0 : 88.0 + (i % 2) * 26;
      final top = 188 - height;
      final facade = lit(
          residential ? const Color(0xFFD9BBA1)
              : avenue ? const Color(0xFFB8C7BD) : const Color(0xFFB5C6D2),
          const Color(0xFF45526B));
      rect(x, top, 62, height, facade);
      rect(x + 49, top, 13, height, shadow);
      if (residential) {
        final roof = Path()..moveTo(x - 4, top)
          ..lineTo(x + 31, top - 18)..lineTo(x + 66, top)..close();
        canvas.drawPath(roof, Paint()..color = lit(
            const Color(0xFFAF715C), const Color(0xFF493F53)));
        rect(x + 25, 165, 12, 23, shadow);
      } else {
        rect(x - 2, top, 66, 4, shadow);
        // Lojas no térreo e marquise voltada à calçada.
        rect(x + 6, 169, 36, 19, shadow);
        rect(x + 7, 171, 14, 14, window);
        rect(x + 25, 171, 14, 14, window);
        rect(x - 2, 162, 64, 6, lit(
            const Color(0xFFBD7967), const Color(0xFF6C4C60)));
      }
      for (var row = 0; row < (residential ? 1 : avenue ? 3 : 5); row++) {
        for (var col = 0; col < 3; col++) {
          rect(x + 7 + col * 13, top + 10 + row * 12, 7, 7,
              (row + col + i % 2) % 3 == 0 ? shadow : window);
        }
      }
    }
    rect(0, 188, 400, 11, lit(
        const Color(0xFFC8C5B9), const Color(0xFF4C5260)));
    for (var i = 0; i < 8; i++) {
      final x = i * 100.0 - t * 200 - 100;
      if (avenue || residential) {
        line(x + 34, 191, x + 34, 151, shadow, 4);
        final leaf = lit(const Color(0xFF4B8E72), const Color(0xFF264B4C));
        for (var crown = 0; crown < 3; crown++) {
          canvas.drawCircle(Offset(x + 22 + crown * 12, 149 - (crown % 2) * 9),
              avenue ? 18 : 12, Paint()..color = leaf);
        }
      }
      // Postes e luzes acendem gradualmente ao anoitecer.
      line(x + 77, 193, x + 77, 128, shadow, 3);
      line(x + 77, 128, x + 92, 128, shadow, 3);
      if (daylight < 1) {
        final beam = Path()..moveTo(x + 87, 132)
          ..lineTo(x + 70, 197)..lineTo(x + 114, 197)
          ..lineTo(x + 97, 132)..close();
        canvas.drawPath(beam, Paint()..color =
            Color.fromRGBO(255, 218, 143, (1 - daylight) * 0.16));
        canvas.drawCircle(Offset(x + 92, 131), 10,
            Paint()..color = Color.fromRGBO(255, 218, 143, (1 - daylight) * 0.12));
      }
      rect(x + 86, 128, 12, 4, window);
    }
  }

  @override
  bool shouldRepaint(covariant _CyclingPainter oldDelegate) =>
      oldDelegate.hour != hour || oldDelegate.temperature != temperature ||
      oldDelegate.code != code || oldDelegate.motion != motion ||
      oldDelegate.sprite != sprite || oldDelegate.dogSprite != dogSprite ||
      oldDelegate.environment != environment;
}
