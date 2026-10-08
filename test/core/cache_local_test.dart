import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/cache/cache_local.dart';

void main() {
  test('drift guarda, reemplaza y vacía', () async {
    final cache = CacheDrift(NativeDatabase.memory());
    addTearDown(cache.cerrar);
    expect(await cache.leer('a'), isNull);
    await cache.guardar('a', '{"x":1}');
    await cache.guardar('a', '{"x":2}');
    await cache.guardar('b', '[]');
    expect(await cache.leer('a'), '{"x":2}');
    await cache.vaciar();
    expect(await cache.leer('b'), isNull);
  });

  group('en el navegador (localStorage)', () {
    test('guarda con prefijo y vacía solo lo del hogar', () async {
      final almacen = _AlmacenMapa()..datos['otra-app'] = 'x';
      final cache = CacheEnAlmacen(almacen);
      await cache.guardar('h1|/api/camaras?', '[]');
      await cache.guardar('${deDispositivo}preferencias', '{}');
      expect(await cache.leer('h1|/api/camaras?'), '[]');
      expect(almacen.datos.keys, contains('tt_cache|h1|/api/camaras?'));
      await cache.vaciar();
      expect(await cache.leer('h1|/api/camaras?'), isNull);
      expect(await cache.leer('${deDispositivo}preferencias'), '{}');
      expect(almacen.datos['otra-app'], 'x');
    });

    test('un almacenamiento lleno solo pierde la caché', () async {
      final cache = CacheEnAlmacen(_AlmacenMapa()..lleno = true);
      await cache.guardar('a', '1');
      expect(await cache.leer('a'), isNull);
    });
  });
}

class _AlmacenMapa implements AlmacenTexto {
  final datos = <String, String>{};
  bool lleno = false;

  @override
  String? leer(String clave) => datos[clave];

  @override
  void escribir(String clave, String valor) {
    if (lleno) throw StateError('QuotaExceededError');
    datos[clave] = valor;
  }

  @override
  void borrar(String clave) => datos.remove(clave);

  @override
  Iterable<String> get claves => datos.keys;
}
