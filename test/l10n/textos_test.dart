import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/formato.dart';
import 'package:te_tengo/l10n/l10n.dart';

Map<String, Object?> _arb(String idioma) =>
    jsonDecode(File('lib/l10n/app_$idioma.arb').readAsStringSync())
        as Map<String, Object?>;

/// The placeholders [mensaje] uses (`{nombre}`, `{n, plural, …}`), not the text of ICU branches
/// (`other{cámaras}`, `=1{…}`).
Set<String> _marcadores(String mensaje) => {
  for (final m in RegExp(r'(?<![\w=])\{\s*(\w+)\s*[,}]').allMatches(mensaje))
    m[1]!,
};

void main() {
  group('ARB', () {
    final es = _arb('es');
    final en = _arb('en');
    Iterable<String> claves(Map<String, Object?> arb) =>
        arb.keys.where((k) => !k.startsWith('@'));

    test('Spanish and English have the same keys', () {
      expect(claves(en).toSet().difference(claves(es).toSet()), isEmpty);
      expect(claves(es).toSet().difference(claves(en).toSet()), isEmpty);
    });

    test('no message is empty', () {
      for (final arb in [es, en]) {
        for (final k in claves(arb)) {
          expect((arb[k]! as String).trim(), isNotEmpty, reason: k);
        }
      }
    });

    test('every placeholder is declared in the Spanish template', () {
      // English may leave out a Spanish-only one (the room with its article, «la Sala»).
      for (final k in claves(es)) {
        final meta = es['@$k'] as Map<String, Object?>?;
        final declarados =
            (meta?['placeholders'] as Map<String, Object?>?)?.keys.toSet() ??
            const <String>{};
        expect(
          declarados,
          containsAll(_marcadores(es[k]! as String)),
          reason: k,
        );
        expect(
          declarados,
          containsAll(_marcadores(en[k]! as String)),
          reason: k,
        );
      }
    });
  });

  group('idioma del celular', () {
    test('English when the phone prefers English', () {
      expect(resolverIdioma(const [Locale('en', 'GB')]), const Locale('en'));
    });

    test('Spanish for Spanish and for any language the app does not have', () {
      expect(resolverIdioma(const [Locale('es', 'PE')]), const Locale('es'));
      expect(resolverIdioma(const [Locale('pt', 'BR')]), const Locale('es'));
      expect(resolverIdioma(const [Locale('qu')]), const Locale('es'));
      expect(resolverIdioma(null), const Locale('es'));
    });

    test('the first preferred language the app has wins', () {
      expect(
        resolverIdioma(const [Locale('fr'), Locale('en'), Locale('es')]),
        const Locale('en'),
      );
    });

    testWidgets('textosDelSistema follows the phone', (tester) async {
      expect(textosDelSistema().localeName, 'es');
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      expect(textosDelSistema().localeName, 'en');
    });
  });

  group('Formato', () {
    final t = DateTime(2026, 9, 23, 14, 5);
    const es = Formato.es;
    const en = Formato('en');

    test('Spanish keeps the prototype formats', () {
      expect(es.hora(t), '14:05');
      expect(es.fechaCorta(t), 'mié 23 sep');
      expect(es.fechaLarga(t), 'miércoles 23 de septiembre');
      expect(es.fechaConAnio(t), '23 sep 2026');
      expect(es.fechaNumerica(t), '23/09/2026');
      expect(es.rangoDias(DateTime(2026, 9, 21), t), '21 – 23 septiembre');
      expect(
        es.rangoDias(DateTime(2026, 8, 31), DateTime(2026, 9, 6)),
        '31 ago – 6 sep',
      );
      expect(
        es.enumerar(['Sala', 'Cocina', 'Pasillo']),
        'Sala, Cocina y Pasillo',
      );
      expect(es.duracion(const Duration(seconds: 125)), '2 min 5 s');
    });

    test('English', () {
      expect(en.hora(t), '2:05\u00a0PM');
      expect(en.fechaCorta(t), 'Wed Sep 23');
      expect(en.fechaLarga(t), 'Wednesday, September 23');
      expect(en.fechaConAnio(t), 'Sep 23, 2026');
      expect(en.fechaNumerica(t), '09/23/2026');
      expect(en.rangoDias(DateTime(2026, 9, 21), t), 'September 21 – 23');
      expect(
        en.rangoDias(DateTime(2026, 8, 31), DateTime(2026, 9, 6)),
        'Aug 31 – Sep 6',
      );
      expect(
        en.enumerar(['Sala', 'Cocina', 'Pasillo']),
        'Sala, Cocina and Pasillo',
      );
    });
  });
}
