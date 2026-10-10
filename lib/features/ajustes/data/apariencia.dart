import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';

/// Light or dark on this phone (or this browser): a device setting, not an account one, so it is
/// not sent to the backend and survives signing out.
enum Apariencia {
  /// Follows the phone's (or the browser's) theme, as the prototype does. The default.
  automatica('Automático', ThemeMode.system),
  clara('Claro', ThemeMode.light),
  oscura('Oscuro', ThemeMode.dark);

  const Apariencia(this.texto, this.modo);

  final String texto;
  final ThemeMode modo;

  /// The stored name; anything unknown (an old or corrupt value) is [automatica].
  static Apariencia desdeNombre(String? nombre) => Apariencia.values.firstWhere(
    (a) => a.name == nombre,
    orElse: () => Apariencia.automatica,
  );
}

/// Where the appearance of this phone is kept.
abstract interface class AlmacenApariencia {
  Future<Apariencia> cargar();

  Future<void> guardar(Apariencia apariencia);
}

class AlmacenAparienciaMemoria implements AlmacenApariencia {
  AlmacenAparienciaMemoria([this.actual = Apariencia.automatica]);

  Apariencia actual;

  @override
  Future<Apariencia> cargar() async => actual;

  @override
  Future<void> guardar(Apariencia apariencia) async => actual = apariencia;
}

/// Kept in the local database (drift's SQLite on Android and iOS, `localStorage` in the browser)
/// under a phone key, so signing out or revoking the consent (`CacheLocal.vaciar`) does not reset it.
class AlmacenAparienciaLocal implements AlmacenApariencia {
  AlmacenAparienciaLocal(this._cache);

  final CacheLocal _cache;
  static const clave = '${deDispositivo}apariencia';

  @override
  Future<Apariencia> cargar() async {
    try {
      return Apariencia.desdeNombre(await _cache.leer(clave));
    } on Object {
      return Apariencia.automatica;
    }
  }

  @override
  Future<void> guardar(Apariencia apariencia) =>
      _cache.guardar(clave, apariencia.name);
}

/// Reads the stored appearance before the first frame (`main()`), so the app never paints the
/// other theme first. A database that does not answer in [espera] gives [Apariencia.automatica]:
/// startup is never held up by a preference.
Future<Apariencia> cargarApariencia(
  CacheLocal cache, {
  Duration espera = const Duration(seconds: 2),
}) => AlmacenAparienciaLocal(
  cache,
).cargar().timeout(espera, onTimeout: () => Apariencia.automatica);

final almacenAparienciaProvider = Provider<AlmacenApariencia>(
  (ref) => AlmacenAparienciaLocal(ref.watch(cacheLocalProvider)),
);

/// The appearance read in `main()`; overridden there. Tests and a fresh install start automatic.
final aparienciaInicialProvider = Provider<Apariencia>(
  (ref) => Apariencia.automatica,
);

/// Synchronous, so `MaterialApp.themeMode` has its value on the first frame.
class AparienciaController extends Notifier<Apariencia> {
  @override
  Apariencia build() => ref.watch(aparienciaInicialProvider);

  /// Applies [apariencia] at once and keeps it on this phone. A storage that fails only loses it
  /// on the next launch.
  Future<void> elegir(Apariencia apariencia) async {
    state = apariencia;
    try {
      await ref.read(almacenAparienciaProvider).guardar(apariencia);
    } on Object {
      // Storage full or blocked: the choice still applies until the app closes.
    }
  }
}

final aparienciaProvider = NotifierProvider<AparienciaController, Apariencia>(
  AparienciaController.new,
);
