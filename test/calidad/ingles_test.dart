import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../apoyo/idioma.dart';
import 'pantallas.dart';

/// Names that come from the test data (people, rooms, cameras, PCs, emails, relationships typed by
/// a member) and stay as they are in any language, plus the brand and Peru's emergency service.
final _datos = RegExp(
  [
    r'Rosa Huamán',
    r'Carmen Huamán',
    r'Luis Huamán',
    r'Huamán',
    r'Rosa',
    r'Carmen',
    r'Luis',
    r'Sala-Rosa',
    r'Cocina-Rosa',
    r'Sala comedor',
    r'Sala',
    r'Pasillo',
    r'Cocina',
    r'Dormitorio',
    r'Comedor',
    r'Hija',
    r'Hijo',
    r'Te Tengo Captura',
    r'Te Tengo',
    r'SAMU',
    r'[\w.]+@[\w.]+',
  ].join('|'),
);

/// Signs of Spanish left on screen: accented letters, «¿ ¡ « »» and frequent short words.
final _espanol = RegExp(
  r'[áéíóúñÁÉÍÓÚÑ¿¡«»]|\b(de|del|la|las|el|los|en|y|con|para|que|por|una|un|sin|tu|tus|sus|más)\b',
);

/// Every text painted on screen (Text, RichText, fields), its tooltips and semantics labels.
List<String> _textos(WidgetTester tester) => [
  for (final e in find.byType(RichText).evaluate())
    (e.widget as RichText).text.toPlainText(),
  for (final e in find.byType(EditableText).evaluate())
    (e.widget as EditableText).controller.text,
  for (final e in find.byType(Tooltip).evaluate())
    ?(e.widget as Tooltip).message,
  for (final e in find.byType(Semantics).evaluate()) ...[
    ?(e.widget as Semantics).properties.label,
    ?(e.widget as Semantics).properties.hint,
  ],
];

/// The main screens open on a phone in English: they build without errors (no missing keys, no
/// overflow at 390 px) and show no Spanish besides the names in the test data.
void main() {
  for (final p in pantallasOscurasYGrandes) {
    testWidgets('en inglés: ${p.nombre}', (tester) async {
      usarIngles(tester);
      await abrirPantalla(tester, p);
      expect(tester.takeException(), isNull);
      final restos = <String>{
        for (final t in _textos(tester))
          if (_espanol.hasMatch(t.replaceAll(_datos, ''))) t,
      };
      expect(restos, isEmpty, reason: 'Spanish left on «${p.nombre}»');
    });
  }
}
