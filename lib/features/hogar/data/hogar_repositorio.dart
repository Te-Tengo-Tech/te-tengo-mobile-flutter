import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../domain/hogar.dart';

/// Household, older adult and consent (contract §2).
abstract interface class HogarRepositorio {
  /// `GET /api/hogar`.
  Future<Hogar> obtener();

  /// `POST /api/hogar`: creates the household with the caller as `TITULAR` and returns a session
  /// that carries its `hogar_id` (CA-04.1). Errors: `409 HOGAR_YA_REGISTRADO` (CA-04.2),
  /// `400 VALIDACION` (CA-04.3).
  Future<Sesion> crear(AdultoMayor adultoMayor);

  /// `PUT /api/hogar/adulto-mayor` (owner).
  Future<AdultoMayor> actualizarAdultoMayor(AdultoMayor adultoMayor);

  /// `POST /api/hogar/consentimiento` (owner). Both flags must be true; the backend stores the date
  /// and time (CA-05.3) and capture may start (CA-05.1). Errors: `422 CONSENTIMIENTO_NO_ACEPTADO`.
  Future<Consentimiento> registrarConsentimiento({required String otorgadoPor});

  /// `DELETE /api/hogar/consentimiento` (owner): stops capture and schedules the deletion of every
  /// recording (CA-09.1); the push `DATOS_ELIMINADOS` arrives when done (CA-09.3), and
  /// `GET /api/hogar` `eliminacion` tells it too. Returns `clips`, how many recordings it deletes;
  /// null with a backend older than 0.3.4.
  Future<int?> revocarConsentimiento();
}

class HogarRepositorioApi implements HogarRepositorio {
  HogarRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<Hogar> obtener() => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>('/api/hogar');
    return Hogar.desdeJson(r.data!);
  });

  @override
  Future<Sesion> crear(AdultoMayor adultoMayor) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/hogar',
      data: {'adultoMayor': adultoMayor.aJson()},
    );
    return Sesion.desdeJson(r.data!);
  });

  @override
  Future<AdultoMayor> actualizarAdultoMayor(AdultoMayor adultoMayor) =>
      llamarApi(() async {
        final r = await _dio.put<Map<String, dynamic>>(
          '/api/hogar/adulto-mayor',
          data: adultoMayor.aJson(),
        );
        return AdultoMayor.desdeJson(r.data!);
      });

  @override
  Future<Consentimiento> registrarConsentimiento({
    required String otorgadoPor,
  }) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/hogar/consentimiento',
      data: {
        'otorgadoPor': otorgadoPor,
        'aceptadoPorAdultoMayor': true,
        'vistaEnVivoAceptada': true,
      },
    );
    return Consentimiento.desdeJson(r.data!);
  });

  @override
  Future<int?> revocarConsentimiento() => llamarApi(() async {
    final r = await _dio.delete<Object?>('/api/hogar/consentimiento');
    final cuerpo = r.data;
    return cuerpo is Map ? (cuerpo['clips'] as num?)?.toInt() : null;
  });
}

final hogarRepositorioProvider = Provider<HogarRepositorio>(
  (ref) => HogarRepositorioApi(ref.watch(clienteApiProvider)),
);

/// The household of the session; reloaded when the session changes household.
final hogarProvider = FutureProvider<Hogar>((ref) {
  ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
  return ref.watch(hogarRepositorioProvider).obtener();
});

/// First name of the older adult, once the household is loaded (`Rosa`).
final nombreAdultoMayorProvider = Provider<String?>(
  (ref) => ref.watch(hogarProvider).value?.adultoMayor.nombrePila,
);
