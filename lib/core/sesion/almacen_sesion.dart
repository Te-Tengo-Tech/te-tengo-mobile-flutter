import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'sesion.dart';

/// Where the session lives between launches. [actual] is cached in memory, so requests do not read
/// the secure storage every time.
abstract interface class AlmacenSesion {
  Sesion? get actual;

  Future<Sesion?> cargar();

  Future<void> guardar(Sesion sesion);

  Future<void> borrar();
}

/// Session in the operating system secure storage (Keychain / Keystore).
class AlmacenSesionSeguro implements AlmacenSesion {
  AlmacenSesionSeguro([this._almacen = const FlutterSecureStorage()]);

  static const _clave = 'tt_sesion';
  final FlutterSecureStorage _almacen;
  Sesion? _actual;

  @override
  Sesion? get actual => _actual;

  @override
  Future<Sesion?> cargar() async {
    try {
      final texto = await _almacen.read(key: _clave);
      _actual = texto == null
          ? null
          : Sesion.desdeJson(jsonDecode(texto) as Map<String, dynamic>);
    } on Object {
      // Unreadable or old data: start signed out.
      _actual = null;
    }
    return _actual;
  }

  @override
  Future<void> guardar(Sesion sesion) async {
    _actual = sesion;
    await _almacen.write(key: _clave, value: jsonEncode(sesion.aJson()));
  }

  @override
  Future<void> borrar() async {
    _actual = null;
    await _almacen.delete(key: _clave);
  }
}

/// In-memory session, for tests.
class AlmacenSesionMemoria implements AlmacenSesion {
  AlmacenSesionMemoria([this._actual]);

  Sesion? _actual;

  @override
  Sesion? get actual => _actual;

  @override
  Future<Sesion?> cargar() async => _actual;

  @override
  Future<void> guardar(Sesion sesion) async => _actual = sesion;

  @override
  Future<void> borrar() async => _actual = null;
}

/// Overridden in `main()` with the store already loaded.
final almacenSesionProvider = Provider<AlmacenSesion>(
  (ref) => AlmacenSesionMemoria(),
);
