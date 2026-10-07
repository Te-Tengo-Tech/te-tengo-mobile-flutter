import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Signs out: revokes the refresh token in the backend (best effort) and forgets the session, so
  /// a new sign-in is required (CA-02.4).
  Future<void> cerrar() async {
    try {
      await ref.read(sesionRepositorioProvider).cerrar();
    } on Object {
      // Without network the session is still closed on this phone.
    }
    await _almacen.borrar();
    state = null;
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

/// The current session; screens behind the guards can rely on it being present.
final sesionActualProvider = Provider<Sesion>(
  (ref) => ref.watch(sesionControllerProvider)!,
);

/// True when the user is the household owner (`TITULAR`).
final esTitularProvider = Provider<bool>(
  (ref) => ref.watch(sesionControllerProvider)?.esTitular ?? false,
);
