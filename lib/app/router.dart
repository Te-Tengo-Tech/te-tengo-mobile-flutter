import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/sesion/sesion.dart';
import '../core/sesion/sesion_controller.dart';
import '../features/ajustes/presentation/pantalla_ajustes.dart';
import '../features/arranque/pantalla_arranque.dart';
import '../features/camaras/presentation/pantalla_camaras.dart';
import '../features/camaras/presentation/pantalla_nombre_habitacion.dart';
import '../features/inicio/pantalla_inicio.dart';
import '../features/sesion/presentation/pantalla_bienvenida.dart';
import '../features/sesion/presentation/pantalla_cuenta_creada.dart';
import '../features/sesion/presentation/pantalla_iniciar_sesion.dart';
import '../features/sesion/presentation/pantalla_registro.dart';
import '../features/sesion/presentation/pantallas_recuperacion.dart';
import 'navegacion.dart';
import 'pantalla_pendiente.dart';
import 'rutas.dart';

/// First location; tests start elsewhere.
final ubicacionInicialProvider = Provider<String>((ref) => Rutas.arranque);

final routerProvider = Provider<GoRouter>((ref) {
  final sesion = ValueNotifier<Sesion?>(ref.read(sesionControllerProvider));
  ref.listen(sesionControllerProvider, (_, nueva) => sesion.value = nueva);
  final router = GoRouter(
    initialLocation: ref.read(ubicacionInicialProvider),
    refreshListenable: sesion,
    redirect: (context, state) => Rutas.redirigir(sesion.value, state.uri.path),
    routes: [
      GoRoute(
        path: Rutas.arranque,
        builder: (context, state) =>
            PantallaArranque(siguiente: state.uri.queryParameters['siguiente']),
      ),
      GoRoute(
        path: Rutas.bienvenida,
        builder: (context, state) => const PantallaBienvenida(),
      ),
      GoRoute(
        path: Rutas.registro,
        builder: (context, state) => const PantallaRegistro(),
      ),
      GoRoute(
        path: Rutas.cuentaCreada,
        builder: (context, state) => const PantallaCuentaCreada(),
      ),
      GoRoute(
        path: Rutas.iniciarSesion,
        builder: (context, state) => PantallaIniciarSesion(
          correo: state.uri.queryParameters['correo'],
          aviso: AvisoInicioSesion.desde(state.uri.queryParameters['aviso']),
        ),
      ),
      GoRoute(
        path: Rutas.recuperar,
        builder: (context, state) =>
            PantallaRecuperar(correo: state.uri.queryParameters['correo']),
      ),
      GoRoute(
        path: Rutas.enlaceEnviado,
        builder: (context, state) => PantallaEnlaceEnviado(
          correo: state.uri.queryParameters['correo'] ?? '',
        ),
      ),
      GoRoute(
        path: Rutas.nuevaContrasena,
        builder: (context, state) => PantallaNuevaContrasena(
          token: state.uri.queryParameters['token'] ?? '',
          correo: state.uri.queryParameters['correo'],
        ),
      ),
      GoRoute(
        path: Rutas.enlaceVencido,
        builder: (context, state) => const PantallaEnlaceVencido(),
      ),
      GoRoute(
        path: Rutas.configPersona,
        builder: (context, state) => const PantallaPendiente('Persona cuidada'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navegacion) =>
            ShellPestanas(navegacion: navegacion),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.inicio,
                builder: (context, state) => const PantallaInicio(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.historial,
                builder: (context, state) =>
                    const PantallaPendiente('Historial'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.familia,
                builder: (context, state) => const PantallaPendiente('Familia'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Rutas.ajustes,
                builder: (context, state) => const PantallaAjustes(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/camaras',
        builder: (context, state) => const PantallaCamaras(),
        routes: [
          GoRoute(
            path: ':id/nombre',
            builder: (context, state) => PantallaNombreHabitacion(
              camaraId: state.pathParameters['id']!,
              nombreActual: state.uri.queryParameters['actual'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    sesion.dispose();
  });
  return router;
});
