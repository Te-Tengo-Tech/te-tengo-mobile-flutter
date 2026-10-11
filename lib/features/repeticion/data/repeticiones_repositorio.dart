import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../domain/repeticion.dart';

/// Replays of the stored movements (contract §11, US-39).
abstract interface class RepeticionesRepositorio {
  /// `POST /api/camaras/{id}/repeticiones` (at most 1 h; logged, CA-39.3). Errors:
  /// `409 SIN_CONSENTIMIENTO_DE_MOVIMIENTOS` (CA-39.4), `404 CAMARA_NO_ENCONTRADA`.
  Future<Repeticion> crear(String camaraId, DateTime desde, DateTime hasta);

  /// `GET /api/repeticiones/{id}/archivos`: the files of another stretch of the same replay.
  Future<Repeticion> archivos(String id, DateTime desde, DateTime hasta);

  /// `DELETE /api/repeticiones/{id}`: closed, its duration is recorded.
  Future<void> cerrar(String id);

  /// `GET /api/accesos-repeticiones`, newest first.
  Future<List<AccesoRepeticion>> accesos();
}

class RepeticionesRepositorioApi implements RepeticionesRepositorio {
  RepeticionesRepositorioApi(this._dio);

  final Dio _dio;

  static String _iso(DateTime t) => t.toUtc().toIso8601String();

  @override
  Future<Repeticion> crear(String camaraId, DateTime desde, DateTime hasta) =>
      llamarApi(() async {
        final r = await _dio.post<Map<String, dynamic>>(
          '/api/camaras/$camaraId/repeticiones',
          data: {'desde': _iso(desde), 'hasta': _iso(hasta)},
        );
        return Repeticion.desdeJson(r.data!);
      });

  @override
  Future<Repeticion> archivos(String id, DateTime desde, DateTime hasta) =>
      llamarApi(() async {
        final r = await _dio.get<Map<String, dynamic>>(
          '/api/repeticiones/$id/archivos',
          queryParameters: {'desde': _iso(desde), 'hasta': _iso(hasta)},
        );
        return Repeticion.desdeJson(r.data!);
      });

  @override
  Future<void> cerrar(String id) =>
      llamarApi(() => _dio.delete<void>('/api/repeticiones/$id'));

  @override
  Future<List<AccesoRepeticion>> accesos() => llamarApi(() async {
    final r = await _dio.get<List<dynamic>>('/api/accesos-repeticiones');
    return [
      for (final j in r.data ?? const [])
        AccesoRepeticion.desdeJson(j as Map<String, dynamic>),
    ];
  });
}

final repeticionesRepositorioProvider = Provider<RepeticionesRepositorio>(
  (ref) => RepeticionesRepositorioApi(ref.watch(clienteApiProvider)),
);

final accesosRepeticionesProvider = FutureProvider<List<AccesoRepeticion>>(
  (ref) => ref.watch(repeticionesRepositorioProvider).accesos(),
);
