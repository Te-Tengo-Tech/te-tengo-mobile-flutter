import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../domain/actividad.dart';

/// `GET /api/actividad` (contract §10, US-33).
abstract interface class ActividadRepositorio {
  /// Newest first; [pcId] keeps the entries of one PC (CA-33.2), [tipo] those of one type.
  Future<PaginaActividad> listar({
    String? pcId,
    String? tipo,
    int pagina = 0,
    int tamano = 50,
  });
}

class ActividadRepositorioApi implements ActividadRepositorio {
  ActividadRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<PaginaActividad> listar({
    String? pcId,
    String? tipo,
    int pagina = 0,
    int tamano = 50,
  }) => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/api/actividad',
      queryParameters: {
        'pcId': ?pcId,
        'tipo': ?tipo,
        'pagina': pagina,
        'tamano': tamano,
      },
    );
    return PaginaActividad.desdeJson(r.data!);
  });
}

final actividadRepositorioProvider = Provider<ActividadRepositorio>(
  (ref) => ActividadRepositorioApi(ref.watch(clienteApiProvider)),
);

/// Loaded pages of the activity log.
class PaginasActividad {
  const PaginasActividad({
    required this.elementos,
    required this.total,
    required this.pagina,
    this.cargandoMas = false,
  });

  final List<Actividad> elementos;
  final int total;
  final int pagina;
  final bool cargandoMas;

  bool get hayMas => elementos.length < total;
}

/// The activity log of the household, or of one PC ([pcId]), loaded page by page.
class ActividadController extends AsyncNotifier<PaginasActividad> {
  ActividadController(this.pcId);

  static const tamano = 50;
  final String? pcId;

  @override
  Future<PaginasActividad> build() async {
    ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
    final p = await ref
        .watch(actividadRepositorioProvider)
        .listar(pcId: pcId, tamano: tamano);
    return PaginasActividad(elementos: p.elementos, total: p.total, pagina: 0);
  }

  Future<void> cargarMas() async {
    final actual = state.value;
    if (actual == null || !actual.hayMas || actual.cargandoMas) return;
    state = AsyncData(
      PaginasActividad(
        elementos: actual.elementos,
        total: actual.total,
        pagina: actual.pagina,
        cargandoMas: true,
      ),
    );
    final siguiente = actual.pagina + 1;
    try {
      final p = await ref
          .read(actividadRepositorioProvider)
          .listar(pcId: pcId, pagina: siguiente, tamano: tamano);
      state = AsyncData(
        PaginasActividad(
          elementos: [...actual.elementos, ...p.elementos],
          total: p.total,
          pagina: siguiente,
        ),
      );
    } on Object {
      state = AsyncData(actual);
    }
  }
}

final actividadProvider = AsyncNotifierProvider.family
    .autoDispose<ActividadController, PaginasActividad, String?>(
      ActividadController.new,
    );

/// The latest change, for «Actividad» in Ajustes («Último cambio: hoy 10:33»).
final ultimaActividadProvider = FutureProvider.autoDispose<Actividad?>((
  ref,
) async {
  ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
  final p = await ref.watch(actividadRepositorioProvider).listar(tamano: 1);
  return p.elementos.firstOrNull;
});
