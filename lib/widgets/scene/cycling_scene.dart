import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../scene/scene_weather.dart';
import 'cycling_painter.dart';
import 'sprite_registration.dart';

/// Cenário dinâmico com animação de sprites locais do ciclista e de um Terra Nova.
class CyclingScene extends StatefulWidget {
  const CyclingScene({
    super.key,
    required this.temperature,
    required this.weatherCode,
    this.time,
    this.locationName = 'Santo André, SP',
    this.utcOffsetSeconds = -10800,
  });

  final double temperature;
  final int weatherCode;
  final String locationName;
  final int utcOffsetSeconds;

  /// Horário local fixo para prévias; por padrão acompanha o relógio.
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
  ui.Image? _backdrop;
  List<ui.Offset> _dogAnchors = [];
  String _environment = 'Automático';
  bool _spriteError = false;
  bool _dogSpriteError = false;
  DateTime _time = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _loadSprite('assets/animations/cyclist-pedaling.png');
    _loadSprite('assets/animations/newfoundland-trot-v2.png', dog: true);
    _loadSprite('assets/scenery/urban-streets-v2.png', backdrop: true);
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _time = DateTime.now().toUtc();
      });
    });
  }

  Future<void> _loadSprite(
    String asset, {
    bool dog = false,
    bool backdrop = false,
  }) async {
    try {
      final bytes = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      try {
        final frame = await codec.getNextFrame();
        if (!mounted) {
          frame.image.dispose();
          return;
        }
        List<ui.Offset> anchors = [];
        if (dog) {
          final data = await frame.image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          if (data != null) {
            anchors = collarAnchors(
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
              frame.image.width,
              frame.image.height,
            );
          }
        }
        if (!mounted) {
          frame.image.dispose();
          return;
        }
        setState(() {
          if (backdrop) {
            _backdrop = frame.image;
          } else if (dog) {
            _dogAnchors = anchors;
            _dogSprite = frame.image;
          } else {
            _sprite = frame.image;
          }
        });
      } finally {
        codec.dispose();
      }
    } catch (_) {
      if (mounted && !backdrop) {
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
    _backdrop?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final time =
        widget.time ?? _time.add(Duration(seconds: widget.utcOffsetSeconds));
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
    final appearance = SceneWeather(
      temperature: widget.temperature,
      code: widget.weatherCode,
    );
    final scene = Semantics(
      label:
          'Rapaz pedalando com um cachorro Terra Nova correndo ao lado em ${widget.locationName}. $environment. $period. $climate. '
          '${widget.temperature.round()} graus Celsius. ${appearance.description}',
      image: true,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 400 / 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: CyclingPainter(
                      motion: _motion,
                      sprite: _sprite,
                      dogSprite: _dogSprite,
                      dogAnchors: _dogAnchors,
                      backdrop: _backdrop,
                      environment: environment,
                      hour: hour,
                      temperature: widget.temperature,
                      code: widget.weatherCode,
                    ),
                  ),
                ),
                if (_dogSpriteError && !appearance.rain && !appearance.snow)
                  const Positioned(
                    bottom: 8,
                    right: 8,
                    child: Text(
                      'Não foi possível carregar o cachorro.',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                if (_spriteError && appearance.outfit == CyclingOutfit.regular)
                  const Center(
                    child: Text('Não foi possível carregar o ciclista.'),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        '$environment · $period · $climate',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
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
          runSpacing: 4,
          children:
              [
                'Automático',
                'Centro',
                'Bairro residencial',
                'Avenida arborizada',
              ].map((name) {
                return ChoiceChip(
                  label: Text(name),
                  selected: _environment == name,
                  selectedColor: colors.primary,
                  checkmarkColor: colors.onPrimary,
                  labelStyle: TextStyle(
                    color: _environment == name
                        ? colors.onPrimary
                        : colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _environment = name),
                );
              }).toList(),
        ),
      ],
    );
  }
}
