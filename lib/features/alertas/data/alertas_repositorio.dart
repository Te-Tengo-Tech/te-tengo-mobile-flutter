import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../domain/alerta.dart';

/// Filters of `GET /api/alertas` (CA-25.2).
class FiltroAlertas {
  const FiltroAlertas({
    this.tipo,
    this.estado,
    this.desde,
    this.hasta,
    this.pagina = 0,
    this.tamano = 50,
  });

  final TipoAlerta? tipo;
  final EstadoAlerta? estado;
  final DateTime? desde;
  final DateTime? hasta;

  /// Zero-based page (docs/BLOCKERS.md).
  final int pagina;
  final int tamano;

  Map<String, Object> get consulta => {
    'tipo': ?tipo?.codigo,
    'estado': ?estado?.codigo,
    'desde': ?desde?.toUtc().toIso8601String(),
    'hasta': ?hasta?.toUtc().toIso8601String(),
    'pagina': pagina,
    'tamano': tamano,
  };

  @override
  bool operator ==(Object other) =>
      other is FiltroAlertas &&
      other.tipo == tipo &&
      other.estado == estado &&
      other.desde == desde &&
      other.hasta == hasta &&
      other.pagina == pagina &&
      other.tamano == tamano;

  @override
  int get hashCode => Object.hash(tipo, estado, desde, hasta, pagina, tamano);
}

/// Alerts and clips (contract §5).
abstract interface class AlertasRepositorio {
  /// `GET /api/alertas`, newest first (CA-25.1).
  Future<PaginaAlertas> listar(FiltroAlertas filtro);

  /// `GET /api/alertas/{id}`. Errors: `404 ALERTA_NO_ENCONTRADA`.
  Future<Alerta> obtener(String id);

  /// `GET /api/alertas/{id}/clip`: a short-lived URL of the 12 s clip (CA-18.1, CA-26.1); with
  /// [descarga], the download disposition (CA-26.2). Errors: `404 CLIP_NO_DISPONIBLE` (CA-18.2),
  /// `410 CLIP_ELIMINADO` (CA-26.3).
  Future<EnlaceClip> clip(String id, {bool descarga = false});
}

class AlertasRepositorioApi implements AlertasRepositorio {
  AlertasRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<PaginaAlertas> listar(FiltroAlertas filtro) => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/api/alertas',
      queryParameters: filtro.consulta,
    );
    return PaginaAlertas.desdeJson(r.data!);
  });

  @override
  Future<Alerta> obtener(String id) => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>('/api/alertas/$id');
    return Alerta.desdeJson(r.data!);
  });

  @override
  Future<EnlaceClip> clip(String id, {bool descarga = false}) =>
      llamarApi(() async {
        final r = await _dio.get<Map<String, dynamic>>(
          '/api/alertas/$id/clip',
          queryParameters: {if (descarga) 'descarga': true},
        );
        return EnlaceClip.desdeJson(r.data!);
      });
}

final alertasRepositorioProvider = Provider<AlertasRepositorio>(
  (ref) => AlertasRepositorioApi(ref.watch(clienteApiProvider)),
);

/// Clip URL of an alert; a missing or deleted clip is reported as its state.
final clipProvider = FutureProvider.family<ResultadoClip, String>((
  ref,
  id,
) async {
  try {
    return ResultadoClip(
      EstadoClip.disponible,
      await ref.watch(alertasRepositorioProvider).clip(id),
    );
  } on ProblemaApi catch (e) {
    if (e.codigo == 'CLIP_NO_DISPONIBLE') {
      return const ResultadoClip(EstadoClip.noDisponible);
    }
    if (e.codigo == 'CLIP_ELIMINADO') {
      return const ResultadoClip(EstadoClip.eliminado);
    }
    rethrow;
  }
});

final alertaProvider = FutureProvider.family<Alerta, String>(
  (ref, id) => ref.watch(alertasRepositorioProvider).obtener(id),
);

/// The newest active alert, visible when the app opens even if the push failed (CA-16.4).
final alertaActivaProvider = FutureProvider<Alerta?>((ref) async {
  final sesion = ref.watch(sesionControllerProvider);
  if (sesion == null || !sesion.tieneHogar) return null;
  final pagina = await ref
      .watch(alertasRepositorioProvider)
      .listar(const FiltroAlertas(estado: EstadoAlerta.activa, tamano: 1));
  return pagina.elementos.firstOrNull;
});
