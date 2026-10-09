import 'package:flutter_test/flutter_test.dart';

import 'pantallas.dart';

void main() {
  for (final p in pantallasPrincipales) {
    testWidgets('${p.nombre}: áreas táctiles, etiquetas y contraste', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await abrirPantalla(tester, p);
      // AGENTS.md asks for touch targets of at least 44 px (the iOS guideline).
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantica.dispose();
    });

    testWidgets('${p.nombre}: texto al 200 % sin desbordes', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await abrirPantalla(tester, p);
      expect(tester.takeException(), isNull);
    });
  }
}
