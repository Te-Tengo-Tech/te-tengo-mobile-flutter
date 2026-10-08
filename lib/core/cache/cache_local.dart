import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache_dispositivo.dart';

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

/// Key/value text storage that survives restarts: the browser's `localStorage` in the PWA.
abstract interface class AlmacenTexto {
  String? leer(String clave);

  void escribir(String clave, String valor);

  void borrar(String clave);

  Iterable<String> get claves;
}

/// The cache over an [AlmacenTexto] (the web app, where drift's SQLite file is not available). A
/// full storage only loses the cache: every failure is ignored.
class CacheEnAlmacen implements CacheLocal {
  CacheEnAlmacen(this._almacen);

  static const prefijo = 'tt_cache|';
  final AlmacenTexto _almacen;

  @override
  Future<String?> leer(String clave) async {
    try {
      return _almacen.leer('$prefijo$clave');
    } on Object {
      return null;
    }
  }

  @override
  Future<void> guardar(String clave, String valor) async {
    try {
      _almacen.escribir('$prefijo$clave', valor);
    } on Object {
      // Quota exceeded or storage blocked: the answer is simply not kept.
    }
  }

  @override
  Future<void> vaciar() async {
    try {
      final hogar = _almacen.claves
          .where(
            (c) =>
                c.startsWith(prefijo) &&
                !c.startsWith('$prefijo$deDispositivo'),
          )
          .toList();
      hogar.forEach(_almacen.borrar);
    } on Object {
      // Storage blocked: there is nothing to forget.
    }
  }
}

/// SQLite on Android and iOS, `localStorage` on the web.
final cacheLocalProvider = Provider<CacheLocal>((ref) {
  final cache = crearCacheDispositivo();
  ref.onDispose(() => cerrarCacheDispositivo(cache));
  return cache;
});
