import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/tema/paleta.dart';

import 'pantallas.dart';

/// Opens the folds of a screen (the alert's clip and details), so their content is checked too.
Future<void> abrirPlegables(WidgetTester tester) async {
  for (final titulo in ['Más detalles', 'Clip del evento']) {
    final fila = find.text(titulo);
    if (fila.evaluate().isEmpty) continue;
    await tester.ensureVisible(fila);
    await tester.pumpAndSettle();
    await tester.tap(fila);
    await tester.pumpAndSettle();
  }
}

void main() {
  for (final p in pantallasOscurasYGrandes) {
    testWidgets('${p.nombre}: modo oscuro con contraste y sin desbordes', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final semantica = tester.ensureSemantics();
      await abrirPantalla(tester, p);
      // The app follows the phone's theme.
      final contexto = tester.element(find.byType(Scaffold).last);
      expect(Theme.of(contexto).brightness, Brightness.dark);
      expect(contexto.colores.oscura, isTrue);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await abrirPlegables(tester);
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantica.dispose();
    });

    testWidgets('${p.nombre}: texto al 200 % sin desbordes, también plegado '
        'abierto', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await abrirPantalla(tester, p);
      expect(tester.takeException(), isNull);
      await abrirPlegables(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${p.nombre}: oscuro y texto al 200 % a la vez', (
      tester,
    ) async {
      tester.platformDispatcher
        ..platformBrightnessTestValue = Brightness.dark
        ..textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await abrirPantalla(tester, p);
      expect(tester.takeException(), isNull);
    });
  }
}
