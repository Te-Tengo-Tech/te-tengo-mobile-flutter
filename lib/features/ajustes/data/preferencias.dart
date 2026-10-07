import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';

/// What this phone is told about (screen 96). Falls and camera state are always on.
class PreferenciasNotificaciones {
  const PreferenciasNotificaciones({
    this.inestables = true,
    this.finPausa = true,
  });

  final bool inestables;
  final bool finPausa;

  PreferenciasNotificaciones con({bool? inestables, bool? finPausa}) =>
      PreferenciasNotificaciones(
        inestables: inestables ?? this.inestables,
        finPausa: finPausa ?? this.finPausa,
      );
}

/// Where the preferences of this phone are kept. The contract has no endpoint for them
/// (docs/BLOCKERS.md), so they stay on the device.
abstract interface class AlmacenPreferencias {
  Future<PreferenciasNotificaciones> cargar();

  Future<void> guardar(PreferenciasNotificaciones preferencias);
}

class AlmacenPreferenciasMemoria implements AlmacenPreferencias {
  AlmacenPreferenciasMemoria([
    this._actual = const PreferenciasNotificaciones(),
  ]);

  PreferenciasNotificaciones _actual;

  @override
  Future<PreferenciasNotificaciones> cargar() async => _actual;

  @override
  Future<void> guardar(PreferenciasNotificaciones preferencias) async =>
      _actual = preferencias;
}

/// Kept in the local database under a phone key, so signing out does not reset them.
class AlmacenPreferenciasLocal implements AlmacenPreferencias {
  AlmacenPreferenciasLocal(this._cache);

  final CacheLocal _cache;
  static const _clave = '${deDispositivo}preferencias';

  @override
  Future<PreferenciasNotificaciones> cargar() async {
    try {
      final guardado = await _cache.leer(_clave);
      if (guardado == null) return const PreferenciasNotificaciones();
      final json = jsonDecode(guardado) as Map<String, dynamic>;
      return PreferenciasNotificaciones(
        inestables: json['inestables'] as bool? ?? true,
        finPausa: json['finPausa'] as bool? ?? true,
      );
    } on Object {
      return const PreferenciasNotificaciones();
    }
  }

  @override
  Future<void> guardar(PreferenciasNotificaciones p) => _cache.guardar(
    _clave,
    jsonEncode({'inestables': p.inestables, 'finPausa': p.finPausa}),
  );
}

final almacenPreferenciasProvider = Provider<AlmacenPreferencias>(
  (ref) => AlmacenPreferenciasLocal(ref.watch(cacheLocalProvider)),
);

class PreferenciasController extends AsyncNotifier<PreferenciasNotificaciones> {
  @override
  Future<PreferenciasNotificaciones> build() =>
      ref.watch(almacenPreferenciasProvider).cargar();

  Future<void> cambiar(PreferenciasNotificaciones nuevas) async {
    state = AsyncData(nuevas);
    await ref.read(almacenPreferenciasProvider).guardar(nuevas);
  }
}

final preferenciasProvider =
    AsyncNotifierProvider<PreferenciasController, PreferenciasNotificaciones>(
      PreferenciasController.new,
    );
