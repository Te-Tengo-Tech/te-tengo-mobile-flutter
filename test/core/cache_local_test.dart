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
}
