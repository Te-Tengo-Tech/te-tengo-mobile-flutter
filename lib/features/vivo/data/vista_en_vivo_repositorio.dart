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
  /// Without [modo] the camera keeps the mode it streams in. [mosaicoId]: the «Ver todas» opening
  /// it belongs to (US-41), so the access log shows one entry.
  Future<SesionVivo> abrir(
    String camaraId, {
    String? alertaId,
    ModoVista? modo,
    String? mosaicoId,
  });

  /// «Ver todas» opened (CA-41.6): the id its sessions share. Null from an API without it (older
  /// than US-41): each camera is then its own access.
  Future<String?> abrirMosaico();

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
    String? mosaicoId,
  }) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/api/camaras/$camaraId/vista-en-vivo',
        data: {
          'alertaId': alertaId,
          'modo': ?modo?.codigo,
          'mosaicoId': ?mosaicoId,
        },
      );
      return SesionVivo.desdeJson(respuesta.data!);
    } on DioException catch (e) {
      throw ProblemaApi.desde(e);
    }
  }

  @override
  Future<String?> abrirMosaico() async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/api/vista-en-vivo/mosaicos',
      );
      return respuesta.data?['mosaicoId'] as String?;
    } on DioException catch (e) {
      final estado = e.response?.statusCode;
      // An API older than US-41 has no such route.
      if (estado == 404 || estado == 405) return null;
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
