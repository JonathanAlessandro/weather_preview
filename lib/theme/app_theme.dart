import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../scene/scene_weather.dart';

class AppTheme {
  static ThemeData forWeather(WeatherData? weather) {
    final palette = _palette(weather);
    final colors = ColorScheme.fromSeed(seedColor: palette.primary).copyWith(
      primary: palette.primary, onPrimary: Colors.white,
      secondary: palette.secondary, onSecondary: Colors.white,
      tertiary: palette.action, onTertiary: Colors.white,
      surface: palette.surface, onSurface: const Color(0xFF172B4D),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background, foregroundColor: colors.onSurface,
        elevation: 0, scrolledUnderElevation: 0, centerTitle: false,
        titleTextStyle: TextStyle(color: colors.onSurface, fontSize: 22,
            fontWeight: FontWeight.w800),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: colors.primary, foregroundColor: colors.onPrimary,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: colors.tertiary, foregroundColor: colors.onTertiary, elevation: 0,
        minimumSize: const Size(48, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      )),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface, selectedColor: colors.primary,
        side: BorderSide(color: colors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        labelStyle: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: palette.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static _WeatherPalette _palette(WeatherData? weather) {
    if (weather == null) return const _WeatherPalette();
    final scene = SceneWeather(temperature: weather.temperature, code: weather.code);
    if (scene.snow) {
      return const _WeatherPalette(primary: Color(0xFF0369A1), secondary: Color(0xFF0F766E),
          action: Color(0xFF5B21B6), background: Color(0xFFEFF9FF), surface: Color(0xFFFCFEFF));
    }
    if (weather.code == 95 || weather.code == 96 || weather.code == 99) {
      return const _WeatherPalette(primary: Color(0xFF6D28D9), secondary: Color(0xFF4338CA),
          action: Color(0xFFBE185D), background: Color(0xFFF0EBFA), surface: Color(0xFFFCFAFF));
    }
    if (scene.rain) {
      return const _WeatherPalette(primary: Color(0xFF1D4ED8), secondary: Color(0xFF0E7490),
          action: Color(0xFF6D28D9), background: Color(0xFFEAF2FD), surface: Color(0xFFF9FBFF));
    }
    if (weather.code == 45 || weather.code == 48) {
      return const _WeatherPalette(primary: Color(0xFF475569), secondary: Color(0xFF0F766E),
          action: Color(0xFF6D28D9), background: Color(0xFFEEF2F3));
    }
    if (weather.code == 2 || weather.code == 3) {
      return const _WeatherPalette(primary: Color(0xFF3157B7), secondary: Color(0xFF00796B),
          action: Color(0xFF9B3DA0), background: Color(0xFFEDF2FA));
    }
    if (weather.temperature < 15) {
      return const _WeatherPalette(primary: Color(0xFF0369A1), secondary: Color(0xFF0F766E),
          action: Color(0xFF5B21B6), background: Color(0xFFF0F7FD));
    }
    if (weather.code == 0 || weather.code == 1) {
      return const _WeatherPalette(primary: Color(0xFF9A3412), secondary: Color(0xFF00796B),
          action: Color(0xFF6D28D9), background: Color(0xFFFFF5E9), surface: Color(0xFFFFFCF7));
    }
    return const _WeatherPalette();
  }
}

class _WeatherPalette {
  const _WeatherPalette({this.primary = const Color(0xFF4F46E5),
    this.secondary = const Color(0xFF00796B), this.action = const Color(0xFFC2410C),
    this.background = const Color(0xFFF3F6FC), this.surface = Colors.white});

  final Color primary;
  final Color secondary;
  final Color action;
  final Color background;
  final Color surface;
}
