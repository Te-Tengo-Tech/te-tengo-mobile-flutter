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
}

final alertasRepositorioProvider = Provider<AlertasRepositorio>(
  (ref) => AlertasRepositorioApi(ref.watch(clienteApiProvider)),
);

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
