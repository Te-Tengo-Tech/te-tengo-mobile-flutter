import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notificaciones/dispositivos_repositorio.dart';
import '../notificaciones/notificaciones_push.dart';
import '../cache/cache_local.dart';
import 'almacen_sesion.dart';
import 'sesion.dart';
import 'sesion_repositorio.dart';

/// Holds the current [Sesion] (null when signed out). The router listens to it for its guards.
class SesionController extends Notifier<Sesion?> {
  @override
  Sesion? build() => ref.watch(almacenSesionProvider).actual;

  AlmacenSesion get _almacen => ref.read(almacenSesionProvider);

  /// Stores a session returned by the backend (sign-in, household creation, invitation...).
  Future<void> iniciar(Sesion sesion) async {
    await _almacen.guardar(sesion);
    state = sesion;
  }

  /// Called by the HTTP client after refreshing the tokens, or with null when the refresh failed.
  void actualizada(Sesion? sesion) => state = sesion;

  /// Signs out: forgets the session on this phone and revokes the refresh token in the backend
  /// (best effort), so a new sign-in is required (CA-02.4).
  Future<void> cerrar() async {
    final sesion = state;
    await _almacen.borrar();
    state = null;
    // The household data leaves this phone with the session.
    try {
      await ref.read(cacheLocalProvider).vaciar();
    } on Object {
      // Nothing cached yet.
    }
    if (sesion == null) return;
    // This phone stops receiving the alerts (`DELETE /api/dispositivos/{tokenPush}`).
    try {
      final token = await ref.read(notificacionesPushProvider).token();
      if (token != null) {
        await ref
            .read(dispositivosRepositorioProvider)
            .eliminar(token, tokenAcceso: sesion.tokenAcceso);
      }
    } on Object {
      // Best effort: the backend also drops devices of revoked sessions.
    }
    try {
      await ref.read(sesionRepositorioProvider).cerrar(sesion.tokenAcceso);
    } on Object {
      // Without network the session is still closed on this phone.
    }
  }

  /// Switches to another household of the user (`POST /api/sesiones/hogar`).
  Future<void> cambiarHogar(String hogarId) async {
    final sesion = await ref
        .read(sesionRepositorioProvider)
        .cambiarHogar(hogarId);
    await iniciar(sesion);
  }
}

final sesionControllerProvider = NotifierProvider<SesionController, Sesion?>(
  SesionController.new,
);

/// True when the user is the household owner (`TITULAR`).
final esTitularProvider = Provider<bool>(
  (ref) => ref.watch(sesionControllerProvider)?.esTitular ?? false,
);
