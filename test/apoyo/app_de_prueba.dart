import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:te_tengo/app/app.dart';
import 'package:te_tengo/app/router.dart';
import 'package:te_tengo/app/tema/tema.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';

import 'package:te_tengo/core/dispositivo/conectividad.dart';
import 'package:te_tengo/core/dispositivo/permiso_notificaciones.dart';

import 'adaptador_falso.dart';
import 'dispositivo_falso.dart';

/// A screen alone, inside the theme, with fake repositories in [overrides].
Widget pantallaDePrueba(
  Widget pantalla, {
  List<Override> overrides = const [],
  Sesion? sesion,
  PermisoNotificaciones? permiso,
  Conectividad? conectividad,
}) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    almacenSesionProvider.overrideWithValue(AlmacenSesionMemoria(sesion)),
    adaptadorHttpProvider.overrideWithValue(AdaptadorFalso()),
    permisoNotificacionesProvider.overrideWithValue(permiso ?? PermisoFalso()),
    conectividadProvider.overrideWithValue(conectividad ?? ConectividadFalsa()),
    ...overrides,
  ],
  child: MaterialApp(theme: temaTeTengo(), home: pantalla),
);

/// The whole app with its router, starting at [ubicacion].
Widget appDePrueba({
  required String ubicacion,
  Sesion? sesion,
  AlmacenSesion? almacen,
  List<Override> overrides = const [],
  PermisoNotificaciones? permiso,
  Conectividad? conectividad,
}) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    almacenSesionProvider.overrideWithValue(
      almacen ?? AlmacenSesionMemoria(sesion),
    ),
    adaptadorHttpProvider.overrideWithValue(AdaptadorFalso()),
    permisoNotificacionesProvider.overrideWithValue(permiso ?? PermisoFalso()),
    conectividadProvider.overrideWithValue(conectividad ?? ConectividadFalsa()),
    ubicacionInicialProvider.overrideWithValue(ubicacion),
    ...overrides,
  ],
  child: const TeTengoApp(),
);

/// Uses a phone-sized view (390 × 844 logical px, as the prototype).
void usarTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls [finder] into view (building lazy list items) and taps it.
Future<void> tocar(WidgetTester tester, Finder finder) async {
  await verHasta(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Scrolls the main list until [finder] is built.
Future<void> verHasta(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
