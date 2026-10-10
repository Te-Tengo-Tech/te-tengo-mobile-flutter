import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/botones.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/hogar/domain/hogar.dart';
import 'package:te_tengo/features/hogar/presentation/pantallas_privacidad.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import 'hogar_falso.dart';

/// Pumps frames for [tiempo]: the deletion spinner never lets the screen settle.
Future<void> pasar(WidgetTester tester, Duration tiempo) async {
  const paso = Duration(milliseconds: 100);
  for (var t = Duration.zero; t < tiempo; t += paso) {
    await tester.pump(paso);
  }
}

/// The app goes to the background (the PWA's window is hidden) and comes back.
void ocultar(WidgetTester tester) {
  for (final estado in [AppLifecycleState.inactive, AppLifecycleState.hidden]) {
    tester.binding.handleAppLifecycleStateChanged(estado);
  }
}

void mostrar(WidgetTester tester) {
  for (final estado in [
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(estado);
  }
}

void main() {
  late HogarRepositorioFalso hogar;
  late NotificacionesPushFalsas push;

  late AlertasRepositorioFalso alertas;

  Future<void> abrir(
    WidgetTester tester, {
    Sesion sesion = sesionTitular,
    String ubicacion = Rutas.privacidad,
    bool asentar = true,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        push: push,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(hogar),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(alertas),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 50)),
        ],
      ),
    );
    if (asentar) {
      await tester.pumpAndSettle();
    } else {
      await pasar(tester, const Duration(milliseconds: 500));
    }
  }

  setUp(() {
    hogar = HogarRepositorioFalso();
    push = NotificacionesPushFalsas();
    alertas = AlertasRepositorioFalso([
      caidaSala(id: 'h1', estado: EstadoAlerta.atendida),
      caidaSala(
        id: 'h2',
        estado: EstadoAlerta.atendida,
        clip: EstadoClip.eliminado,
      ),
      caidaSala(id: 'h3', estado: EstadoAlerta.falsaAlarma),
    ]);
  });

  /// Revokes from Privacidad and stays on the deletion screen, whose spinner never settles.
  Future<void> revocar(WidgetTester tester) async {
    await tocar(tester, find.text('Revocar consentimiento'));
    await tester.tap(find.text('Sí, revocar y eliminar'));
    await pasar(tester, const Duration(seconds: 1));
  }

  /// A backend 0.3.4 or later: `eliminacion` in `GET /api/hogar`, `clips` in the `202`.
  void backendConEliminacion({int clips = 2}) {
    hogar
      ..informaEliminacion = true
      ..clipsAlRevocar = clips
      ..eliminacion = Eliminacion(
        terminada: false,
        clips: clips,
        programadaEn: DateTime(2026, 9, 23, 10, 50),
      );
  }

  void eliminacionTerminada({int clips = 2}) => hogar.eliminacion = Eliminacion(
    terminada: true,
    clips: clips,
    programadaEn: DateTime(2026, 9, 23, 10, 50),
    terminadaEn: DateTime(2026, 9, 23, 10, 51),
  );

  void esperaEliminando(String clips) {
    expect(find.text('Revocando el consentimiento'), findsOneWidget);
    expect(find.text('Eliminando las grabaciones…'), findsOneWidget);
    expect(find.text(clips), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
  }

  void esperaTerminada(WidgetTester tester, String clips) {
    expect(find.text('Consentimiento revocado'), findsOneWidget);
    expect(find.text('Grabaciones eliminadas'), findsOneWidget);
    expect(find.textContaining(clips, findRichText: true), findsOneWidget);
    expect(find.text('Enviada'), findsOneWidget);
    expect(
      tester
          .widget<Boton>(find.widgetWithText(Boton, 'Volver al inicio'))
          .alPresionar,
      isNotNull,
    );
  }

  testWidgets(
    'la privacidad muestra la constancia y cómo se cuidan los datos',
    (tester) async {
      await abrir(tester);
      expect(find.text('Constancia de consentimiento'), findsOneWidget);
      expect(find.text('3 ago 2026'), findsOneWidget);
      await verHasta(tester, find.text('Reconocimiento facial'));
      expect(
        find.text('Se guardan 30 días y luego se eliminan'),
        findsOneWidget,
      );
      expect(find.text('No se usa'), findsOneWidget);
      expect(
        find.text('Registro de accesos a la vista en vivo'),
        findsOneWidget,
      );
      await verHasta(tester, find.text('Revocar consentimiento'));
      expect(
        find.textContaining('privacidad@tetengo.pe', findRichText: true),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'CA-09.2: si no confirma, el consentimiento y la captura siguen activos',
    (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('Revocar consentimiento'));
      expect(find.text('¿Revocar el consentimiento?'), findsOneWidget);
      expect(
        find.text(
          'La cámara de la Sala dejará de capturar, nadie recibirá más alertas y '
          'se borrarán las grabaciones. No se puede deshacer.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancelar, mantenerlo'));
      await tester.pumpAndSettle();
      expect(hogar.revocaciones, 0);
      expect(find.text('Tu consentimiento sigue vigente'), findsOneWidget);
      expect(find.text('La cámara sigue detectando caídas.'), findsOneWidget);
      expect(find.text('Revocar consentimiento'), findsOneWidget);
    },
  );

  testWidgets(
    'CA-09.1 y CA-09.3: revoca, elimina las grabaciones y lo confirma',
    (tester) async {
      await abrir(tester);
      await tocar(tester, find.text('Revocar consentimiento'));
      await tester.tap(find.text('Sí, revocar y eliminar'));
      // The deletion spinner keeps animating: pump frames instead of settling.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(hogar.revocaciones, 1);
      expect(find.text('Revocando el consentimiento'), findsOneWidget);
      expect(
        find.text('No cierres la app. Esto toma unos segundos.'),
        findsOneWidget,
      );
      expect(find.text('Captura detenida'), findsOneWidget);
      expect(
        find.textContaining(
          'La cámara de la Sala dejó de capturar a las 10:50',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Eliminando las grabaciones…'), findsOneWidget);
      expect(find.text('2 clips guardados'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(
        tester
            .widget<Boton>(find.widgetWithText(Boton, 'Volver al inicio'))
            .alPresionar,
        isNull,
      );

      push.recibir(
        MensajePush(
          tipo: TipoPush.datosEliminados,
          ocurridaEn: DateTime(2026, 9, 23, 10, 51),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Consentimiento revocado'), findsOneWidget);
      expect(
        find.text(
          'La captura se detuvo y las grabaciones se eliminaron. Te enviamos la constancia a carmen.huaman@gmail.com.',
        ),
        findsOneWidget,
      );
      expect(find.text('Grabaciones eliminadas'), findsOneWidget);
      expect(
        find.textContaining(
          '2 clips borrados de forma permanente a las 10:51',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Enviada'), findsOneWidget);
      await tocar(tester, find.text('Volver al inicio'));
      expect(find.text('Detección detenida'), findsOneWidget);
      expect(
        find.text('Revocaste el consentimiento. No hay captura ni alertas.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '404 SIN_CONSENTIMIENTO: si ya estaba revocado, muestra que no hay consentimiento',
    (tester) async {
      await abrir(tester);
      expect(find.text('Constancia de consentimiento'), findsOneWidget);
      // Revoked meanwhile from another phone: the backend has no current consent.
      final c = hogar.hogar.consentimiento!;
      hogar
        ..errorRevocar = const ProblemaApi(
          codigo: 'SIN_CONSENTIMIENTO',
          detalle: 'No hay un consentimiento vigente.',
          estado: 404,
        )
        ..hogar = Hogar(
          hogarId: 'h-1',
          adultoMayor: rosa,
          rol: Rol.titular,
          consentimiento: Consentimiento(
            otorgadoEn: c.otorgadoEn,
            otorgadoPor: c.otorgadoPor,
            registradoPor: c.registradoPor,
            vistaEnVivoAceptada: true,
            vigente: false,
          ),
        );
      await tocar(tester, find.text('Revocar consentimiento'));
      await tester.tap(find.text('Sí, revocar y eliminar'));
      await tester.pumpAndSettle();
      expect(hogar.revocaciones, 1);
      expect(find.text('Revocando el consentimiento'), findsNothing);
      await tester.drag(
        find.byType(Scrollable).hitTestable().first,
        const Offset(0, 3000),
      );
      await tester.pumpAndSettle();
      expect(find.text('No hay un consentimiento vigente.'), findsNothing);
      expect(find.text('Sin consentimiento'), findsOneWidget);
      expect(
        find.text(
          'Revocado. La cámara no captura y las grabaciones fueron eliminadas.',
        ),
        findsOneWidget,
      );
      expect(find.text('Constancia de consentimiento'), findsNothing);
      expect(find.text('Revocar consentimiento'), findsNothing);
    },
  );

  testWidgets('un familiar invitado no puede revocar', (tester) async {
    await abrir(tester, sesion: sesionInvitado);
    await verHasta(
      tester,
      find.text(
        'Solo Carmen (titular) puede revocar el consentimiento. Si Rosa quiere retirarlo, avísale.',
      ),
    );
    expect(find.text('Revocar consentimiento'), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('la eliminación termina por la consulta aunque el push no llegue', (
    tester,
  ) async {
    backendConEliminacion();
    await abrir(tester);
    await revocar(tester);
    esperaEliminando('2 clips guardados');
    final antes = hogar.consultas;
    await pasar(tester, const Duration(seconds: 7));
    // Every 3 s while visible.
    expect(hogar.consultas - antes, greaterThanOrEqualTo(2));
    esperaEliminando('2 clips guardados');

    // The push DATOS_ELIMINADOS never reached the app (PWA hidden, app in the background).
    eliminacionTerminada();
    await pasar(tester, const Duration(seconds: 3));
    esperaTerminada(tester, '2 clips borrados de forma permanente a las 10:51');

    // Done: no more questions, and a late push changes nothing.
    final alTerminar = hogar.consultas;
    push.recibir(
      MensajePush(
        tipo: TipoPush.datosEliminados,
        ocurridaEn: DateTime(2026, 9, 23, 10, 52),
      ),
    );
    await pasar(tester, const Duration(seconds: 7));
    expect(hogar.consultas - alTerminar, lessThanOrEqualTo(1));
    esperaTerminada(tester, '2 clips borrados de forma permanente a las 10:51');
  });

  testWidgets(
    'en la web, el push que el service worker recibió con la ventana oculta la termina',
    (tester) async {
      final web = NotificacionesPushWebFalsas();
      push = web;
      await abrir(tester);
      await revocar(tester);
      esperaEliminando('2 clips guardados');
      web.trabajador.add({
        'tipo': 'DATOS_ELIMINADOS',
        'ocurridaEn': DateTime(2026, 9, 23, 10, 51).toUtc().toIso8601String(),
      });
      await pasar(tester, const Duration(milliseconds: 300));
      esperaTerminada(
        tester,
        '2 clips borrados de forma permanente a las 10:51',
      );
      // Firebase's copy, once the window is visible again, is the same push: handled once.
      web.firebase.add(
        MensajePush(
          tipo: TipoPush.datosEliminados,
          ocurridaEn: DateTime(2026, 9, 23, 10, 51),
        ),
      );
      await pasar(tester, const Duration(milliseconds: 300));
      esperaTerminada(
        tester,
        '2 clips borrados de forma permanente a las 10:51',
      );
    },
  );

  testWidgets('el push termina la eliminación antes que la consulta', (
    tester,
  ) async {
    backendConEliminacion();
    await abrir(tester);
    await revocar(tester);
    esperaEliminando('2 clips guardados');
    push.recibir(
      MensajePush(
        tipo: TipoPush.datosEliminados,
        ocurridaEn: DateTime(2026, 9, 23, 10, 51),
      ),
    );
    await pasar(tester, const Duration(milliseconds: 300));
    esperaTerminada(tester, '2 clips borrados de forma permanente a las 10:51');
    // The backend says the same afterwards: nothing changes.
    eliminacionTerminada();
    await pasar(tester, const Duration(seconds: 4));
    esperaTerminada(tester, '2 clips borrados de forma permanente a las 10:51');
  });

  testWidgets('al volver a la app consulta la eliminación de inmediato', (
    tester,
  ) async {
    backendConEliminacion();
    await abrir(tester);
    await revocar(tester);
    ocultar(tester);
    final oculta = hogar.consultas;
    await pasar(tester, const Duration(seconds: 7));
    // Hidden: no questions.
    expect(hogar.consultas, oculta);
    eliminacionTerminada();
    mostrar(tester);
    await pasar(tester, const Duration(milliseconds: 300));
    expect(hogar.consultas, greaterThan(oculta));
    esperaTerminada(tester, '2 clips borrados de forma permanente a las 10:51');
  });

  testWidgets(
    'abierta tras reiniciar la app, la reconstruye con lo que dice el backend',
    (tester) async {
      backendConEliminacion(clips: 8);
      hogar.hogar = hogarDeRosa(consentimiento: false);
      await abrir(tester, ubicacion: Rutas.revocado, asentar: false);
      esperaEliminando('8 clips guardados');
      expect(
        find.textContaining(
          'La cámara de la Sala dejó de capturar a las 10:50',
          findRichText: true,
        ),
        findsOneWidget,
      );
      eliminacionTerminada(clips: 8);
      await pasar(tester, const Duration(seconds: 3));
      esperaTerminada(
        tester,
        '8 clips borrados de forma permanente a las 10:51',
      );
    },
  );

  testWidgets('abierta tras reiniciar, con la eliminación ya terminada', (
    tester,
  ) async {
    backendConEliminacion();
    eliminacionTerminada();
    hogar.hogar = hogarDeRosa(consentimiento: false);
    await abrir(tester, ubicacion: Rutas.revocado);
    esperaTerminada(tester, '2 clips borrados de forma permanente a las 10:51');
    await tocar(tester, find.text('Volver al inicio'));
    expect(find.text('Detección detenida'), findsOneWidget);
  });

  testWidgets(
    'con un backend anterior a 0.3.4 deja de consultar y espera el push',
    (tester) async {
      await abrir(tester);
      await revocar(tester);
      final antes = hogar.consultas;
      await pasar(tester, const Duration(seconds: 10));
      expect(hogar.consultas - antes, lessThanOrEqualTo(1));
      esperaEliminando('2 clips guardados');
      push.recibir(
        MensajePush(
          tipo: TipoPush.datosEliminados,
          ocurridaEn: DateTime(2026, 9, 23, 10, 51),
        ),
      );
      await pasar(tester, const Duration(milliseconds: 300));
      esperaTerminada(
        tester,
        '2 clips borrados de forma permanente a las 10:51',
      );
    },
  );

  testWidgets('si la consulta falla, la reintenta en la siguiente vuelta', (
    tester,
  ) async {
    backendConEliminacion();
    await abrir(tester);
    await revocar(tester);
    hogar.errorObtener = const ProblemaApi(
      codigo: ProblemaApi.sinConexion,
      detalle: 'Sin conexión.',
    );
    eliminacionTerminada();
    await pasar(tester, const Duration(seconds: 4));
    esperaEliminando('2 clips guardados');
    hogar.errorObtener = null;
    await pasar(tester, const Duration(seconds: 3));
    esperaTerminada(tester, '2 clips borrados de forma permanente a las 10:51');
  });

  testWidgets('muestra los clips que el backend dice que elimina', (
    tester,
  ) async {
    // The 202 counts every stored recording, also those the history no longer lists as available.
    backendConEliminacion(clips: 2);
    hogar.clipsAlRevocar = 5;
    await abrir(tester);
    await revocar(tester);
    esperaEliminando('5 clips guardados');
  });

  testWidgets(
    'con un backend anterior cuenta los clips por páginas de hasta 100',
    (tester) async {
      // `tamano: 200` was a 400 VALIDACION that the screen showed as «0 clips».
      alertas.alertas = [
        for (var i = 0; i < 150; i++)
          caidaSala(
            id: 'c$i',
            estado: EstadoAlerta.atendida,
            ocurridaEn: DateTime(2026, 9, 1).add(Duration(hours: i)),
          ),
        caidaSala(
          id: 'borrado',
          estado: EstadoAlerta.atendida,
          clip: EstadoClip.eliminado,
        ),
      ];
      await abrir(tester);
      await revocar(tester);
      esperaEliminando('150 clips guardados');
      expect(
        alertas.filtros.every((f) => f.tamano <= FiltroAlertas.tamanoMaximo),
        isTrue,
      );
      expect(alertas.filtros.map((f) => f.pagina), containsAll([0, 1]));
    },
  );

  testWidgets(
    'si no puede contar los clips no muestra «0 clips», sino ninguna cifra',
    (tester) async {
      alertas.errorListar = const ProblemaApi(
        codigo: 'VALIDACION',
        detalle: 'Revisa los datos.',
        estado: 400,
      );
      await abrir(tester);
      await revocar(tester);
      expect(find.text('Eliminando las grabaciones…'), findsOneWidget);
      expect(find.textContaining('clip'), findsNothing);
      push.recibir(
        MensajePush(
          tipo: TipoPush.datosEliminados,
          ocurridaEn: DateTime(2026, 9, 23, 10, 51),
        ),
      );
      await pasar(tester, const Duration(milliseconds: 300));
      expect(find.text('Grabaciones eliminadas'), findsOneWidget);
      expect(find.textContaining('clip', findRichText: true), findsNothing);
    },
  );

  test('contarClipsGuardados nunca pide más de 100 por página', () async {
    final repositorio = AlertasRepositorioFalso([
      for (var i = 0; i < 230; i++)
        caidaSala(
          id: 'c$i',
          clip: i.isEven ? EstadoClip.disponible : EstadoClip.noDisponible,
          ocurridaEn: DateTime(2026, 9, 1).add(Duration(hours: i)),
        ),
    ]);
    expect(await contarClipsGuardados(repositorio), 115);
    expect(repositorio.filtros.map((f) => (f.pagina, f.tamano)), [
      (0, 100),
      (1, 100),
      (2, 100),
    ]);
  });

  test('el falso rechaza tamano mayor que 100, como el backend', () async {
    await expectLater(
      AlertasRepositorioFalso().listar(const FiltroAlertas(tamano: 200)),
      throwsA(
        isA<ProblemaApi>().having((p) => p.codigo, 'codigo', 'VALIDACION'),
      ),
    );
  });

  test(
    'GET /api/hogar lee eliminacion; un backend anterior no la envía',
    () async {
      final base = {
        'hogarId': 'h-1',
        'adultoMayor': {'nombre': 'Rosa Huamán', 'direccion': ''},
        'rol': 'TITULAR',
        'consentimiento': null,
        'dispositivosActivos': 1,
      };
      final anterior = Hogar.desdeJson(base);
      expect(anterior.informaEliminacion, isFalse);
      expect(anterior.eliminacion, isNull);

      final sinRevocar = Hogar.desdeJson({...base, 'eliminacion': null});
      expect(sinRevocar.informaEliminacion, isTrue);
      expect(sinRevocar.eliminacion, isNull);

      final terminada = Hogar.desdeJson({
        ...base,
        'eliminacion': {
          'estado': 'TERMINADA',
          'clips': 2,
          'programadaEn': '2026-10-10T17:34:12Z',
          'terminadaEn': '2026-10-10T17:35:00Z',
        },
      }).eliminacion!;
      expect(terminada.terminada, isTrue);
      expect(terminada.clips, 2);
      expect(
        terminada.programadaEn,
        DateTime.utc(2026, 10, 10, 17, 34, 12).toLocal(),
      );
      expect(
        terminada.terminadaEn,
        DateTime.utc(2026, 10, 10, 17, 35).toLocal(),
      );

      final programada = Hogar.desdeJson({
        ...base,
        'eliminacion': {
          'estado': 'PROGRAMADA',
          'clips': 2,
          'programadaEn': '2026-10-10T17:34:12Z',
          'terminadaEn': null,
        },
      }).eliminacion!;
      expect(programada.terminada, isFalse);
      expect(programada.terminadaEn, isNull);
    },
  );

  test('DELETE /api/hogar/consentimiento devuelve los clips', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'DELETE',
        '/api/hogar/consentimiento',
        const Respuesta(202, {'eliminacionProgramada': true, 'clips': 2}),
      );
    final c = ProviderContainer(
      overrides: [
        almacenSesionProvider.overrideWithValue(
          AlmacenSesionMemoria(sesionTitular),
        ),
        adaptadorHttpProvider.overrideWithValue(http),
      ],
    );
    addTearDown(c.dispose);
    expect(await c.read(hogarRepositorioProvider).revocarConsentimiento(), 2);
  });

  test('DELETE /api/hogar/consentimiento', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'DELETE',
        '/api/hogar/consentimiento',
        const Respuesta(202, {'eliminacionProgramada': true}),
      );
    final c = ProviderContainer(
      overrides: [
        almacenSesionProvider.overrideWithValue(
          AlmacenSesionMemoria(sesionTitular),
        ),
        adaptadorHttpProvider.overrideWithValue(http),
      ],
    );
    addTearDown(c.dispose);
    // A backend older than 0.3.4 does not say how many clips.
    expect(
      await c.read(hogarRepositorioProvider).revocarConsentimiento(),
      isNull,
    );
    expect(http.peticiones.single.method, 'DELETE');
  });
}
