import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../domain/vista_en_vivo.dart';

/// Live view sessions of the household cameras (US-23).
abstract interface class VistaEnVivoRepositorio {
  /// Asks the camera's household agent to get ready for a live view (`204`): it warms what stays on
  /// the PC, and no image leaves it until a session opens. Same rules as [abrir].
  Future<void> preparar(String camaraId);

  /// Opens a session; `409 CAMARA_DESCONECTADA` or `409 CAMARA_EN_PAUSA` when unavailable.
  /// Without [modo] the camera keeps the mode it streams in.
  Future<SesionVivo> abrir(
    String camaraId, {
    String? alertaId,
    ModoVista? modo,
  });

  /// Changes what the camera's stream shows, for every viewer; returns the mode now in effect.
  Future<ModoVista> cambiarModo(String sesionId, ModoVista modo);

  /// Closes it; the backend records who watched, when and for how long (CA-24.1).
  Future<void> cerrar(String sesionId);

  /// Who watched, when and for how long, newest first (CA-24.2).
  Future<List<AccesoVivo>> accesos();
}

class VistaEnVivoRepositorioApi implements VistaEnVivoRepositorio {
  VistaEnVivoRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<void> preparar(String camaraId) async {
    try {
      await _dio.post<void>(
        '/api/vista-en-vivo/preparar',
        data: {'camaraId': camaraId},
      );
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<SesionVivo> abrir(
    String camaraId, {
    String? alertaId,
    ModoVista? modo,
  }) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/api/camaras/$camaraId/vista-en-vivo',
        data: {'alertaId': alertaId, 'modo': ?modo?.codigo},
      );
      return SesionVivo.desdeJson(respuesta.data!);
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<ModoVista> cambiarModo(String sesionId, ModoVista modo) async {
    try {
      final respuesta = await _dio.patch<Map<String, dynamic>>(
        '/api/vista-en-vivo/$sesionId',
        data: {'modo': modo.codigo},
      );
      return ModoVista.desdeCodigo(respuesta.data?['modo']);
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<void> cerrar(String sesionId) async {
    try {
      await _dio.delete<void>('/api/vista-en-vivo/$sesionId');
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<List<AccesoVivo>> accesos() async {
    try {
      final respuesta = await _dio.get<List<dynamic>>(
        '/api/accesos-vista-en-vivo',
      );
      return (respuesta.data ?? [])
          .map((j) => AccesoVivo.desdeJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }
}

final vistaEnVivoRepositorioProvider = Provider<VistaEnVivoRepositorio>(
  (ref) => VistaEnVivoRepositorioApi(ref.watch(clienteApiProvider)),
);

/// Sends [VistaEnVivoRepositorio.preparar] for a screen the live view is likely opened from. Only
/// a head start: an old API or agent, a paused camera or no connection change nothing, so errors
/// are ignored.
void prepararVivo(WidgetRef ref, String camaraId) => unawaited(
  ref
      .read(vistaEnVivoRepositorioProvider)
      .preparar(camaraId)
      .catchError((Object _) {}),
);

final accesosVivoProvider = FutureProvider<List<AccesoVivo>>(
  (ref) => ref.watch(vistaEnVivoRepositorioProvider).accesos(),
);
