import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';
import '../domain/filtro_historial.dart';

/// Applied history filter.
class FiltroHistorialController extends Notifier<FiltroHistorial> {
  @override
  FiltroHistorial build() => FiltroHistorial.vacio;

  void aplicar(FiltroHistorial filtro) => state = filtro;
}

final filtroHistorialProvider =
    NotifierProvider<FiltroHistorialController, FiltroHistorial>(
      FiltroHistorialController.new,
    );

/// Loaded pages of the history.
class PaginasHistorial {
  const PaginasHistorial({
    required this.alertas,
    required this.total,
    required this.pagina,
    this.cargandoMas = false,
  });

  final List<Alerta> alertas;
  final int total;
  final int pagina;
  final bool cargandoMas;

  bool get hayMas => alertas.length < total;
}

/// Alerts of the history, newest first (CA-25.1), filtered (CA-25.2), loaded page by page.
class HistorialController extends AsyncNotifier<PaginasHistorial> {
  static const tamano = 50;

  @override
  Future<PaginasHistorial> build() async {
    ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
    final filtro = ref.watch(filtroHistorialProvider);
    final p = await ref
        .watch(alertasRepositorioProvider)
        .listar(filtro.aConsulta(ref.read(relojProvider)(), tamano: tamano));
    return PaginasHistorial(alertas: p.elementos, total: p.total, pagina: 0);
  }

  Future<void> cargarMas() async {
    final actual = state.value;
    if (actual == null || !actual.hayMas || actual.cargandoMas) return;
    state = AsyncData(
      PaginasHistorial(
        alertas: actual.alertas,
        total: actual.total,
        pagina: actual.pagina,
        cargandoMas: true,
      ),
    );
    final filtro = ref.read(filtroHistorialProvider);
    final siguiente = actual.pagina + 1;
    try {
      final p = await ref
          .read(alertasRepositorioProvider)
          .listar(
            filtro.aConsulta(
              ref.read(relojProvider)(),
              pagina: siguiente,
              tamano: tamano,
            ),
          );
      state = AsyncData(
        PaginasHistorial(
          alertas: [...actual.alertas, ...p.elementos],
          total: p.total,
          pagina: siguiente,
        ),
      );
    } on Object {
      state = AsyncData(actual);
    }
  }
}

final historialProvider =
    AsyncNotifierProvider<HistorialController, PaginasHistorial>(
      HistorialController.new,
    );

/// How many alerts a draft filter would show («Ver 3 alertas»).
final conteoFiltroProvider = FutureProvider.family<int, FiltroHistorial>((
  ref,
  filtro,
) async {
  final p = await ref
      .watch(alertasRepositorioProvider)
      .listar(filtro.aConsulta(ref.read(relojProvider)(), tamano: 1));
  return p.total;
});
