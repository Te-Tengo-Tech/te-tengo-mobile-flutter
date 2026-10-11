import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_local.dart';
import '../../../core/dispositivo/conectividad.dart';
import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../domain/reporte_caida.dart';

/// `POST /api/reportes-de-caida` (contract §11, CA-40.4).
abstract interface class ReportesRepositorio {
  Future<ReporteRecibido> enviar(ReporteCaida reporte);
}

class ReportesRepositorioApi implements ReportesRepositorio {
  ReportesRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<ReporteRecibido> enviar(ReporteCaida reporte) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/reportes-de-caida',
      data: reporte.aJson(),
    );
    return ReporteRecibido.desdeJson(r.data!);
  });
}

final reportesRepositorioProvider = Provider<ReportesRepositorio>(
  (ref) => ReportesRepositorioApi(ref.watch(clienteApiProvider)),
);

/// What happened to a report the family sent.
enum EnvioReporte {
  enviado,

  /// Without internet: kept on the phone and sent when the connection returns («Lo guardamos
  /// para enviarlo»).
  guardado,
}

/// Reports written without internet, kept in the local database until they can be sent. They are
/// household data: signing out forgets them with the rest of the cache.
class ColaReportes {
  ColaReportes(this._cache, this._repositorio, this._conectividad);

  static const clave = 'reportesDeCaidaPendientes';

  final CacheLocal _cache;
  final ReportesRepositorio _repositorio;
  final Conectividad _conectividad;
  Future<int>? _enviando;

  Future<List<ReporteCaida>> pendientes() async {
    final texto = await _cache.leer(clave);
    if (texto == null) return const [];
    try {
      return [
        for (final r in jsonDecode(texto) as List<dynamic>)
          ReporteCaida.desdeJson(r as Map<String, dynamic>),
      ];
    } on Object {
      return const [];
    }
  }

  Future<void> _escribir(List<ReporteCaida> reportes) =>
      _cache.guardar(clave, jsonEncode([for (final r in reportes) r.aJson()]));

  /// Sends [reporte] now or, without internet, keeps it for later.
  Future<EnvioReporte> enviar(ReporteCaida reporte) async {
    if (!await _conectividad.conectado()) return _guardar(reporte);
    try {
      await _repositorio.enviar(reporte);
      return EnvioReporte.enviado;
    } on ProblemaApi catch (e) {
      if (e.codigo != ProblemaApi.sinConexion) rethrow;
      return _guardar(reporte);
    }
  }

  Future<EnvioReporte> _guardar(ReporteCaida reporte) async {
    await _escribir([...await pendientes(), reporte]);
    return EnvioReporte.guardado;
  }

  /// Sends the kept reports in order; stops at the first one that still cannot go (no connection,
  /// session to renew, server error). One the backend rejects as invalid (`400 VALIDACION`, or
  /// `404 CAMARA_NO_ENCONTRADA` after the camera was removed), which retrying will not fix, is
  /// dropped. Returns how many it sent.
  Future<int> enviarPendientes() =>
      _enviando ??= _enviarPendientes().whenComplete(() => _enviando = null);

  Future<int> _enviarPendientes() async {
    final cola = [...await pendientes()];
    if (cola.isEmpty) return 0;
    var enviados = 0;
    while (cola.isNotEmpty) {
      try {
        await _repositorio.enviar(cola.first);
        enviados++;
      } on ProblemaApi catch (e) {
        if (!const {400, 404, 422}.contains(e.estado)) break;
      }
      cola.removeAt(0);
      await _escribir(cola);
    }
    return enviados;
  }
}

final colaReportesProvider = Provider<ColaReportes>(
  (ref) => ColaReportes(
    ref.watch(cacheLocalProvider),
    ref.watch(reportesRepositorioProvider),
    ref.watch(conectividadProvider),
  ),
);
