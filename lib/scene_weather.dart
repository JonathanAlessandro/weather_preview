enum CyclingOutfit { regular, winter, raincoat }

/// Códigos WMO da Open-Meteo; frio sozinho não significa neve.
class SceneWeather {
  const SceneWeather({required this.temperature, required this.code});

  final double temperature;
  final int code;

  bool get snow => const [71, 73, 75, 77, 85, 86].contains(code);
  bool get rain => const [51, 53, 55, 56, 57, 61, 63, 65, 66, 67,
    80, 81, 82, 95, 96, 99].contains(code);

  CyclingOutfit get outfit => rain ? CyclingOutfit.raincoat
      : snow || temperature < 15 ? CyclingOutfit.winter : CyclingOutfit.regular;

  String get description => snow
      ? 'Neve caindo. Ciclista com casaco e calça. Cachorro com neve no pelo.'
      : rain
          ? 'Chuva caindo. Ciclista com capa impermeável. Cachorro com pelo molhado.'
          : outfit == CyclingOutfit.winter ? 'Ciclista com casaco e calça.' : '';
}
