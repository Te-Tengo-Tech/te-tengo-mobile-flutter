import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';

/// Endpoints of the contract the app does not need, with the reason.
const _sinUso = {
  // The household (`GET /api/hogar`) already carries the consent.
  'GET /api/hogar/consentimiento',
};

/// Every endpoint of docs/API_CONTRACT.md is called by the app with its method and path.
void main() {
  final contrato = File('docs/API_CONTRACT.md').readAsStringSync();
  final codigo = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map((f) => f.readAsStringSync())
      .join('\n');
  final endpoints = RegExp(
    r'`(GET|POST|PUT|PATCH|DELETE) (/api/[^`\s?]+)',
  ).allMatches(contrato).map((m) => (m.group(1)!, m.group(2)!)).toSet();

  test('el contrato tiene endpoints', () => expect(endpoints, hasLength(36)));

  for (final (metodo, ruta) in endpoints) {
    final nombre = '$metodo $ruta';
    if (_sinUso.contains(nombre)) continue;
    test(nombre, () {
      // `{id}` becomes a Dart interpolation: `$camaraId` or `${Uri.encodeComponent(token)}`.
      final patron = RegExp.escape(ruta).replaceAllMapped(
        RegExp(r'\\\{[^}]+\\\}|\{[^}]+\}'),
        (_) => r'\$(\{[^}]+\}|\w+)',
      );
      final enCodigo = RegExp("'$patron'").hasMatch(codigo);
      expect(enCodigo, isTrue, reason: 'No se usa $ruta');
      // The method is the call that sends that path: `.get(`, `.post(`, `.delete<`…
      final llamada = RegExp(
        '\\.${metodo.toLowerCase()}(Uri)?(<[^(]*>)?\\(\\s*\'$patron\'',
      );
      final metodoInterceptor = ruta == '/api/sesiones/refresco';
      expect(
        llamada.hasMatch(codigo) || metodoInterceptor,
        isTrue,
        reason: '$ruta no se llama con $metodo',
      );
    });
  }

  test('cada tipo de push del contrato se reconoce', () {
    final inicio = contrato.indexOf('## 7. Push notifications');
    final fin = contrato.indexOf('\n## ', inicio + 1);
    final seccion = contrato.substring(inicio, fin < 0 ? null : fin);
    // First cell of each row of the push table: `ALERTA_ESCALADA` / `SIN_CONTACTO_SECUNDARIO`.
    final tipos = {
      for (final fila in seccion.split('\n').where((l) => l.startsWith('| `')))
        for (final m in RegExp('`([A-Z_]+)`').allMatches(fila.split('|')[1]))
          m.group(1)!,
    };
    expect(tipos, isNotEmpty);
    expect(TipoPush.values.map((t) => t.codigo).toSet(), tipos);
  });
}
