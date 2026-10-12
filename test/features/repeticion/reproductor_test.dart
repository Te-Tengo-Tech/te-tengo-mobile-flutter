import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/presentation/pantalla_camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/movimientos/data/fuente_fotogramas.dart';
import 'package:te_tengo/features/movimientos/data/movimientos_repositorio.dart';
import 'package:te_tengo/features/movimientos/domain/fotogramas.dart';
import 'package:te_tengo/features/movimientos/presentation/esqueleto.dart';
import 'package:te_tengo/features/repeticion/data/repeticiones_repositorio.dart';
import 'package:te_tengo/features/repeticion/domain/repeticion.dart';
import 'package:te_tengo/features/repeticion/presentation/reproductor_camara.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../movimientos/movimientos_falso.dart';
import 'repeticiones_falso.dart';

final _ahora = DateTime(2026, 9, 23, 10, 50);

/// A fall in the Sala at 10:41:52 that got up at 10:43, and an unstable movement at 10:30.
List<Alerta> _alertasDeHoy() => [
  caidaSala(
    id: 'a-caida',
    estado: EstadoAlerta.atendida,
    ocurridaEn: DateTime(2026, 9, 23, 10, 41, 52),
    recuperadaEn: DateTime(2026, 9, 23, 10, 43),
    atendidaPor: 'Carmen Huamán',
  ),
  caidaSala(
    id: 'a-inestable',
    tipo: TipoAlerta.movimientoInestable,
    estado: EstadoAlerta.atendida,
    ocurridaEn: DateTime(2026, 9, 23, 10, 30),
    atendidaPor: 'Carmen Huamán',
  ),
];

class _FuenteFalsa implements FuenteFotogramas {
  _FuenteFalsa({DateTime? desde, this.segundos = 600})
    : desde = desde ?? DateTime(2026, 9, 23, 10, 36);

  final DateTime desde;
  final int segundos;
  final cargadas = <String>[];
  final sha256 = <String?>[];

  @override
  Future<List<Fotograma>> cargar(String url, {String? sha256Esperado}) async {
    cargadas.add(url);
    sha256.add(sha256Esperado);
    return [
      for (var s = 0; s <= segundos; s++)
        Fotograma(
          en: desde.add(Duration(seconds: s)),
          puntos: List.filled(17, const Offset(0.5, 0.5)),
        ),
    ];
  }
}

