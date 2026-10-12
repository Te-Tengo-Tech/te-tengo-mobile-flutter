import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../camaras/data/orden_camaras.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../vivo/domain/vista_en_vivo.dart';
import '../domain/camara_detectada.dart';
import '../domain/camaras_en_casa.dart';
import '../domain/pc.dart';

/// The household's PCs, their link and their webcams (contract §9, US-28 to US-31).
abstract interface class PcsRepositorio {
  /// The linked PCs, oldest first, each with its cameras in use (CA-30.2).
  Future<List<Pc>> listar();

  /// What the approval screen shows for a code (CA-28.4). Owner only.
  Future<ConsultaPc> consultar(String codigo);

  /// Links the PC of [codigo] to the household (CA-28.1, CA-30.1).
  Future<Pc> aprobar(String codigo);

  /// «No reconozco esta PC»: the PC is not linked (CA-28.4).
  Future<void> rechazar(String codigo);

  /// «Quitar esta PC» (CA-31.1, CA-31.2): the app stops showing it and its cameras at once; the PC
  /// stops capturing and shows its QR again as soon as it connects. No push is sent for it.
  Future<void> quitar(String pcId);

  /// Every webcam the PC reported, in use or «sin usar» (CA-29.1).
  Future<List<CamaraDetectada>> camaras(String pcId);

  /// «Buscar de nuevo»: the PC looks for its webcams again (CA-29.6).
  Future<void> buscarCamaras(String pcId);

  /// «Usar esta cámara»: the webcam watches the room [ambienteId], or a new room called
  /// [nombreAmbiente] (CA-29.2, CA-29.3).
  Future<Camara> usarCamara(
    String camaraId, {
    String? ambienteId,
    String? nombreAmbiente,
  });

  /// «Dejar de usar»: the camera stops detecting and its room is free (CA-29.2).
  Future<void> dejarDeUsar(String camaraId);

  /// The household's rooms, each with its camera in use: the chips of «¿En qué habitación está?».
  Future<List<Ambiente>> ambientes();

  /// A short live view of a webcam to recognise it (CA-29.7): the same playback and rules as the
  /// live view, closed with `DELETE /api/vista-en-vivo/{sesionId}` and logged as a preview.
  Future<SesionVivo> vistaPrevia(String camaraId);
}

class PcsRepositorioApi implements PcsRepositorio {
  PcsRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Pc>> listar() => llamarApi(() async {
    final r = await _dio.get<List<dynamic>>('/api/pcs');
    return [
      for (final j in r.data ?? const [])
        Pc.desdeJson(j as Map<String, dynamic>),
    ];
  });

  @override
  Future<ConsultaPc> consultar(String codigo) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/vinculaciones/consulta',
      data: {'codigo': codigo},
    );
    return ConsultaPc.desdeJson(r.data!);
  });

  @override
  Future<Pc> aprobar(String codigo) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/vinculaciones/aprobacion',
      data: {'codigo': codigo},
    );
    return Pc.desdeJson(r.data!);
  });

  @override
  Future<void> rechazar(String codigo) => llamarApi(
    () =>
        _dio.post<void>('/api/vinculaciones/rechazo', data: {'codigo': codigo}),
  );

  @override
  Future<void> quitar(String pcId) =>
      llamarApi(() => _dio.delete<void>('/api/pcs/$pcId'));

  @override
  Future<List<CamaraDetectada>> camaras(String pcId) => llamarApi(() async {
    final r = await _dio.get<List<dynamic>>('/api/pcs/$pcId/camaras');
    return [
      for (final j in r.data ?? const [])
        CamaraDetectada.desdeJson(j as Map<String, dynamic>),
    ];
  });

  @override
  Future<void> buscarCamaras(String pcId) =>
      llamarApi(() => _dio.post<void>('/api/pcs/$pcId/busqueda-de-camaras'));

  @override
  Future<Camara> usarCamara(
    String camaraId, {
    String? ambienteId,
    String? nombreAmbiente,
  }) => llamarApi(() async {
    final r = await _dio.put<Map<String, dynamic>>(
      '/api/camaras/$camaraId/ambiente',
      data: ambienteId != null
          ? {'ambienteId': ambienteId}
          : {'nombreAmbiente': nombreAmbiente},
    );
    return Camara.desdeJson(r.data!);
  });

  @override
  Future<void> dejarDeUsar(String camaraId) =>
      llamarApi(() => _dio.delete<void>('/api/camaras/$camaraId/ambiente'));

  @override
  Future<List<Ambiente>> ambientes() => llamarApi(() async {
    final r = await _dio.get<List<dynamic>>('/api/ambientes');
    return [
      for (final j in r.data ?? const [])
        Ambiente.desdeJson(j as Map<String, dynamic>),
    ];
  });

  @override
  Future<SesionVivo> vistaPrevia(String camaraId) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/camaras/$camaraId/vista-previa',
    );
    return SesionVivo.desdeJson(r.data!);
  });
}

final pcsRepositorioProvider = Provider<PcsRepositorio>(
  (ref) => PcsRepositorioApi(ref.watch(clienteApiProvider)),
);

/// The household's PCs (`GET /api/pcs`).
final pcsProvider = FutureProvider<List<Pc>>(
  (ref) => ref.watch(pcsRepositorioProvider).listar(),
);

/// The webcams of one PC (`GET /api/pcs/{id}/camaras`).
final camarasDetectadasProvider =
    FutureProvider.family<List<CamaraDetectada>, String>(
      (ref, pcId) => ref.watch(pcsRepositorioProvider).camaras(pcId),
    );

/// The household's rooms (`GET /api/ambientes`).
final ambientesProvider = FutureProvider<List<Ambiente>>(
  (ref) => ref.watch(pcsRepositorioProvider).ambientes(),
);

/// The household's cameras with their PC and the state the family sees: Inicio, «Cámaras» and the
/// live view's room picker. An older backend without `/api/pcs` gives cameras without a PC.
/// The household's cameras with their PC and state, in the order of this phone.
final camarasEnCasaProvider = FutureProvider<List<CamaraEnCasa>>((ref) async {
  final camaras = await ref.watch(camarasProvider.future);
  final hogar = await ref.watch(hogarProvider.future);
  List<Pc> pcs;
  try {
    pcs = await ref.watch(pcsProvider.future);
  } on Object {
    pcs = const [];
  }
  // In the order of this phone, favourites first (CA-41.4).
  return ref
      .watch(ordenCamarasProvider)
      .ordenar(
        camarasEnCasa(camaras, pcs, conConsentimiento: hogar.conConsentimiento),
        (c) => c.camara.id,
      );
});
