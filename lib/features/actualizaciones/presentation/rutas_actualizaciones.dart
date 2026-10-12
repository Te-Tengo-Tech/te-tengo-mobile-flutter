import 'package:go_router/go_router.dart';

import 'pantalla_acerca_de.dart';
import 'pantalla_permiso_instalar.dart';

/// Paths of the app's update (US-43).
abstract final class RutasActualizaciones {
  /// Ajustes › «Acerca de Te Tengo».
  static const acercaDe = '/ajustes/acerca-de';

  /// «Permite instalar la actualización» (Android, APK).
  static const permiso = '/actualizacion/permiso';

  /// Paths the minimum-version screen never covers, besides alerts and live views: the start
  /// and the permission the APK's installer needs.
  static const libres = ['/arranque', permiso];
}

final rutasActualizaciones = [
  GoRoute(
    path: RutasActualizaciones.acercaDe,
    builder: (context, state) => const PantallaAcercaDe(),
  ),
  GoRoute(
    path: RutasActualizaciones.permiso,
    builder: (context, state) => const PantallaPermisoInstalar(),
  ),
];
