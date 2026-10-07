import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Local client database of the architecture («Base de datos local del cliente»): the latest
/// backend answers the app showed, so it can show them again without internet.
/// Prefix of the keys that belong to the phone, not to a household (preferences).
const deDispositivo = 'dispositivo|';

abstract interface class CacheLocal {
  Future<String?> leer(String clave);

  Future<void> guardar(String clave, String valor);

  /// Forgets the household data (sign-out, consent revoked); keeps the keys of this phone that
  /// start with [deDispositivo].
  Future<void> vaciar();
}

class CacheMemoria implements CacheLocal {
  final datos = <String, String>{};

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> guardar(String clave, String valor) async =>
      datos[clave] = valor;

  @override
  Future<void> vaciar() async =>
      datos.removeWhere((k, _) => !k.startsWith(deDispositivo));
}

/// SQLite through drift: one key/value table, written with plain SQL (no code generation).
class CacheDrift implements CacheLocal {
  CacheDrift(QueryExecutor ejecutor) : _db = _BaseCache(ejecutor);

  final _BaseCache _db;

  @override
  Future<String?> leer(String clave) async {
    final filas = await _db
        .customSelect(
          'SELECT valor FROM cache WHERE clave = ?',
          variables: [Variable.withString(clave)],
        )
        .get();
    return filas.firstOrNull?.read<String>('valor');
  }

  @override
  Future<void> guardar(String clave, String valor) => _db.customStatement(
    'INSERT INTO cache (clave, valor, guardado_en) VALUES (?, ?, ?) '
    'ON CONFLICT(clave) DO UPDATE SET valor = excluded.valor, '
    'guardado_en = excluded.guardado_en',
    [clave, valor, DateTime.now().millisecondsSinceEpoch],
  );

  @override
  Future<void> vaciar() => _db.customStatement(
    'DELETE FROM cache WHERE substr(clave, 1, ?) <> ?',
    [deDispositivo.length, deDispositivo],
  );

  Future<void> cerrar() => _db.close();
}

class _BaseCache extends GeneratedDatabase {
  _BaseCache(super.ejecutor);

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => customStatement(
      'CREATE TABLE IF NOT EXISTS cache ('
      'clave TEXT NOT NULL PRIMARY KEY, '
      'valor TEXT NOT NULL, '
      'guardado_en INTEGER NOT NULL)',
    ),
  );
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

final cacheLocalProvider = Provider<CacheLocal>((ref) {
  final cache = CacheEnArchivo();
  ref.onDispose(cache.cerrar);
  return cache;
});
