import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'cache_local.dart';

CacheLocal crearCacheDispositivo() => CacheEnArchivo();

Future<void> cerrarCacheDispositivo(CacheLocal cache) async {
  if (cache is CacheEnArchivo) await cache.cerrar();
}

/// The app database file in the application support folder, opened on first use. Without a
/// file system (tests, a failing plugin) the cache lives in memory.
class CacheEnArchivo implements CacheLocal {
  Future<CacheLocal>? _abierta;

  Future<CacheLocal> _cache() => _abierta ??= () async {
    try {
      final carpeta = await getApplicationSupportDirectory();
      return CacheDrift(
        NativeDatabase.createInBackground(
          File('${carpeta.path}${Platform.pathSeparator}te_tengo.sqlite'),
        ),
      );
    } on Object {
      return CacheMemoria();
    }
  }();

  @override
  Future<String?> leer(String clave) async => (await _cache()).leer(clave);

  @override
  Future<void> guardar(String clave, String valor) async =>
      (await _cache()).guardar(clave, valor);

  @override
  Future<void> vaciar() async => (await _cache()).vaciar();

  Future<void> cerrar() async {
    final cache = await _abierta;
    if (cache is CacheDrift) await cache.cerrar();
  }
}