void main() {
  late RepeticionesRepositorioFalso repeticiones;
  late MovimientosRepositorioFalso movimientos;
  late AlertasRepositorioFalso alertas;

  setUp(() {
    repeticiones = RepeticionesRepositorioFalso();
    movimientos = MovimientosRepositorioFalso(vigente: true, retencion: 30);
    alertas = AlertasRepositorioFalso(_alertasDeHoy());
  });

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    FuenteFotogramas? fuente,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          repeticionesRepositorioProvider.overrideWithValue(repeticiones),
          movimientosRepositorioProvider.overrideWithValue(movimientos),
          alertasRepositorioProvider.overrideWithValue(alertas),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => _ahora),
          if (fuente != null)
            fuenteFotogramasProvider.overrideWithValue(fuente),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Leaves the camera: the tree goes and the replay, if any, closes.
  Future<void> salir(WidgetTester tester) async {
    GoRouter.of(tester.element(find.byType(PantallaCamara))).go(Rutas.inicio);
    await tester.pumpAndSettle();
  }

  Finder momento(String t) => find.text(t);

  group('Al abrir', () {
    testWidgets(
      'CA-39.3: abrir la cámara y ver el último evento no se registra',
      (tester) async {
        await abrir(tester, Rutas.camara('c1'));
        expect(momento('Hoy 10:41:52'), findsOneWidget);
        expect(find.text('Posible caída'), findsOneWidget);
        expect(
          ayudaCon(
            'Solo puntos del cuerpo, nunca video. Cada repetición queda en el '
            'registro de accesos.',
          ),
          findsOneWidget,
        );
        expect(find.text('Eventos · Hoy'), findsOneWidget);
        await verHasta(tester, find.text('Inestable'));
        expect(find.text('Se levantó'), findsOneWidget);
        expect(find.text('Caída'), findsOneWidget);
        expect(find.text('Inestable'), findsOneWidget);
        expect(repeticiones.creadas, isEmpty);
        expect(find.text('10:36'), findsOneWidget);
        expect(find.text('10:46'), findsOneWidget);
      },
    );

    testWidgets('sin eventos abre en los últimos minutos', (tester) async {
      alertas.alertas = [];
      await abrir(tester, Rutas.camara('c1'));
      expect(momento('Hoy 10:48:30'), findsOneWidget);
      await verHasta(tester, find.text('Sin eventos hoy'));
      // Nothing played yet and no event: no skeleton and no guessed posture.
      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.foregroundPainter is PintorEsqueleto,
        ),
        findsNothing,
      );
      expect(alertas.clips, isEmpty);
    });

    testWidgets(
      'CA-39.3: la foto fija del último evento sale de los puntos de su clip '
      'y no se registra',
      (tester) async {
        final fuente = _FuenteFalsa(
          desde: DateTime(2026, 9, 23, 10, 41, 46),
          segundos: 12,
        );
        alertas.enlaces.add(
          const EnlaceClip(
            url: 'https://clips.tetengo.pe/a-caida.mp4',
            puntos: 'https://clips.tetengo.pe/a-caida.landmarks.parquet',
            puntosLigeros: 'https://clips.tetengo.pe/a-caida.landmarks.ttmov',
          ),
        );
        await abrir(tester, Rutas.camara('c1'), fuente: fuente);
        expect(momento('Hoy 10:41:52'), findsOneWidget);
        expect(alertas.clips, ['a-caida']);
        expect(fuente.cargadas, [
          'https://clips.tetengo.pe/a-caida.landmarks.ttmov',
        ]);
        expect(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.foregroundPainter is PintorEsqueleto,
          ),
          findsOneWidget,
        );
        expect(find.text('Posible caída'), findsOneWidget);
        expect(repeticiones.creadas, isEmpty);
      },
    );
  });

  group('Reproducir registra la repetición', () {
    testWidgets('CA-39.1 y CA-39.3: reproducir la registra una vez y al salir '
        'se cierra con el acceso registrado', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tester.tap(find.bySemanticsLabel('Reproducir'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(repeticiones.creadas.single, (
        'c1',
        DateTime(2026, 9, 23, 10, 36),
        DateTime(2026, 9, 23, 10, 46),
      ));
      expect(momento('Hoy 10:41:53'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Pausar'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Retroceder 10 segundos'));
      await tester.pumpAndSettle();
      expect(momento('Hoy 10:41:43'), findsOneWidget);
      expect(repeticiones.creadas, hasLength(1));
      await salir(tester);
      expect(repeticiones.cerradas, ['rp-1']);
      expect(find.text('Acceso registrado'), findsOneWidget);
      expect(find.textContaining('Repetición de la Sala · '), findsOneWidget);
    });

    testWidgets('CA-39.3: recorrer la línea con un evento de la lista la '
        'registra y va a ese momento', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Inestable'));
      expect(repeticiones.creadas, hasLength(1));
      expect(momento('Hoy 10:30:00'), findsOneWidget);
      expect(find.text('Movimiento inestable'), findsOneWidget);
      // The replay starts with the window of that moment.
      expect(repeticiones.creadas.single.$2, DateTime(2026, 9, 23, 10, 25));
    });

    testWidgets('CA-39.3: arrastrar la línea de tiempo la registra', (
      tester,
    ) async {
      await abrir(tester, Rutas.camara('c1'));
      final linea = find.bySemanticsLabel('Momento de la repetición');
      await tester.drag(linea, const Offset(-60, 0));
      await tester.pumpAndSettle();
      expect(repeticiones.creadas, hasLength(1));
      expect(momento('Hoy 10:41:52'), findsNothing);
    });

    testWidgets('CA-39.3: sin reproducir ni recorrer, salir no registra nada', (
      tester,
    ) async {
      await abrir(tester, Rutas.camara('c1'));
      await salir(tester);
      expect(repeticiones.creadas, isEmpty);
      expect(repeticiones.cerradas, isEmpty);
      expect(find.text('Acceso registrado'), findsNothing);
    });
  });

  group('Filtros', () {
    testWidgets('«Solo eventos» salta de evento en evento', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Solo eventos'));
      expect(find.bySemanticsLabel('Evento anterior'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Evento siguiente'));
      await tester.pumpAndSettle();
      expect(momento('Hoy 10:43:00'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Evento siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('No hay más eventos'), findsOneWidget);
    });

    testWidgets('«1 hora» muestra la hora completa', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('1 hora'));
      // The clock hour, but the window cannot pass now: 09:50 to 10:50.
      expect(find.text('09:50'), findsOneWidget);
      expect(find.text('10:20'), findsOneWidget);
      expect(find.text('10:50'), findsOneWidget);
    });

    testWidgets('«Ayer» y «Elegir día…»', (tester) async {
      alertas.alertas = [
        ..._alertasDeHoy(),
        caidaSala(
          id: 'a-ayer',
          tipo: TipoAlerta.movimientoInestable,
          estado: EstadoAlerta.atendida,
          ocurridaEn: DateTime(2026, 9, 22, 18, 26),
        ),
      ];
      movimientos.datosDesde = DateTime(2026, 9, 18);
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ayer'));
      expect(find.text('Eventos · Ayer'), findsOneWidget);
      expect(momento('Ayer 18:26:00'), findsOneWidget);
      await tocar(tester, find.text('Elegir día…'));
      expect(find.text('Hay movimientos desde el 18/09/2026.'), findsOneWidget);
      expect(
        find.bySemanticsLabel('miércoles 16 de septiembre, sin movimientos'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('martes 22 de septiembre, con eventos'),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('sábado 19 de septiembre'));
      await tester.pumpAndSettle();
      expect(find.text('sáb 19 sep'), findsOneWidget);
      expect(find.text('Sin eventos el sáb 19 sep'), findsOneWidget);
    });
  });

  group('Sin movimientos que repetir', () {
    testWidgets('CA-39.4: sin el permiso, pide activarlo', (tester) async {
      movimientos = MovimientosRepositorioFalso();
      await abrir(tester, Rutas.camara('c1'));
      expect(
        find.text('Para ver lo que pasó, activa Guardar movimientos'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Reproducir'), findsNothing);
      expect(find.text('Últimos eventos'), findsOneWidget);
      await tocar(tester, find.text('Activar'));
      expect(find.text('¿Guardamos los movimientos de Rosa?'), findsOneWidget);
    });

    testWidgets('el invitado ve que solo la titular lo activa', (tester) async {
      movimientos = MovimientosRepositorioFalso(vigente: true);
      await abrir(tester, Rutas.camara('c1'), sesion: sesionInvitado);
      expect(
        find.text('Para ver lo que pasó, activa Movimientos en la nube'),
        findsOneWidget,
      );
      expect(find.text('Solo Carmen puede activarlo'), findsOneWidget);
    });

    testWidgets('los últimos eventos abren su alerta', (tester) async {
      movimientos = MovimientosRepositorioFalso();
      await abrir(tester, Rutas.camara('c1'));
      expect(find.text('23/09'), findsNWidgets(2));
      await tocar(tester, find.text('Caída'));
      expect(find.text('Caída en la Sala'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 1));
    });

    testWidgets('CA-39.4: un día fuera del plazo ofrece ver lo último', (
      tester,
    ) async {
      await abrir(tester, Rutas.camaraEn('c1', DateTime(2026, 8, 11, 10)));
      expect(
        find.text('No hay movimientos del 11/08. Hay desde el 24/08/2026.'),
        findsOneWidget,
      );
      expect(find.text('10 min'), findsNothing);
      await tocar(tester, find.text('Ver lo último'));
      expect(momento('Hoy 10:41:52'), findsOneWidget);
    });

    testWidgets('CA-35.4: el permiso retirado mientras se mira', (
      tester,
    ) async {
      repeticiones.errorCrear = const ProblemaApi(
        codigo: 'SIN_CONSENTIMIENTO_DE_MOVIMIENTOS',
        detalle: 'Rosa ya no autoriza guardar sus movimientos.',
        estado: 409,
      );
      await abrir(tester, Rutas.camara('c1'));
      await tester.tap(find.bySemanticsLabel('Reproducir'));
      await tester.pumpAndSettle();
      expect(
        find.text('Rosa retiró el permiso. Se borraron sus movimientos.'),
        findsOneWidget,
      );
    });

    testWidgets('sin internet lo dice', (tester) async {
      repeticiones.errorCrear = const ProblemaApi(
        codigo: ProblemaApi.sinConexion,
        detalle: 'No hay conexión con Te Tengo. Revisa tu internet.',
      );
      await abrir(tester, Rutas.camara('c1'));
      await tester.tap(find.bySemanticsLabel('Reproducir'));
      await tester.pumpAndSettle();
      expect(find.text('Sin internet'), findsOneWidget);
    });
  });

  testWidgets('«Ver qué pasó» de una alerta abre la cámara en ese momento', (
    tester,
  ) async {
    await abrir(tester, Rutas.detalleAlerta('a-inestable'));
    await verHasta(tester, find.text('En la cámara, sin video'));
    await tocar(tester, find.text('Ver qué pasó'));
    expect(find.byType(PantallaCamara), findsOneWidget);
    expect(momento('Hoy 10:30:00'), findsOneWidget);
    expect(repeticiones.creadas, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets('con un decodificador dibuja el esqueleto del momento', (
    tester,
  ) async {
    final fuente = _FuenteFalsa();
    await abrir(tester, Rutas.camara('c1'), fuente: fuente);
    await tester.tap(find.bySemanticsLabel('Reproducir'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.bySemanticsLabel('Pausar'));
    await tester.pumpAndSettle();
    // The light files, checked against their own sha256, never the Parquet files.
    expect(fuente.cargadas, isNotEmpty);
    expect(fuente.cargadas, everyElement(endsWith('.ttmov')));
    expect(fuente.sha256, everyElement('def'));
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.foregroundPainter is PintorEsqueleto,
      ),
      findsOneWidget,
    );
  });

  testWidgets('un archivo sin su ligero no se descarga y se ve sin datos', (
    tester,
  ) async {
    repeticiones.sinLigeros = true;
    final fuente = _FuenteFalsa();
    await abrir(tester, Rutas.camara('c1'), fuente: fuente);
    await tester.tap(find.bySemanticsLabel('Reproducir'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.bySemanticsLabel('Pausar'));
    await tester.pumpAndSettle();
    expect(repeticiones.creadas, hasLength(1));
    expect(fuente.cargadas.where((u) => u.contains('movimientos')), isEmpty);
    expect(find.text('Sin datos'), findsWidgets);
  });

  group('Dominio', () {
    test('los huecos son lo que ningún archivo cubre', () {
      final h = huecosDe(
        [
          ArchivoMovimientos(
            id: 'a',
            desde: DateTime(2026, 9, 23, 10, 35),
            hasta: DateTime(2026, 9, 23, 10, 40),
            url: 'u',
          ),
          ArchivoMovimientos(
            id: 'b',
            desde: DateTime(2026, 9, 23, 10, 45),
            hasta: DateTime(2026, 9, 23, 10, 50),
            url: 'u',
          ),
        ],
        DateTime(2026, 9, 23, 10, 30),
        DateTime(2026, 9, 23, 10, 50),
      );
      expect(
        [for (final t in h) (t.desde.minute, t.hasta.minute)],
        [(30, 35), (40, 45)],
      );
    });

    test('los eventos salen de las alertas de la cámara', () {
      final e = eventosDe(_alertasDeHoy(), 'c1');
      expect(
        [for (final x in e) x.tipo],
        [TipoEvento.inestable, TipoEvento.caida, TipoEvento.levanto],
      );
      expect(eventosDe(_alertasDeHoy(), 'otra'), isEmpty);
    });

    test(
      'el reproductor corta los datos donde la PC dejó de responder',
      () async {
        final r = ReproductorCamara(
          camaraId: 'c1',
          habitacion: 'Sala',
          repeticiones: RepeticionesRepositorioFalso(),
          alertas: AlertasRepositorioFalso(_alertasDeHoy()),
          reloj: () => _ahora,
          corte: (
            desde: DateTime(2026, 9, 23, 10, 44),
            motivo: 'La PC no responde',
          ),
        );
        addTearDown(r.dispose);
        await r.iniciar();
        final t = r.huecos.single;
        expect(t.motivo, 'La PC no responde');
        expect(t.desde, DateTime(2026, 9, 23, 10, 44));
        r.irA(DateTime(2026, 9, 23, 10, 45));
        expect(r.posicion, DateTime(2026, 9, 23, 10, 44));
      },
    );
  });

  group('Fuente de fotogramas', () {
    test('comprueba el sha256 antes de decodificar', () async {
      final bytes = Uint8List.fromList(utf8.encode('movimientos'));
      final dio = Dio()..httpClientAdapter = _Bytes(bytes);
      final decod = _Decod();
      final fuente = FuenteFotogramas(decod, dio: dio);
      await fuente.cargar(
        'https://m/1.parquet',
        sha256Esperado: sha256.convert(bytes).toString(),
      );
      expect(decod.veces, 1);
      await expectLater(
        fuente.cargar('https://m/1.parquet', sha256Esperado: 'ffff'),
        throwsFormatException,
      );
      expect(decod.veces, 1);
    });
  });

  test('POST, GET archivos, DELETE y accesos de repeticiones', () async {
    const repeticion = {
      'id': 'rp-1',
      'camaraId': 'c1',
      'habitacion': 'Sala',
      'desde': '2026-09-23T15:36:00Z',
      'hasta': '2026-09-23T15:46:00Z',
      'disponiblesDesde': '2026-08-24T05:00:00Z',
      'guardadoEnLaNube': true,
      'archivos': [
        {
          'id': 'f1',
          'desde': '2026-09-23T15:35:00Z',
          'hasta': '2026-09-23T15:40:00Z',
          'tamanoBytes': 120000,
          'fotogramas': 4500,
          'sha256': 'abc',
          'url': 'https://s3/f1.parquet',
          'ligero': {
            'url': 'https://s3/f1.ttmov',
            'tamanoBytes': 64000,
            'sha256': 'def',
          },
        },
      ],
      'urlsExpiranEn': '2026-09-23T16:00:00Z',
    };
    final http = AdaptadorFalso()
      ..cuando(
        'POST',
        '/api/camaras/c1/repeticiones',
        const Respuesta(201, repeticion),
      )
      ..cuando(
        'GET',
        '/api/repeticiones/rp-1/archivos',
        const Respuesta(200, repeticion),
      )
      ..cuando('DELETE', '/api/repeticiones/rp-1', const Respuesta(204))
      ..cuando(
        'GET',
        '/api/accesos-repeticiones',
        const Respuesta(200, [
          {
            'id': 'ar-1',
            'usuario': {'id': 'u-carmen', 'nombre': 'Carmen Huamán'},
            'camaraId': 'c1',
            'habitacion': 'Sala',
            'momentoDesde': '2026-09-15T12:54:00Z',
            'momentoHasta': '2026-09-15T13:04:00Z',
            'inicio': '2026-09-23T02:46:00Z',
            'duracionSegundos': 130,
          },
        ]),
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
    final repo = c.read(repeticionesRepositorioProvider);
    final desde = DateTime.utc(2026, 9, 23, 15, 36);
    final hasta = DateTime.utc(2026, 9, 23, 15, 46);
    final r = await repo.crear('c1', desde, hasta);
    expect(r.archivos.single.fotogramas, 4500);
    expect(r.archivos.single.ligero!.url, 'https://s3/f1.ttmov');
    expect(r.archivos.single.ligero!.sha256, 'def');
    expect(r.archivos.single.ligero!.tamanoBytes, 64000);
    expect(r.disponiblesDesde!.toUtc(), DateTime.utc(2026, 8, 24, 5));
    await repo.archivos('rp-1', desde, hasta);
    await repo.cerrar('rp-1');
    final a = (await repo.accesos()).single;
    expect(a.duracionSegundos, 130);
    expect(a.momentoDesde.toUtc(), DateTime.utc(2026, 9, 15, 12, 54));
    expect(http.peticiones.first.data, {
      'desde': '2026-09-23T15:36:00.000Z',
      'hasta': '2026-09-23T15:46:00.000Z',
    });
    expect(http.peticiones[1].queryParameters, {
      'desde': '2026-09-23T15:36:00.000Z',
      'hasta': '2026-09-23T15:46:00.000Z',
    });
  });
}

class _Decod implements DecodificadorMovimientos {
  int veces = 0;

  @override
  Future<List<Fotograma>> decodificar(Uint8List bytes) async {
    veces++;
    return const [];
  }
}

class _Bytes implements HttpClientAdapter {
  _Bytes(this.bytes);

  final Uint8List bytes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(bytes, 200);

  @override
  void close({bool force = false}) {}
}
