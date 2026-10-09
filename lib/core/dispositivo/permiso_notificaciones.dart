import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../web/navegador.dart';

/// Notification permission of the phone (CA-16.3).
abstract interface class PermisoNotificaciones {
  Future<bool> activadas();

  /// Asks for the permission; when the system no longer asks, opens the app settings. Returns
  /// whether notifications are enabled afterwards.
  Future<bool> activar();
}

class PermisoNotificacionesSistema implements PermisoNotificaciones {
  const PermisoNotificacionesSistema();

  @override
  Future<bool> activadas() => Permission.notification.isGranted;

  @override
  Future<bool> activar() async {
    final estado = await Permission.notification.request();
    if (estado.isPermanentlyDenied) await openAppSettings();
    return estado.isGranted;
  }
}

/// The browser permission (the PWA). It is only asked from the tap on «Activar notificaciones»:
/// Safari ignores a prompt without a user gesture, and the app never prompts on its own on the web.
/// A browser without notifications (an iPhone Safari tab) counts as not allowed.
class PermisoNotificacionesNavegador implements PermisoNotificaciones {
  const PermisoNotificacionesNavegador();

  @override
  Future<bool> activadas() async =>
      permisoNotificacionesNavegador() == 'granted';

  @override
  Future<bool> activar() async =>
      await pedirPermisoNotificacionesNavegador() == 'granted';
}

final permisoNotificacionesProvider = Provider<PermisoNotificaciones>(
  (ref) => kIsWeb
      ? const PermisoNotificacionesNavegador()
      : const PermisoNotificacionesSistema(),
);

/// Whether the phone lets Te Tengo show notifications; refreshed when the app resumes.
final notificacionesActivasProvider = FutureProvider<bool>(
  (ref) => ref.watch(permisoNotificacionesProvider).activadas(),
);
