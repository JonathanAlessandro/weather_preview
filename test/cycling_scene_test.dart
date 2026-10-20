import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_preview/widgets/scene/cycling_scene.dart';

void main() {
  Widget scene(int hour, {double temperature = 21, int code = 0}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: CyclingScene(
            temperature: temperature,
            weatherCode: code,
            time: DateTime(2026, 10, 20, hour),
          ),
        ),
      ),
    );
  }

  testWidgets('Automático mantém paisagem urbana no frio e no calor', (tester) async {
    for (final temperature in [10.0, 32.0]) {
      for (final entry in {6: 'Bairro residencial · Amanhecer',
        10: 'Centro · Dia', 14: 'Avenida arborizada · Dia',
        18: 'Bairro residencial · Entardecer',
        22: 'Bairro residencial · Noite'}.entries) {
        await tester.pumpWidget(scene(entry.key, temperature: temperature));
        await tester.pump();
        expect(find.textContaining(entry.value), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, 'Praia'), findsNothing);
        expect(find.widgetWithText(ChoiceChip, 'Floresta'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Escolha manual persiste ao mudar horário e condição', (tester) async {
    await tester.pumpWidget(scene(10));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Avenida arborizada'));
    await tester.pump();
    for (final code in [3, 45, 61, 75, 95]) {
      await tester.pumpWidget(scene(22, code: code));
      await tester.pump();
      expect(find.textContaining('Avenida arborizada · Noite'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.widgetWithText(ChoiceChip, 'Automático'));
    await tester.pump();
    expect(find.textContaining('Bairro residencial · Noite'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
