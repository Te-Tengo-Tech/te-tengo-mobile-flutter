import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

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

final permisoNotificacionesProvider = Provider<PermisoNotificaciones>(
  (ref) => const PermisoNotificacionesSistema(),
);

/// Whether the phone lets Te Tengo show notifications; refreshed when the app resumes.
final notificacionesActivasProvider = FutureProvider<bool>(
  (ref) => ref.watch(permisoNotificacionesProvider).activadas(),
);
