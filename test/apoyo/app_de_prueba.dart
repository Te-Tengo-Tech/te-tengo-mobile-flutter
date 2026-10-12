import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:te_tengo/app/app.dart';
import 'package:te_tengo/app/router.dart';
import 'package:te_tengo/app/tema/tema.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/avisos_flotantes.dart';
import 'package:te_tengo/core/ui/ayuda.dart';
import 'package:te_tengo/features/widget/data/widget_sistema.dart';

import 'package:te_tengo/core/dispositivo/conectividad.dart';
import 'package:te_tengo/core/dispositivo/permiso_notificaciones.dart';

import 'package:te_tengo/core/notificaciones/dispositivos_repositorio.dart';
import 'package:te_tengo/core/notificaciones/notificaciones_push.dart';

import 'adaptador_falso.dart';
import 'push_falso.dart';
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
    cacheLocalProvider.overrideWithValue(CacheMemoria()),
    permisoNotificacionesProvider.overrideWithValue(permiso ?? PermisoFalso()),
    conectividadProvider.overrideWithValue(conectividad ?? ConectividadFalsa()),
    ...overrides,
  ],
  child: MaterialApp(
    theme: temaTeTengo(),
    home: pantalla,
    builder: (context, hijo) => AnfitrionAvisos(child: hijo!),
  ),
);

/// The whole app with its router, starting at [ubicacion].
Widget appDePrueba({
  required String ubicacion,
  Sesion? sesion,
  AlmacenSesion? almacen,
  List<Override> overrides = const [],
  PermisoNotificaciones? permiso,
  Conectividad? conectividad,
  NotificacionesPush? push,
  DispositivosRepositorio? dispositivos,
  CacheLocal? cache,
  AdaptadorFalso? http,
  WidgetDelSistema? widget,
}) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    almacenSesionProvider.overrideWithValue(
      almacen ?? AlmacenSesionMemoria(sesion),
    ),
    // By default this phone has a token and the backend has it: no notice about the alerts.
    notificacionesPushProvider.overrideWithValue(
      push ?? NotificacionesPushFalsas(tokenActual: 'fcm-prueba'),
    ),
    dispositivosRepositorioProvider.overrideWithValue(
      dispositivos ?? DispositivosFalsos(),
    ),
    adaptadorHttpProvider.overrideWithValue(http ?? AdaptadorFalso()),
    cacheLocalProvider.overrideWithValue(cache ?? CacheMemoria()),
    permisoNotificacionesProvider.overrideWithValue(permiso ?? PermisoFalso()),
    conectividadProvider.overrideWithValue(conectividad ?? ConectividadFalsa()),
    ubicacionInicialProvider.overrideWithValue(ubicacion),
    // No home-screen widget unless a test brings its own.
    widgetDelSistemaProvider.overrideWithValue(
      widget ?? const WidgetNoDisponible(),
    ),
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
    // The visible list: tabs and routes below keep theirs in the tree.
    scrollable: find.byType(Scrollable).hitTestable().first,
  );
  await tester.pumpAndSettle();
}

/// The «?» help whose text is [texto] (docs `5100fc7`).
Finder ayudaCon(String texto) =>
    find.byWidgetPredicate((w) => w is AyudaInfo && w.texto == texto);

/// The «?» with [texto] is on screen, its text is not until a tap opens it, and a second tap closes
/// it again.
Future<void> verAyuda(WidgetTester tester, String texto) async {
  final ayuda = ayudaCon(texto);
  await verHasta(tester, ayuda);
  expect(ayuda, findsOneWidget);
  await tester.ensureVisible(ayuda);
  await tester.pumpAndSettle();
  final antes = find.text(texto).evaluate().length;
  await tester.tap(ayuda);
  await tester.pumpAndSettle();
  expect(find.text(texto), findsNWidgets(antes + 1));
  await tester.tap(ayuda);
  await tester.pumpAndSettle();
  expect(find.text(texto), findsNWidgets(antes));
}
