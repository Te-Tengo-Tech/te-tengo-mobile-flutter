import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/push.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/dispositivos_repositorio.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/notificaciones/notificaciones_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion_controller.dart';
import 'package:te_tengo/core/sesion/sesion_repositorio.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/web/entorno.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/inicio/presentation/pantalla_inicio.dart';

import '../apoyo/adaptador_falso.dart';
import '../apoyo/app_de_prueba.dart';
import '../apoyo/datos.dart';
import '../apoyo/dispositivo_falso.dart';
import '../apoyo/push_falso.dart';
import '../features/camaras/repositorio_falso.dart';
import '../features/familia/familia_falso.dart';
import '../features/hogar/hogar_falso.dart';

class _SesionesFalsas implements SesionRepositorio {
  @override
  Future<void> cerrar(String tokenAcceso) async {}

  @override
  Future<Sesion> cambiarHogar(String hogarId) => throw UnimplementedError();

  @override
  Future<List<HogarResumen>> hogares() async => [];
}

/// The app goes to the background and comes back.
Future<void> volverALaApp(WidgetTester tester) async {
  for (final estado in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(estado);
  }
  await tester.pumpAndSettle();
}

void main() {
  group('obtenerTokenPush', () {
    test('en Android pide el token de FCM directamente', () async {
      var apns = 0;
      final token = await obtenerTokenPush(
        esIos: false,
        tokenApns: () async {
          apns++;
          return null;
        },
        tokenFcm: () async => 'fcm-1',
      );
      expect(token, 'fcm-1');
      expect(apns, 0);
    });

    test('en iOS espera el token de APNs antes de pedir el de FCM', () async {
      final respuestas = <String?>[null, null, 'apns-1'];
      final esperas = <Duration>[];
      var fcm = 0;
      final token = await obtenerTokenPush(
        esIos: true,
        tokenApns: () async => respuestas.removeAt(0),
        tokenFcm: () async {
          fcm++;
          return 'fcm-1';
        },
        esperar: (d) async => esperas.add(d),
      );
      expect(token, 'fcm-1');
      expect(esperas, [const Duration(seconds: 1), const Duration(seconds: 1)]);
      expect(fcm, 1);
    });

    test('en iOS sin APNs no pide el token de FCM y devuelve null', () async {
      var fcm = 0;
      var apns = 0;
      final token = await obtenerTokenPush(
        esIos: true,
        intentos: 3,
        tokenApns: () async {
          apns++;
          return null;
        },
        tokenFcm: () async {
          fcm++;
          return 'fcm-1';
        },
        esperar: (_) async {},
      );
      expect(token, isNull);
      expect(apns, 3);
      expect(fcm, 0);
    });

    test('otro error de Firebase se propaga para avisarlo', () async {
      await expectLater(
        obtenerTokenPush(
          esIos: false,
          tokenApns: () async => null,
          tokenFcm: () async => throw Exception('messaging/permission-blocked'),
        ),
        throwsException,
      );
    });

    test('un error de Firebase deja la app sin token', () async {
      final token = await obtenerTokenPush(
        esIos: false,
        tokenApns: () async => null,
        tokenFcm: () async => throw Exception('apns-token-not-set'),
      );
      expect(token, isNull);
    });
  });

  test('sin Firebase no hay token ni se pide el permiso', () async {
    const inactivas = NotificacionesPushInactivas();
    expect(await inactivas.pedirPermiso(), isFalse);
    expect(await inactivas.token(), isNull);
  });

  group('MensajePush', () {
    test('lee el payload de datos del contrato', () {
      final m = MensajePush.desdeDatos({
        'tipo': 'ALERTA_CAIDA',
        'alertaId': 'a-1',
        'camaraId': 'c1',
        'habitacion': 'Sala',
        'ocurridaEn': '2026-10-07T15:04:31Z',
      })!;
      expect(m.tipo, TipoPush.alertaCaida);
      expect(m.alertaId, 'a-1');
      expect(m.ocurridaEn, isNotNull);
      expect(MensajePush.desdeDatos({'tipo': 'OTRO'}), isNull);
    });

    test('cada tipo abre su pantalla', () {
      MensajePush m(TipoPush t) =>
          MensajePush(tipo: t, alertaId: 'a-1', camaraId: 'c1');
      for (final t in [
        TipoPush.alertaCaida,
        TipoPush.alertaMovimientoInestable,
        TipoPush.alertaActualizadaACaida,
        TipoPush.caidaConfirmada,
        TipoPush.seLevanto,
        TipoPush.alertaEscalada,
        TipoPush.sinContactoSecundario,
      ]) {
        expect(rutaDePush(m(t)), Rutas.alerta('a-1'), reason: t.codigo);
      }
      expect(
        rutaDePush(m(TipoPush.alertaAtendida)),
        Rutas.detalleAlerta('a-1'),
      );
      for (final t in [
        TipoPush.camaraDesconectada,
        TipoPush.camaraReconectada,
        TipoPush.deteccionNoConfiable,
        TipoPush.pausaFinalizada,
      ]) {
        expect(rutaDePush(m(t)), Rutas.camara('c1'), reason: t.codigo);
      }
      expect(rutaDePush(m(TipoPush.datosEliminados)), Rutas.privacidad);
      expect(
        rutaDePush(const MensajePush(tipo: TipoPush.alertaCaida)),
        Rutas.inicio,
      );
    });
  });

  group('en la app', () {
    late NotificacionesPushFalsas push;
    late DispositivosFalsos dispositivos;
    late AlmacenSesionMemoria almacen;

    Future<void> abrir(
      WidgetTester tester, {
      String ubicacion = Rutas.inicio,
      EntornoNavegador? entorno,
      PermisoFalso? permiso,
    }) async {
      usarTelefono(tester);
      await tester.pumpWidget(
        appDePrueba(
          ubicacion: ubicacion,
          almacen: almacen,
          permiso: permiso,
          push: push,
          dispositivos: dispositivos,
          overrides: [
            camarasRepositorioProvider.overrideWithValue(
              CamarasRepositorioFalso(),
            ),
            hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
            familiaRepositorioProvider.overrideWithValue(
              FamiliaRepositorioFalso(),
            ),
            sesionRepositorioProvider.overrideWithValue(_SesionesFalsas()),
            relojProvider.overrideWithValue(
              () => DateTime(2026, 9, 23, 10, 42),
            ),
            if (entorno != null)
              entornoNavegadorProvider.overrideWithValue(entorno),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      push = NotificacionesPushFalsas(tokenActual: 'fcm-1');
      dispositivos = DispositivosFalsos();
      almacen = AlmacenSesionMemoria(sesionTitular);
    });

    testWidgets('registra el celular al abrir la app con sesión', (
      tester,
    ) async {
      await abrir(tester);
      expect(dispositivos.registrados, ['fcm-1|ANDROID']);
      push.renovar('fcm-2');
      await tester.pumpAndSettle();
      expect(dispositivos.registrados, ['fcm-1|ANDROID', 'fcm-2|ANDROID']);
    });

    testWidgets('pide el permiso de notificaciones una sola vez, con hogar', (
      tester,
    ) async {
      await abrir(tester);
      expect(push.permisosPedidos, 1);
      push.renovar('fcm-2');
      await tester.pumpAndSettle();
      expect(push.permisosPedidos, 1);
    });

    testWidgets(
      'en la web no pide el permiso por su cuenta: espera el toque y luego registra',
      (tester) async {
        // Safari only shows the prompt inside a tap («Activar notificaciones» in Inicio).
        push.tokenActual = null;
        await abrir(
          tester,
          entorno: const EntornoNavegador(esWeb: true, instalada: true),
          permiso: PermisoFalso(activas: false),
        );
        expect(push.permisosPedidos, 0);
        expect(dispositivos.registrados, isEmpty);
        push.tokenActual = 'fcm-web';
        await tester.tap(find.text('Activar notificaciones'));
        await tester.pumpAndSettle();
        expect(push.permisosPedidos, 0);
        expect(dispositivos.registrados, ['fcm-web|ANDROID']);
      },
    );

    testWidgets('sin hogar no pide el permiso ni registra', (tester) async {
      almacen = AlmacenSesionMemoria(sesionSinHogar);
      await abrir(tester, ubicacion: Rutas.configPersona);
      expect(push.permisosPedidos, 0);
      expect(dispositivos.registrados, isEmpty);
    });

    testWidgets(
      'si el token aún no existe (iOS espera a APNs), registra al volver a la app',
      (tester) async {
        push.tokenActual = null;
        await abrir(tester);
        expect(dispositivos.registrados, isEmpty);
        push.tokenActual = 'fcm-tarde';
        tester.binding
          ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
          ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
          ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
          ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
          ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
          ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pumpAndSettle();
        expect(dispositivos.registrados, ['fcm-tarde|ANDROID']);
      },
    );

    testWidgets('sin Firebase configurado la app funciona sin registrar', (
      tester,
    ) async {
      usarTelefono(tester);
      await tester.pumpWidget(
        appDePrueba(
          ubicacion: Rutas.inicio,
          almacen: almacen,
          dispositivos: dispositivos,
          push: const NotificacionesPushInactivas(),
          overrides: [
            camarasRepositorioProvider.overrideWithValue(
              CamarasRepositorioFalso(),
            ),
            hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
            familiaRepositorioProvider.overrideWithValue(
              FamiliaRepositorioFalso(),
            ),
            sesionRepositorioProvider.overrideWithValue(_SesionesFalsas()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);
      expect(dispositivos.registrados, isEmpty);
    });

    testWidgets('sin sesión no registra; al iniciar sesión, sí', (
      tester,
    ) async {
      almacen = AlmacenSesionMemoria();
      await abrir(tester, ubicacion: Rutas.bienvenida);
      expect(dispositivos.registrados, isEmpty);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      await c.read(sesionControllerProvider.notifier).iniciar(sesionTitular);
      await tester.pumpAndSettle();
      expect(dispositivos.registrados, ['fcm-1|ANDROID']);
    });

    testWidgets('varios registros a la vez envían uno y, al terminar, uno más', (
      tester,
    ) async {
      await abrir(tester);
      // Start, session listener and Inicio register at once: only one POST (it was 2 tokens).
      expect(dispositivos.registrados, ['fcm-1|ANDROID']);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(PantallaInicio)),
      );
      final gestor = c.read(gestorPushProvider);
      final espera = Completer<void>();
      push.esperaToken = espera.future;
      final primero = gestor.registrar(forzar: true);
      final segundo = gestor.registrar(forzar: true);
      final tercero = gestor.registrar();
      // Those who asked meanwhile share the one that runs after the first.
      expect(identical(segundo, tercero), isTrue);
      espera.complete();
      final resultados = await Future.wait([primero, segundo, tercero]);
      await tester.pumpAndSettle();
      expect(push.maxTokensALaVez, 1);
      expect(dispositivos.registrados, hasLength(3));
      expect(resultados, everyElement(RecepcionPush.activa));
      expect(c.read(recepcionPushProvider), RecepcionPush.activa);
    });

    testWidgets(
      'quien pide registrar durante otro registro recibe el resultado del siguiente',
      (tester) async {
        // The web token exists only once the permission was granted: a registration that started
        // before must not answer «Activar notificaciones».
        push.tokenActual = null;
        await abrir(
          tester,
          entorno: const EntornoNavegador(esWeb: true, instalada: true),
        );
        final gestor = ProviderScope.containerOf(
          tester.element(find.byType(PantallaInicio)),
        ).read(gestorPushProvider);
        final espera = Completer<void>();
        push.esperaToken = espera.future;
        final antes = gestor.registrar();
        final despues = gestor.registrar(forzar: true);
        // The first one already asked Firebase, before the permission was granted.
        await tester.pump();
        push.tokenActual = 'fcm-web';
        espera.complete();
        expect(await antes, RecepcionPush.sinToken);
        expect(await despues, RecepcionPush.activa);
        await tester.pumpAndSettle();
        expect(dispositivos.registrados, ['fcm-web|ANDROID']);
      },
    );

    testWidgets('quita del backend el token que el celular ya no usa', (
      tester,
    ) async {
      await abrir(tester);
      push.renovar('fcm-2');
      await tester.pumpAndSettle();
      expect(dispositivos.registrados, ['fcm-1|ANDROID', 'fcm-2|ANDROID']);
      expect(dispositivos.eliminados, ['fcm-1|null']);
    });

    testWidgets('al volver a la app registra el celular otra vez', (
      tester,
    ) async {
      await abrir(tester);
      await volverALaApp(tester);
      expect(dispositivos.registrados, ['fcm-1|ANDROID', 'fcm-1|ANDROID']);
      // It first asked the backend whether it still sends to this phone.
      expect(dispositivos.consultados, ['d-fcm-1']);
    });

    testWidgets(
      'si el backend ya no envía a este celular, pide otro token y lo registra',
      (tester) async {
        await abrir(tester);
        dispositivos.inactivos.add('d-fcm-1');
        push.tokenTrasBorrar = 'fcm-2';
        await volverALaApp(tester);
        expect(push.tokensBorrados, 1);
        expect(dispositivos.registrados.last, 'fcm-2|ANDROID');
        expect(dispositivos.eliminados, ['fcm-1|null']);
        expect(find.text('Este celular no recibe las alertas'), findsNothing);
      },
    );

    testWidgets(
      'si no consigue otro token, avisa que este celular no recibe las alertas',
      (tester) async {
        await abrir(tester);
        dispositivos.inactivos.add('d-fcm-1');
        push.tokenTrasBorrar = 'fcm-1';
        await volverALaApp(tester);
        expect(find.text('Este celular no recibe las alertas'), findsOneWidget);
      },
    );

    testWidgets('un error de Firebase al pedir el token no se calla', (
      tester,
    ) async {
      push.errorToken = Exception('messaging/token-subscribe-failed');
      await abrir(tester);
      expect(dispositivos.registrados, isEmpty);
      expect(find.text('Este celular no recibe las alertas'), findsOneWidget);
    });

    testWidgets('al cerrar sesión deja de recibir alertas en este celular', (
      tester,
    ) async {
      await abrir(tester);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(PantallaInicio)),
      );
      await c.read(sesionControllerProvider.notifier).cerrar();
      await tester.pumpAndSettle();
      expect(dispositivos.eliminados, ['fcm-1|acceso-1']);
    });

    testWidgets('tocar la notificación de la cámara abre su detalle', (
      tester,
    ) async {
      await abrir(tester);
      push.tocar(
        const MensajePush(
          tipo: TipoPush.camaraDesconectada,
          camaraId: 'c1',
          habitacion: 'Sala',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cámara · Sala'), findsOneWidget);
    });

    testWidgets(
      'una notificación que abrió la app cerrada lleva a su pantalla',
      (tester) async {
        push.mensajeInicial = const MensajePush(tipo: TipoPush.datosEliminados);
        await abrir(tester, ubicacion: Rutas.arranque);
        expect(find.text('Privacidad'), findsOneWidget);
      },
    );

    testWidgets('con la app abierta, la desconexión se avisa en la app', (
      tester,
    ) async {
      await abrir(tester);
      push.recibir(
        const MensajePush(
          tipo: TipoPush.camaraDesconectada,
          camaraId: 'c1',
          habitacion: 'Sala',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('La cámara de la Sala se desconectó'), findsOneWidget);
      await tester.tap(find.text('La cámara de la Sala se desconectó'));
      await tester.pumpAndSettle();
      expect(find.text('Cámara · Sala'), findsOneWidget);
    });
  });

  group('DispositivosRepositorioApi', () {
    ProviderContainer contenedor(AdaptadorFalso http) {
      final c = ProviderContainer(
        overrides: [
          almacenSesionProvider.overrideWithValue(
            AlmacenSesionMemoria(sesionTitular),
          ),
          adaptadorHttpProvider.overrideWithValue(http),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test(
      'POST /api/dispositivos devuelve el Dispositivo del contrato',
      () async {
        final http = AdaptadorFalso()
          ..cuando(
            'POST',
            '/api/dispositivos',
            const Respuesta(201, {
              'id': 'd-1',
              'plataforma': 'ANDROID',
              'activo': true,
              'vistoEn': '2026-10-10T15:00:00Z',
              'desactivadoEn': null,
            }),
          );
        final d = await contenedor(http)
            .read(dispositivosRepositorioProvider)
            .registrar(tokenPush: 'fcm-1', plataforma: 'ANDROID');
        expect(d.id, 'd-1');
        expect(d.activo, isTrue);
        expect(d.vistoEn, isNotNull);
      },
    );

    test('un backend anterior a 0.3.1 responde sin cuerpo', () async {
      final http = AdaptadorFalso()
        ..cuando('POST', '/api/dispositivos', const Respuesta(201));
      final d = await contenedor(http)
          .read(dispositivosRepositorioProvider)
          .registrar(tokenPush: 'fcm-1', plataforma: 'ANDROID');
      expect(d.id, isNull);
      expect(d.activo, isTrue);
    });

    test(
      'GET /api/dispositivos/{id}: activo, inactivo o desconocido',
      () async {
        final http = AdaptadorFalso()
          ..cuando(
            'GET',
            '/api/dispositivos/d-1',
            const Respuesta(200, {
              'id': 'd-1',
              'plataforma': 'WEB',
              'activo': false,
              'vistoEn': '2026-10-10T15:00:00Z',
              'desactivadoEn': '2026-10-10T15:05:00Z',
            }),
          )
          ..cuando(
            'GET',
            '/api/dispositivos/d-2',
            Respuesta.problema(404, 'DISPOSITIVO_NO_ENCONTRADO'),
          );
        final repo = contenedor(http).read(dispositivosRepositorioProvider);
        final d = await repo.consultar('d-1');
        expect(d!.activo, isFalse);
        expect(d.desactivadoEn, isNotNull);
        expect(await repo.consultar('d-2'), isNull);
      },
    );

    test(
      'POST /api/dispositivos y DELETE /api/dispositivos/{tokenPush}',
      () async {
        final http = AdaptadorFalso()
          ..cuando('POST', '/api/dispositivos', const Respuesta(201))
          ..cuando('DELETE', '/api/dispositivos/fcm-1', const Respuesta(204));
        final c = ProviderContainer(
          overrides: [
            almacenSesionProvider.overrideWithValue(
              AlmacenSesionMemoria(sesionTitular),
            ),
            adaptadorHttpProvider.overrideWithValue(http),
          ],
        );
        addTearDown(c.dispose);
        final repo = c.read(dispositivosRepositorioProvider);
        await repo.registrar(tokenPush: 'fcm-1', plataforma: 'IOS');
        await repo.eliminar('fcm-1', tokenAcceso: 'viejo');
        expect(http.peticiones.first.data, {
          'tokenPush': 'fcm-1',
          'plataforma': 'IOS',
        });
        expect(http.peticiones.last.headers['Authorization'], 'Bearer viejo');
      },
    );
  });
}
