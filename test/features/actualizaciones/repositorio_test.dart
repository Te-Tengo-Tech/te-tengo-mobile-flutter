import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/actualizaciones/data/versiones_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';

void main() {
  late AdaptadorFalso http;
  late VersionesRepositorio repo;

  setUp(() {
    http = AdaptadorFalso();
    final contenedor = ProviderContainer(
      overrides: [adaptadorHttpProvider.overrideWithValue(http)],
    );
    addTearDown(contenedor.dispose);
    repo = contenedor.read(versionesRepositorioProvider);
  });

  test('GET /api/versiones, público y sin token', () async {
    http.cuando(
      'GET',
      '/api/versiones',
      const Respuesta(200, {
        'windows': {'version': '0.5.0', 'notas': []},
        'mac': null,
        'apk': {
          'version': '0.6.0',
          'versionMinima': '0.4.0',
          'url': 'https://tetengo.example/te-tengo.apk',
          'sha256': 'ab',
          'tamanoBytes': 8400000,
          'publicadaEn': '2026-10-10T15:00:00Z',
          'notas': ['Las alertas llegan más rápido.'],
        },
        'play': null,
        'ios': null,
        'pwa': {'version': '0.6.0', 'notas': []},
        'paginaDescargas': null,
      }),
    );
    final v = await repo.leer();
    expect(v!.apk!.version, '0.6.0');
    expect(v.apk!.versionMinima, '0.4.0');
    expect(v.apk!.notas, ['Las alertas llegan más rápido.']);
    expect(v.play, isNull);
    final pedido = http.hechas('GET', '/api/versiones').single;
    expect(pedido.headers.containsKey('Authorization'), isFalse);
    expect(pedido.headers['Api-Version'], '1');
  });

  test('un backend anterior (404) no da información', () async {
    http.cuando(
      'GET',
      '/api/versiones',
      Respuesta.problema(404, 'NO_ENCONTRADO'),
    );
    expect(await repo.leer(), isNull);
  });

  test('sin conexión es SIN_CONEXION', () async {
    http.sinConexion = true;
    await expectLater(
      repo.leer(),
      throwsA(
        isA<ProblemaApi>().having(
          (p) => p.codigo,
          'codigo',
          ProblemaApi.sinConexion,
        ),
      ),
    );
  });
}
