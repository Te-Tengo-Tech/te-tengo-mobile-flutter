import 'package:web/web.dart' as web;

import 'cache_local.dart';

CacheLocal crearCacheDispositivo() =>
    CacheEnAlmacen(const _AlmacenLocalStorage());

Future<void> cerrarCacheDispositivo(CacheLocal cache) async {}

/// The browser's `localStorage` (about 5 MB per origin, enough for the JSON answers).
class _AlmacenLocalStorage implements AlmacenTexto {
  const _AlmacenLocalStorage();

  web.Storage get _local => web.window.localStorage;

  @override
  String? leer(String clave) => _local.getItem(clave);

  @override
  void escribir(String clave, String valor) => _local.setItem(clave, valor);

  @override
  void borrar(String clave) => _local.removeItem(clave);

  @override
  Iterable<String> get claves => [
    for (var i = 0; i < _local.length; i++) ?_local.key(i),
  ];
}
