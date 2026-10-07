import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/cliente_api.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../domain/familiar.dart';

/// Family and alert routing (contract §3).
abstract interface class FamiliaRepositorio {
  /// `GET /api/familiares`.
  Future<List<Familiar>> listar();

  /// `POST /api/invitaciones` (owner): emails a link to create access (CA-08.1). Errors:
  /// `409 YA_ES_FAMILIAR`.
  Future<Invitacion> invitar(String correo);

  /// `POST /api/invitaciones/{token}/aceptacion` (public): a new account with [nombre] and
  /// [contrasena], or the signed-in one when both are null. Returns the `INVITADO` session of the
  /// household (CA-08.2). Errors: `410 INVITACION_VENCIDA`.
  Future<Sesion> aceptarInvitacion(
    String token, {
    String? nombre,
    String? contrasena,
  });

  /// `DELETE /api/familiares/{usuarioId}` (owner): removes access to the alerts (CA-08.3). Errors:
  /// `409 NO_SE_PUEDE_RETIRAR_TITULAR`.
  Future<void> retirar(String usuarioId);

  /// `GET /api/hogar/aviso`.
  Future<ConfiguracionAviso> aviso();

  /// `PUT /api/hogar/aviso` (owner). Errors: `422 ESPERA_INVALIDA`, `422 CONTACTO_NO_ES_FAMILIAR`.
  Future<ConfiguracionAviso> guardarAviso(ConfiguracionAviso aviso);
}

class FamiliaRepositorioApi implements FamiliaRepositorio {
  FamiliaRepositorioApi(this._dio);

  final Dio _dio;

  @override
  Future<List<Familiar>> listar() => llamarApi(() async {
    final r = await _dio.get<List<dynamic>>('/api/familiares');
    return (r.data ?? [])
        .map((j) => Familiar.desdeJson(j as Map<String, dynamic>))
        .toList();
  });

  @override
  Future<Invitacion> invitar(String correo) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/invitaciones',
      data: {'correo': correo},
    );
    return Invitacion.desdeJson(r.data!);
  });

  @override
  Future<Sesion> aceptarInvitacion(
    String token, {
    String? nombre,
    String? contrasena,
  }) => llamarApi(() async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/api/invitaciones/${Uri.encodeComponent(token)}/aceptacion',
      data: nombre == null
          ? null
          : {'nombre': nombre, 'contrasena': contrasena},
    );
    return Sesion.desdeJson(r.data!);
  });

  @override
  Future<void> retirar(String usuarioId) => llamarApi(() async {
    await _dio.delete<void>('/api/familiares/$usuarioId');
  });

  @override
  Future<ConfiguracionAviso> aviso() => llamarApi(() async {
    final r = await _dio.get<Map<String, dynamic>>('/api/hogar/aviso');
    return ConfiguracionAviso.desdeJson(r.data!);
  });

  @override
  Future<ConfiguracionAviso> guardarAviso(ConfiguracionAviso aviso) =>
      llamarApi(() async {
        final r = await _dio.put<Map<String, dynamic>>(
          '/api/hogar/aviso',
          data: aviso.aJson(),
        );
        // The contract answers `200`; the body may be empty.
        final datos = r.data;
        return datos == null ? aviso : ConfiguracionAviso.desdeJson(datos);
      });
}

final familiaRepositorioProvider = Provider<FamiliaRepositorio>(
  (ref) => FamiliaRepositorioApi(ref.watch(clienteApiProvider)),
);

final familiaresProvider = FutureProvider<List<Familiar>>((ref) {
  ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
  return ref.watch(familiaRepositorioProvider).listar();
});

/// First name of the owner, for the read-only notices («Solo Carmen (titular) puede…»).
final nombreTitularProvider = Provider<String?>((ref) {
  final sesion = ref.watch(sesionControllerProvider);
  if (sesion?.esTitular ?? false) return sesion!.usuario.nombrePila;
  final familia = ref.watch(familiaresProvider).value;
  return familia?.where((f) => f.esTitular).firstOrNull?.nombrePila;
});

final avisoProvider = FutureProvider<ConfiguracionAviso>((ref) {
  ref.watch(sesionControllerProvider.select((s) => s?.hogarId));
  return ref.watch(familiaRepositorioProvider).aviso();
});

/// Members with their role in the alert order, principal first (`famOrder`).
class MiembroFamilia {
  const MiembroFamilia(this.familiar, this.papel);

  final Familiar familiar;
  final PapelAviso papel;
}

List<MiembroFamilia> ordenarFamilia(
  List<Familiar> familia,
  ConfiguracionAviso? aviso,
) {
  PapelAviso papel(Familiar f) => f.usuarioId == aviso?.principalId
      ? PapelAviso.principal
      : f.usuarioId == aviso?.secundarioId
      ? PapelAviso.secundario
      : PapelAviso.familiar;
  return [for (final f in familia) MiembroFamilia(f, papel(f))]
    ..sort((a, b) => a.papel.index.compareTo(b.papel.index));
}

final miembrosProvider = Provider<AsyncValue<List<MiembroFamilia>>>((ref) {
  final familia = ref.watch(familiaresProvider);
  final aviso = ref.watch(avisoProvider);
  return switch ((familia, aviso)) {
    (AsyncData(value: final f), AsyncData(value: final a)) => AsyncData(
      ordenarFamilia(f, a),
    ),
    (AsyncError(:final error, :final stackTrace), _) ||
    (
      _,
      AsyncError(:final error, :final stackTrace),
    ) => AsyncError(error, stackTrace),
    _ => const AsyncLoading(),
  };
});
