import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/push.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/movimientos/data/movimientos_repositorio.dart';
import 'package:te_tengo/features/movimientos/domain/movimientos.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../pcs/pcs_falso.dart';
import 'movimientos_falso.dart';

void main() {
  late MovimientosRepositorioFalso movimientos;
  late PcsRepositorioFalso pcs;
  late NotificacionesPushFalsas push;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    bool consentimiento = true,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        push: push,
        overrides: [
          movimientosRepositorioProvider.overrideWithValue(movimientos),
          pcsRepositorioProvider.overrideWithValue(pcs),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso([camaraSalaPc]),
          ),
          hogarRepositorioProvider.overrideWithValue(
            HogarRepositorioFalso(hogarDeRosa(consentimiento: consentimiento)),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> marcarPermiso(WidgetTester tester) => tocar(
    tester,
    find.text('Rosa aceptó que se guarden sus movimientos para estos fines.'),
  );

  setUp(() {
    movimientos = MovimientosRepositorioFalso();
    pcs = PcsRepositorioFalso();
    push = NotificacionesPushFalsas(tokenActual: 'fcm-prueba');
  });

  group('Privacidad', () {
    testWidgets('CA-35.3: sin el permiso, la nube está desactivada', (
      tester,
    ) async {
      await abrir(tester, Rutas.privacidad);
      await verHasta(tester, find.text('Guardar movimientos'));
      expect(find.text('No autorizado'), findsOneWidget);
      expect(find.text('Desactivado · falta el permiso'), findsOneWidget);
    });

    testWidgets('con el permiso dice desde cuándo y el plazo', (tester) async {
      movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30);
      await abrir(tester, Rutas.privacidad);
      await verHasta(tester, find.text('Guardar movimientos'));
      expect(find.text('Vigente desde el 24 ago 2026'), findsOneWidget);
      expect(find.text('Se guardan 30 días'), findsOneWidget);
    });
  });

  group('Guardar movimientos', () {
    testWidgets('CA-35.1: explica para qué, qué, dónde, cuánto y quién', (
      tester,
    ) async {
      await abrir(tester, Rutas.movimientos);
      expect(find.text('¿Guardamos los movimientos de Rosa?'), findsOneWidget);
      expect(
        find.text('Es opcional: las alertas funcionan igual.'),
        findsOneWidget,
      );
      for (final t in ['Para qué', 'Qué guardamos', 'Dónde', 'Cuánto tiempo']) {
        expect(find.text(t), findsOneWidget);
      }
      await tocar(tester, find.text('Dónde'));
      expect(
        find.text(
          'En la PC de la casa y, si lo eliges, en la nube: Cloudflare R2, con '
          'servidores fuera del Perú. Guardarlos ahí es un flujo transfronterizo '
          'de datos personales.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('CA-35.2: registra quién lo dio y la versión del texto', (
      tester,
    ) async {
      await abrir(tester, Rutas.movimientos);
      await tocar(tester, find.text('Registrar el permiso'));
      expect(movimientos.registros, isEmpty);
      await marcarPermiso(tester);
      await tocar(tester, find.text('Registrar el permiso'));
      expect(movimientos.registros, [('Rosa Huamán', false, '2')]);
      expect(find.text('Permiso registrado'), findsOneWidget);
      expect(find.text('Permiso para guardar movimientos'), findsOneWidget);
      expect(find.text('Carmen Huamán'), findsOneWidget);
      expect(find.text('Versión del texto'), findsOneWidget);
      expect(
        find.text(
          'Constancia exigida por la Ley N.° 29733 para datos sensibles.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('lo puede dar su representante, con su nombre', (tester) async {
      await abrir(tester, Rutas.movimientos);
      await tocar(tester, find.text('Su representante'));
      await marcarPermiso(tester);
      await tocar(tester, find.text('Registrar el permiso'));
      expect(find.text('Escribe el nombre del representante.'), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: find.widgetWithText(CampoTexto, 'Nombre del representante'),
          matching: find.byType(TextField),
        ),
        'Jorge Huamán',
      );
      await tocar(tester, find.text('Registrar el permiso'));
      expect(movimientos.registros, [('Jorge Huamán', true, '2')]);
      expect(find.text('Jorge Huamán (representante)'), findsOneWidget);
    });

    testWidgets('sin internet no registra nada', (tester) async {
      movimientos.errorRegistrar = const ProblemaApi(
        codigo: ProblemaApi.sinConexion,
        detalle: 'Sin conexión',
      );
      await abrir(tester, Rutas.movimientos);
      await marcarPermiso(tester);
      await tocar(tester, find.text('Registrar el permiso'));
      expect(find.text('No pudimos registrar el permiso'), findsOneWidget);
      expect(find.text('Nada se guardó.'), findsOneWidget);
    });

    testWidgets('CA-35.1: sin el consentimiento de monitoreo, primero ese', (
      tester,
    ) async {
      await abrir(tester, Rutas.movimientos, consentimiento: false);
      expect(find.text('Falta el consentimiento'), findsOneWidget);
      await verHasta(tester, find.text('Registrar el permiso'));
      await tester.tap(find.text('Registrar el permiso'), warnIfMissed: false);
      await tester.pump();
      expect(movimientos.registros, isEmpty);
    });

    testWidgets('el familiar invitado lo lee sin poder registrarlo', (
      tester,
    ) async {
      await abrir(tester, Rutas.movimientos, sesion: sesionInvitado);
      await verHasta(
        tester,
        find.text('Solo Carmen (titular) puede registrar este permiso.'),
      );
      expect(find.text('Registrar el permiso'), findsNothing);
    });

    testWidgets('el documento completo dice cómo retirarlo', (tester) async {
      await abrir(tester, Rutas.documentoMovimientos);
      expect(find.text('Guardar movimientos'), findsOneWidget);
      await verHasta(tester, find.text('Cómo retirarlo'));
      expect(find.text('Cómo retirarlo'), findsOneWidget);
    });

    testWidgets(
      'el texto vigente nombra la nube y el flujo transfronterizo (versión 2)',
      (tester) async {
        await abrir(tester, Rutas.documentoMovimientos);
        await verHasta(tester, find.textContaining('Cloudflare R2'));
        expect(
          find.textContaining('flujo transfronterizo de datos personales'),
          findsOneWidget,
        );
        await verHasta(tester, find.text('Versión del texto: 2.'));
      },
    );

    testWidgets('un permiso de la versión 1 conserva su texto', (tester) async {
      movimientos = MovimientosRepositorioFalso(vigente: true);
      await abrir(tester, Rutas.documentoMovimientos);
      await verHasta(
        tester,
        find.text(
          'En la PC de la casa y, si lo eliges, en la nube (servidores fuera '
          'del Perú).',
        ),
      );
      expect(find.textContaining('Cloudflare R2'), findsNothing);
      await verHasta(tester, find.text('Versión del texto: 1.'));
    });
  });

  group('Dejar de guardar', () {
    setUp(
      () => movimientos = MovimientosRepositorioFalso(
        vigente: true,
        retencion: 30,
      ),
    );

    testWidgets('CA-35.4: pide confirmar, borra la nube y avisa al terminar', (
      tester,
    ) async {
      await abrir(tester, Rutas.movimientos);
      await tocar(tester, find.text('Dejar de guardar movimientos'));
      expect(
        find.text('¿Dejar de guardar los movimientos de Rosa?'),
        findsOneWidget,
      );
      await tocar(tester, find.text('Cancelar'));
      expect(movimientos.revocaciones, 0);
      await tocar(tester, find.text('Dejar de guardar movimientos'));
      // The spinner of the deletion never settles: pump instead.
      await tester.tap(find.text('Dejar de guardar'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(movimientos.revocaciones, 1);
      expect(find.text('Borrando los movimientos de la nube…'), findsWidgets);
      expect(find.text('Preguntará si también se borran ahí.'), findsOneWidget);
      // The API finished meanwhile: the screen asks for it.
      movimientos.eliminacion = EliminacionMovimientos(
        terminada: true,
        archivos: 3,
        programadaEn: DateTime(2026, 9, 23, 10, 42),
        terminadaEn: DateTime(2026, 9, 23, 10, 43),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(
        find.text('Listo. Ya no guardamos los movimientos de Rosa.'),
        findsOneWidget,
      );
      expect(find.text('Movimientos borrados de la nube'), findsOneWidget);
      await tocar(tester, find.text('Volver a Privacidad'));
      expect(find.text('Privacidad'), findsOneWidget);
    });

    testWidgets('CA-35.4: el aviso MOVIMIENTOS_ELIMINADOS también lo termina', (
      tester,
    ) async {
      await abrir(tester, Rutas.movimientos);
      await tocar(tester, find.text('Dejar de guardar movimientos'));
      await tester.tap(find.text('Dejar de guardar'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      push.recibir(
        MensajePush(
          tipo: TipoPush.movimientosEliminados,
          ocurridaEn: DateTime.utc(2026, 9, 23, 15, 43),
        ),
      );
      await tester.pump();
      expect(
        find.text('Listo. Ya no guardamos los movimientos de Rosa.'),
        findsOneWidget,
      );
    });

    testWidgets('el familiar invitado no puede retirarlo', (tester) async {
      await abrir(tester, Rutas.movimientos, sesion: sesionInvitado);
      await verHasta(
        tester,
        find.text('Solo Carmen (titular) puede retirar este permiso.'),
      );
      expect(find.text('Dejar de guardar movimientos'), findsNothing);
    });

    test('tocar el aviso abre Privacidad', () {
      expect(
        rutaDePush(const MensajePush(tipo: TipoPush.movimientosEliminados)),
        Rutas.privacidad,
      );
    });
  });

  group('Movimientos en la nube', () {
    testWidgets('CA-37.1: desactivado hasta elegir un plazo', (tester) async {
      movimientos = MovimientosRepositorioFalso(vigente: true);
      await abrir(tester, Rutas.nube);
      expect(find.text('No guardar en la nube'), findsOneWidget);
      expect(find.text('1 año'), findsOneWidget);
      expect(find.text('Máximo recomendado'), findsOneWidget);
      expect(
        find.text('40 a 80 MB por cámara al día (estimado)'),
        findsOneWidget,
      );
      expect(find.text('Hay movimientos desde'), findsNothing);
      await tocar(tester, find.text('30 días'));
      expect(movimientos.retenciones, [30]);
      expect(find.text('Movimientos en la nube: 30 días'), findsOneWidget);
      expect(find.text('Hay movimientos desde'), findsOneWidget);
    });

    testWidgets('CA-37.4: acortar el plazo dice desde qué fecha borra', (
      tester,
    ) async {
      movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30);
      await abrir(tester, Rutas.nube);
      await tocar(tester, find.text('7 días'));
      expect(find.text('¿Guardar solo 7 días?'), findsOneWidget);
      expect(
        find.text(
          'Borraremos los movimientos anteriores al 16/09/2026. No se pueden '
          'recuperar.',
        ),
        findsOneWidget,
      );
      await tocar(tester, find.text('Cancelar'));
      expect(movimientos.retenciones, isEmpty);
      await tocar(tester, find.text('7 días'));
      await tocar(tester, find.text('Guardar 7 días'));
      expect(movimientos.retenciones, [7]);
    });

    testWidgets('dejar de guardar en la nube borra todo, tras confirmar', (
      tester,
    ) async {
      movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30);
      await abrir(tester, Rutas.nube);
      await tocar(tester, find.text('No guardar en la nube'));
      expect(find.text('¿Dejar de guardar en la nube?'), findsOneWidget);
      await tocar(tester, find.text('No guardar en la nube').last);
      expect(movimientos.retenciones, [null]);
      expect(find.text('Borramos los movimientos de la nube.'), findsOneWidget);
    });

    testWidgets('CA-35.3: sin el permiso, las opciones están desactivadas', (
      tester,
    ) async {
      await abrir(tester, Rutas.nube);
      expect(
        find.text('Falta el permiso de Rosa para guardar movimientos'),
        findsOneWidget,
      );
      await tocar(tester, find.text('30 días'));
      expect(movimientos.retenciones, isEmpty);
      await tocar(tester, find.text('Ver el permiso'));
      expect(find.text('¿Guardamos los movimientos de Rosa?'), findsOneWidget);
    });

    testWidgets('el familiar invitado lo ve sin poder cambiarlo', (
      tester,
    ) async {
      movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30);
      await abrir(tester, Rutas.nube, sesion: sesionInvitado);
      expect(find.text('Solo ver'), findsOneWidget);
      expect(
        find.text('Solo Carmen (titular) puede cambiar el plazo.'),
        findsOneWidget,
      );
      await tocar(tester, find.text('90 días'));
      expect(movimientos.retenciones, isEmpty);
    });

    testWidgets('sin internet no guarda el cambio', (tester) async {
      movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30)
        ..errorRetencion = const ProblemaApi(
          codigo: ProblemaApi.sinConexion,
          detalle: 'Sin conexión',
        );
      await abrir(tester, Rutas.nube);
      await tocar(tester, find.text('90 días'));
      expect(find.text('No pudimos guardar el cambio'), findsOneWidget);
    });

    testWidgets('CA-37.3: una PC sin conexión sube sus movimientos al volver', (
      tester,
    ) async {
      movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30);
      pcs.pcs = [pcSalaRosa(estado: EstadoConexion.desconectada)];
      await abrir(tester, Rutas.nube);
      await verHasta(
        tester,
        find.text('La PC Sala-Rosa subirá sus movimientos al reconectarse.'),
      );
    });
  });

  group('MovimientosRepositorioApi', () {
    late AdaptadorFalso http;
    late MovimientosRepositorio repo;

    setUp(() {
      http = AdaptadorFalso();
      final c = ProviderContainer(
        overrides: [
          almacenSesionProvider.overrideWithValue(
            AlmacenSesionMemoria(sesionTitular),
          ),
          adaptadorHttpProvider.overrideWithValue(http),
        ],
      );
      addTearDown(c.dispose);
      repo = c.read(movimientosRepositorioProvider);
    });

    const consentimientoJson = {
      'vigente': true,
      'versionTextoVigente': '1',
      'constancia': {
        'otorgadoEn': '2026-08-24T15:15:00Z',
        'otorgadoPor': 'Rosa Huamán',
        'representante': false,
        'registradoPor': {'id': 'u-carmen', 'nombre': 'Carmen Huamán'},
        'versionTexto': '1',
        'revocadoEn': null,
      },
      'eliminacion': null,
    };

    test('GET, POST y DELETE /api/hogar/consentimiento-movimientos', () async {
      http
        ..cuando(
          'GET',
          '/api/hogar/consentimiento-movimientos',
          const Respuesta(200, consentimientoJson),
        )
        ..cuando(
          'POST',
          '/api/hogar/consentimiento-movimientos',
          const Respuesta(201, consentimientoJson),
        )
        ..cuando(
          'DELETE',
          '/api/hogar/consentimiento-movimientos',
          const Respuesta(202, {'eliminacionProgramada': true, 'archivos': 12}),
        );
      final c = await repo.consentimiento();
      expect(c.vigente, isTrue);
      expect(c.constancia!.registradoPor, 'Carmen Huamán');
      await repo.registrar(
        otorgadoPor: 'Rosa Huamán',
        representante: false,
        versionTexto: '1',
      );
      expect(http.peticiones[1].data, {
        'otorgadoPor': 'Rosa Huamán',
        'representante': false,
        'aceptado': true,
        'versionTexto': '1',
      });
      expect(await repo.revocar(), 12);
    });

    test('GET y PUT /api/hogar/movimientos-en-la-nube', () async {
      const nube = {
        'retencionDias': 30,
        'opciones': [7, 30, 90, 365],
        'maximoRecomendadoDias': 365,
        'mbPorCamaraPorDia': {'minimo': 40, 'maximo': 80},
        'consentimientoVigente': true,
        'datosDesde': '2026-08-24T05:00:00Z',
        'archivos': 120,
        'tamanoBytes': 1000,
      };
      http
        ..cuando(
          'GET',
          '/api/hogar/movimientos-en-la-nube',
          const Respuesta(200, nube),
        )
        ..cuando(
          'PUT',
          '/api/hogar/movimientos-en-la-nube',
          const Respuesta(200, nube),
        );
      final n = await repo.nube();
      expect(n.retencionDias, 30);
      expect(n.mbMaximo, 80);
      await repo.cambiarRetencion(null);
      expect(http.peticiones.last.data, {'retencionDias': null});
    });
  });

  test('resumen del plazo', () {
    expect(resumenNube(null), 'Desactivado');
    expect(resumenNube(365), 'Se guardan 1 año');
    expect(textoPlazo(30), '30 días');
  });
}
