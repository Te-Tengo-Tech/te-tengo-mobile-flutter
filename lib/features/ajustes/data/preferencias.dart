import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final almacenPreferenciasProvider = Provider<AlmacenPreferencias>(
  (ref) => AlmacenPreferenciasMemoria(),
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
