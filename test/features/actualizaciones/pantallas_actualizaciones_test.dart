import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/router.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/features/actualizaciones/data/actualizacion_controller.dart';
import 'package:te_tengo/features/actualizaciones/domain/estado_actualizacion.dart';
import 'package:te_tengo/features/actualizaciones/domain/versiones.dart';
import 'package:te_tengo/features/actualizaciones/presentation/rutas_actualizaciones.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/clip_falso.dart';
import 'package:te_tengo/features/alertas/presentation/reproductor.dart';
import '../../apoyo/dispositivo_falso.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import '../alertas/alertas_falso.dart';
import 'actualizaciones_falso.dart';
import 'app_actualizaciones.dart';

void main() {
  group('barra de versión nueva', () {
    testWidgets(
      'APK: «Hay una versión nueva (0.6.0)», «Qué cambió» y «Actualizar»',
      (tester) async {
        await abrirApp(
          tester,
          Rutas.inicio,
          actualizacion: overridesActualizacion(
            versiones: VersionesFalsas(versionesEn('0.6.0')),
          ),
        );
        expect(texto('Hay una versión nueva (0.6.0)'), findsOneWidget);
        expect(find.text('Actualizar'), findsOneWidget);
        await tester.tap(find.text('Qué cambió'));
        await tester.pumpAndSettle();
        expect(find.text('Qué cambió en la 0.6.0'), findsOneWidget);
        expect(find.text('8,4 MB'), findsOneWidget);
        expect(find.text('Las alertas llegan más rápido.'), findsOneWidget);
        await tester.tap(find.text('Ahora no'));
        await tester.pumpAndSettle();
        expect(find.text('Qué cambió en la 0.6.0'), findsNothing);
      },
    );

    testWidgets(
      'PWA: «Hay una versión nueva» y «Actualizar», sin «Qué cambió»',
      (tester) async {
        await abrirApp(
          tester,
          Rutas.historial,
          actualizacion: overridesActualizacion(
            info: infoPwa,
            versiones: VersionesFalsas(versionesEn('0.6.0')),
          ),
        );
        expect(find.text('Hay una versión nueva'), findsOneWidget);
        expect(find.text('Qué cambió'), findsNothing);
        expect(find.text('Actualizar'), findsOneWidget);
      },
    );

    testWidgets('PWA: «Actualizando…» y recarga (CA-43.4)', (tester) async {
      final recargas = <int>[];
      await abrirApp(
        tester,
        Rutas.inicio,
        actualizacion: overridesActualizacion(
          info: infoPwa,
          versiones: VersionesFalsas(versionesEn('0.6.0')),
          recargas: recargas,
        ),
      );
      await tester.tap(find.text('Actualizar'));
      await tester.pump();
      expect(find.text('Actualizando…'), findsOneWidget);
      expect(recargas, [1]);
    });

    testWidgets('Google Play: «Hay una versión nueva» con «Qué cambió»', (
      tester,
    ) async {
      await abrirApp(
        tester,
        Rutas.familia,
        actualizacion: overridesActualizacion(
          info: infoPlay,
          versiones: VersionesFalsas(versionesEn('0.6.0')),
        ),
      );
      expect(find.text('Hay una versión nueva'), findsOneWidget);
      expect(find.text('Qué cambió'), findsOneWidget);
    });

    testWidgets('iPhone: «Hay una versión nueva · TestFlight» y «Abrir»', (
      tester,
    ) async {
      final enlaces = <Uri>[];
      await abrirApp(
        tester,
        Rutas.ajustes,
        actualizacion: overridesActualizacion(
          info: infoIos,
          versiones: VersionesFalsas(versionesEn('0.6.0')),
          enlaces: enlaces,
        ),
      );
      expect(find.text('Hay una versión nueva'), findsOneWidget);
      expect(find.text('TestFlight'), findsOneWidget);
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(enlaces.single.host, 'testflight.apple.com');
    });

    testWidgets('al día no hay barra', (tester) async {
      await abrirApp(
        tester,
        Rutas.inicio,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.5.0')),
        ),
      );
      expect(find.textContaining('Hay una versión nueva'), findsNothing);
    });

    testWidgets('un backend sin /api/versiones no muestra nada', (
      tester,
    ) async {
      await abrirApp(
        tester,
        Rutas.inicio,
        actualizacion: overridesActualizacion(versiones: VersionesFalsas()),
      );
      expect(find.textContaining('versión'), findsNothing);
    });

    testWidgets(
      'con una alerta activa la barra espera y vuelve al cerrarla (CA-43.9)',
      (tester) async {
        final alertas = AlertasRepositorioFalso([caidaSala()]);
        await abrirApp(
          tester,
          Rutas.historial,
          repoAlertas: alertas,
          actualizacion: overridesActualizacion(
            versiones: VersionesFalsas(versionesEn('0.6.0')),
          ),
        );
        // The alert opened by itself (CA-16.4): no bar on it.
        expect(find.textContaining('Hay una versión nueva'), findsNothing);
        alertas.alertas = [caidaSala(estado: EstadoAlerta.atendida)];
        contenedorDe(tester).invalidate(alertaActivaProvider);
        contenedorDe(tester).read(routerProvider).pop();
        await tester.pumpAndSettle();
        expect(texto('Hay una versión nueva (0.6.0)'), findsOneWidget);
      },
    );
  });

  group('versión obligatoria (CA-43.8)', () {
    testWidgets('bloquea con amabilidad y deja llamar', (tester) async {
      final llamadas = <String?>[];
      await abrirApp(
        tester,
        Rutas.inicio,
        llamadas: llamadas,
        actualizacion: overridesActualizacion(
          info: infoPlay,
          versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.6.0')),
        ),
      );
      expect(
        find.text('Actualiza Te Tengo para seguir recibiendo alertas'),
        findsOneWidget,
      );
      expect(find.text('Tienes la 0.5.0. Toma un minuto.'), findsOneWidget);
      expect(find.text('Abrir la tienda'), findsOneWidget);
      expect(find.text('Se abre Google Play.'), findsOneWidget);
      expect(find.textContaining('Hay una versión nueva'), findsNothing);
      await tester.tap(find.text('Llamar a Rosa'));
      expect(llamadas, hasLength(1));
    });

    testWidgets('iPhone: «Se abre App Store.»', (tester) async {
      await abrirApp(
        tester,
        Rutas.inicio,
        actualizacion: overridesActualizacion(
          info: const InfoApp(version: '0.5.0', canal: Canal.ios),
          versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.6.0')),
        ),
      );
      expect(find.text('Se abre App Store.'), findsOneWidget);
    });

    testWidgets('APK y PWA: «Actualizar»', (tester) async {
      await abrirApp(
        tester,
        Rutas.inicio,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.6.0')),
        ),
      );
      expect(find.text('Actualizar'), findsOneWidget);
      expect(find.textContaining('Se abre'), findsNothing);
    });

    testWidgets('sin sesión también, sin «Llamar»', (tester) async {
      await abrirApp(
        tester,
        Rutas.bienvenida,
        sesion: null,
        actualizacion: overridesActualizacion(
          info: infoPlay,
          versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.6.0')),
        ),
      );
      expect(find.text('Abrir la tienda'), findsOneWidget);
      expect(find.textContaining('Llamar a'), findsNothing);
    });

    testWidgets('la alerta activa se sigue viendo', (tester) async {
      await abrirApp(
        tester,
        Rutas.inicio,
        alertas: [caidaSala()],
        actualizacion: overridesActualizacion(
          info: infoPlay,
          versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.6.0')),
        ),
      );
      // The alert opens by itself on top and the update screen steps aside.
      expect(
        find.text('Actualiza Te Tengo para seguir recibiendo alertas'),
        findsNothing,
      );
      expect(find.textContaining('Llamar a Rosa'), findsWidgets);
    });

    testWidgets('una alerta abierta desde una notificación no se cubre', (
      tester,
    ) async {
      final atendida = caidaSala(id: 'h1', estado: EstadoAlerta.atendida);
      await abrirApp(
        tester,
        Rutas.detalleAlerta('h1'),
        alertas: [atendida],
        mas: [fabricaClipProvider.overrideWithValue(ClipFalso.new)],
        actualizacion: overridesActualizacion(
          info: infoPlay,
          versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.6.0')),
        ),
      );
      expect(
        find.text('Actualiza Te Tengo para seguir recibiendo alertas'),
        findsNothing,
      );
    });

    testWidgets('al día no aparece', (tester) async {
      await abrirApp(
        tester,
        Rutas.inicio,
        actualizacion: overridesActualizacion(
          info: infoPlay,
          versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.5.0')),
        ),
      );
      expect(
        find.text('Actualiza Te Tengo para seguir recibiendo alertas'),
        findsNothing,
      );
    });
  });

  group('Acerca de Te Tengo', () {
    testWidgets('fila de Ajustes: «Versión 0.5.0 · hay una nueva»', (
      tester,
    ) async {
      await abrirApp(
        tester,
        Rutas.ajustes,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.6.0')),
        ),
      );
      await verHasta(tester, find.text('Acerca de Te Tengo'));
      expect(texto('Versión 0.5.0 · hay una nueva'), findsOneWidget);
      expect(find.text('Te Tengo 0.5.0'), findsOneWidget);
      await tocar(tester, find.text('Acerca de Te Tengo'));
      expect(find.text('Acerca de'), findsOneWidget);
    });

    testWidgets('versión nueva con «Qué cambió» y la acción', (tester) async {
      await abrirApp(
        tester,
        RutasActualizaciones.acercaDe,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.6.0')),
        ),
      );
      expect(find.text('Versión 0.5.0'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('Versión 0.6.0'), findsOneWidget);
      expect(find.text('Qué cambió'), findsOneWidget);
      expect(find.text('Actualizar'), findsOneWidget);
    });

    testWidgets('«Buscar actualizaciones» y «Tienes la última versión»', (
      tester,
    ) async {
      await abrirApp(
        tester,
        RutasActualizaciones.acercaDe,
        actualizacion: overridesActualizacion(
          info: infoPlay,
          versiones: VersionesFalsas(versionesEn('0.5.0')),
        ),
      );
      expect(find.text('Android · Google Play'), findsOneWidget);
      expect(find.text('Tienes la última versión'), findsOneWidget);
      expect(texto('Revisado hoy a las 10:42.'), findsOneWidget);
      await tester.tap(find.text('Buscar actualizaciones'));
      await tester.pumpAndSettle();
      expect(find.text('Tienes la última versión'), findsOneWidget);
    });

    testWidgets('sin internet al buscar: «No pudimos buscar.»', (tester) async {
      final conectividad = ConectividadFalsa();
      await abrirApp(
        tester,
        RutasActualizaciones.acercaDe,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.5.0')),
        ),
        conectividad: conectividad,
      );
      conectividad.hay = false;
      await tester.tap(find.text('Buscar actualizaciones'));
      await tester.pumpAndSettle();
      expect(find.text('Sin internet'), findsOneWidget);
      expect(find.text('No pudimos buscar.'), findsOneWidget);
      conectividad.hay = true;
    });

    testWidgets('con una alerta activa: «Al cerrar la alerta.» (CA-43.9)', (
      tester,
    ) async {
      await abrirApp(
        tester,
        RutasActualizaciones.acercaDe,
        alertas: [caidaSala()],
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.6.0')),
        ),
      );
      expect(find.text('Al cerrar la alerta.'), findsOneWidget);
    });

    testWidgets('PCs de la casa: al día y con versión anterior (CA-43.7)', (
      tester,
    ) async {
      await abrirApp(
        tester,
        RutasActualizaciones.acercaDe,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.5.0', captura: '0.5.0')),
        ),
      );
      await verHasta(tester, find.text('PCs de la casa'));
      expect(
        find.text('Todas al día · Te Tengo Captura 0.5.0'),
        findsOneWidget,
      );
      expect(texto('Captura 0.5.0 · al día'), findsOneWidget);
    });

    testWidgets('1 PC con versión anterior', (tester) async {
      await abrirApp(
        tester,
        RutasActualizaciones.acercaDe,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.5.0', captura: '0.5.1')),
        ),
      );
      await verHasta(tester, find.text('1 PC con versión anterior'));
      expect(texto('Captura 0.5.0 · versión anterior'), findsOneWidget);
    });
  });

  group('APK en pantalla', () {
    testWidgets('«Permite instalar la actualización»: ajustes y «Ahora no»', (
      tester,
    ) async {
      final instalador = InstaladorFalso(permiso: false);
      await abrirApp(
        tester,
        RutasActualizaciones.permiso,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.6.0')),
          instalador: instalador,
        ),
      );
      expect(find.text('Instalar la actualización'), findsOneWidget);
      expect(find.text('Permite instalar la actualización'), findsOneWidget);
      expect(find.text('Android lo pide una sola vez.'), findsOneWidget);
      expect(find.text('Toca «Abrir ajustes».'), findsOneWidget);
      expect(find.text('Activa «Permitir de esta fuente».'), findsOneWidget);
      expect(find.text('Vuelve a Te Tengo.'), findsOneWidget);
      await tester.tap(find.text('Abrir ajustes'));
      await tester.pump();
      expect(instalador.ajustesAbiertos, 1);
      await tester.tap(find.text('Ahora no'));
      await tester.pumpAndSettle();
      expect(
        contenedorDe(tester).read(actualizacionProvider).error,
        ErrorActualizacion.sinPermiso,
      );
    });

    testWidgets('la barra dice «Falta el permiso de Android»', (tester) async {
      await abrirApp(
        tester,
        Rutas.inicio,
        actualizacion: overridesActualizacion(
          versiones: VersionesFalsas(versionesEn('0.6.0')),
        ),
      );
      contenedorDe(
        tester,
      ).read(actualizacionProvider.notifier).permisoAhoraNo();
      await tester.pumpAndSettle();
      expect(find.text('Falta el permiso de Android'), findsOneWidget);
      expect(find.text('Sin él no se instala.'), findsOneWidget);
      expect(find.text('Actualizar'), findsOneWidget);
    });
  });

  testWidgets('busca al abrir, al volver tras 5 minutos y una vez al día', (
    tester,
  ) async {
    var ahora = DateTime(2026, 10, 11, 10, 42);
    final versiones = VersionesFalsas(versionesEn('0.5.0'));
    await abrirApp(
      tester,
      Rutas.inicio,
      reloj: () => ahora,
      actualizacion: overridesActualizacion(versiones: versiones),
    );
    expect(versiones.lecturas, 1);
    Future<void> volver() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    }

    ahora = ahora.add(const Duration(minutes: 2));
    await volver();
    expect(versiones.lecturas, 1);
    ahora = ahora.add(const Duration(minutes: 5));
    await volver();
    expect(versiones.lecturas, 2);
    // A day later, with the app open.
    ahora = ahora.add(const Duration(days: 1));
    await tester.pump(const Duration(days: 1));
    await tester.pumpAndSettle();
    expect(versiones.lecturas, 3);
  });
}
