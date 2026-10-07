import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/camaras/presentation/pantalla_camaras.dart';
import '../features/camaras/presentation/pantalla_nombre_habitacion.dart';
import '../features/inicio/pantalla_inicio.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PantallaInicio(),
        routes: [
          GoRoute(
            path: 'camaras',
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
      ),
    ],
  );
});
