import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';

/// «Aumentar el contraste» on this phone (or this browser): a device setting, like the appearance,
/// so it is not sent to the backend and survives signing out. Off by default; the phone's own
/// accessibility setting also turns it on (`MaterialApp.highContrastTheme`).
abstract interface class AlmacenContraste {
  Future<bool> cargar();

  Future<void> guardar(bool activo);
}

class AlmacenContrasteMemoria implements AlmacenContraste {
  AlmacenContrasteMemoria([this.activo = false]);

  bool activo;

  @override
  Future<bool> cargar() async => activo;

  @override
  Future<void> guardar(bool activo) async => this.activo = activo;
}

/// Kept in the local database under a phone key, like the appearance (`CacheLocal.vaciar` keeps it).
class AlmacenContrasteLocal implements AlmacenContraste {
  AlmacenContrasteLocal(this._cache);

  final CacheLocal _cache;
  static const clave = '${deDispositivo}contraste';

  @override
  Future<bool> cargar() async {
    try {
      return await _cache.leer(clave) == 'si';
    } on Object {
      return false;
    }
  }

  @override
  Future<void> guardar(bool activo) =>
      _cache.guardar(clave, activo ? 'si' : 'no');
}

/// Read in `main()` before the first frame, with the appearance; a database that does not answer
/// in [espera] leaves it off.
Future<bool> cargarContraste(
  CacheLocal cache, {
  Duration espera = const Duration(seconds: 2),
}) => AlmacenContrasteLocal(
  cache,
).cargar().timeout(espera, onTimeout: () => false);

final almacenContrasteProvider = Provider<AlmacenContraste>(
  (ref) => AlmacenContrasteLocal(ref.watch(cacheLocalProvider)),
);

/// The value read in `main()`; overridden there. Tests and a fresh install start without it.
final contrasteInicialProvider = Provider<bool>((ref) => false);

/// Synchronous, so the first frame already has the right theme.
class ContrasteController extends Notifier<bool> {
  @override
  bool build() => ref.watch(contrasteInicialProvider);

  /// Applies it at once and keeps it on this phone; a storage that fails only loses it on the next
  /// launch.
  Future<void> cambiar(bool activo) async {
    state = activo;
    try {
      await ref.read(almacenContrasteProvider).guardar(activo);
    } on Object {
      // Storage full or blocked: the choice still applies until the app closes.
    }
  }
}

final contrasteProvider = NotifierProvider<ContrasteController, bool>(
  ContrasteController.new,
);
