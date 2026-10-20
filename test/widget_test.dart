import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_preview/widgets/titulo_secao.dart';

void main() {
  testWidgets('TituloSecao exibe o texto informado', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TituloSecao(titulo: 'Detalhes')),
      ),
    );

    expect(find.text('Detalhes'), findsOneWidget);
  });
}
