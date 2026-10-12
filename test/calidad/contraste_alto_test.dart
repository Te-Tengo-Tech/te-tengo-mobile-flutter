import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/tema/paleta.dart';

import 'oscuro_y_letra_grande_test.dart' show abrirPlegables;
import 'pantallas.dart';

/// «Aumentar el contraste» (screens 349 to 354): the phone's accessibility setting turns on the
/// high-contrast palette, in light and in dark, and every main screen keeps readable text without
/// overflowing.
void main() {
  for (final p in [...pantallasPrincipales, ...pantallasNuevas]) {
    for (final oscuro in [false, true]) {
      testWidgets(
        '${p.nombre}: contraste alto${oscuro ? ' y modo oscuro' : ''}',
        (tester) async {
          tester.platformDispatcher.accessibilityFeaturesTestValue =
              const FakeAccessibilityFeatures(highContrast: true);
          if (oscuro) {
            tester.platformDispatcher.platformBrightnessTestValue =
                Brightness.dark;
          }
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          final semantica = tester.ensureSemantics();
          await abrirPantalla(tester, p);
          final contexto = tester.element(find.byType(Scaffold).last);
          expect(contexto.colores.contraste, isTrue);
          expect(contexto.colores.oscura, oscuro);
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await abrirPlegables(tester);
          expect(tester.takeException(), isNull);
          semantica.dispose();
        },
      );
    }
  }
}
