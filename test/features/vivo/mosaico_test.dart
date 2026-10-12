import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/dispositivo/llamada.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/data/orden_camaras.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/modos_vista.dart';
import 'package:te_tengo/features/vivo/presentation/pantalla_mosaico.dart';
import 'package:te_tengo/features/vivo/presentation/pantalla_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_webrtc.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../pcs/camaras_y_pcs_test.dart' show casaDeRosa, camara, pc;
import '../pcs/pcs_falso.dart';
import 'vivo_falso.dart';

class _OrientacionFalsa implements OrientacionMosaico {
  final llamadas = <String>[];

  @override
  void horizontal() => llamadas.add('horizontal');

  @override
  void liberar() => llamadas.add('liberar');
}

void main() {
  late PcsRepositorioFalso pcs;
  late CamarasRepositorioFalso camaras;
  late VistaEnVivoRepositorioFalso vivo;
  late FabricaReproductorFalsa reproductores;
  late _OrientacionFalsa orientacion;
  late CacheMemoria cache;
  late List<String?> llamadas;
  late DateTime ahora;

  void usarCamaras(List<Camara> lista, {bool pcSinConexion = false}) {
    camaras.camaras = lista;
    pcs.pcs = [
      pc(
        'pc-sala',
        'Sala-Rosa',
        lista.where((c) => c.pcId == 'pc-sala').toList(),
      ),
      pc(
        'pc-cocina',
        'Cocina-Rosa',
        lista.where((c) => c.pcId == 'pc-cocina').toList(),
        sinConexion: pcSinConexion,
      ),
    ];
  }

  setUp(() {
    pcs = PcsRepositorioFalso();
    camaras = CamarasRepositorioFalso();
    vivo = VistaEnVivoRepositorioFalso();
    reproductores = FabricaReproductorFalsa();
    orientacion = _OrientacionFalsa();
    cache = CacheMemoria();
    llamadas = [];
    ahora = DateTime(2026, 9, 23, 10, 42, 6);
    final casa = casaDeRosa();
    usarCamaras(casa.camaras);
  });

  /// A phone held in landscape (844 × 390), as «Ver todas» opens.
  void enHorizontal(WidgetTester tester) {
    tester.view.physicalSize = const Size(2532, 1170);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    bool horizontal = true,
    bool consentimiento = true,
  }) async {
    if (horizontal) {
      enHorizontal(tester);
    } else {
      usarTelefono(tester);
    }
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        cache: cache,
        overrides: [
          pcsRepositorioProvider.overrideWithValue(pcs),
          camarasRepositorioProvider.overrideWithValue(camaras),
          vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
          fabricaReproductorVivoProvider.overrideWithValue(reproductores.crear),
          fabricaReproductorWebrtcProvider.overrideWithValue(
            reproductores.crearWebrtc,
          ),
          orientacionMosaicoProvider.overrideWithValue(orientacion),
          hogarRepositorioProvider.overrideWithValue(
            HogarRepositorioFalso(hogarDeRosa(consentimiento: consentimiento)),
          ),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => ahora),
          llamarProvider.overrideWithValue((t) async => llamadas.add(t)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder celda(String habitacion) =>
      find.bySemanticsLabel(RegExp('^$habitacion, '));

  List<String> abiertas() => [for (final (id, _) in vivo.abiertas) id];

  List<Camara> seis() => [
    camara('c1', 'Sala', 'pc-sala'),
    camara('c2', 'Dormitorio', 'pc-sala'),
    camara('c3', 'Pasillo', 'pc-sala'),
    camara('c4', 'Cocina', 'pc-cocina'),
    camara('c5', 'Comedor', 'pc-cocina'),
    camara('c6', 'Estudio', 'pc-cocina'),
  ];

  group('CA-41.1 mosaico en horizontal', () {
    testWidgets('«Ver todas» en Cámaras abre en horizontal 4 cámaras en '
        'vivo, en el orden de este celular, como un solo acceso', (
      tester,
    ) async {
      await AlmacenOrdenCamarasLocal(
        cache,
      ).guardar(const OrdenCamaras(favoritas: {'c4'}));
      await abrir(tester, Rutas.pcs, horizontal: false);
      await tocar(tester, find.text('Ver todas'));
      expect(find.byType(PantallaMosaico), findsOneWidget);
      expect(orientacion.llamadas, ['horizontal']);
      expect(vivo.mosaicos, 1);
      expect(abiertas(), ['c4', 'c1', 'c2', 'c3']);
      expect(vivo.mosaicosPedidos, everyElement('m-1'));
      expect(find.byKey(const Key('video-en-vivo')), findsNWidgets(4));
      expect(find.text('EN VIVO'), findsNWidgets(4));
      // Four cameras: one page, no pager.
      expect(find.bySemanticsLabel('Página siguiente'), findsNothing);
      for (final t in ['Cerrar', 'Video', 'Esqueleto', 'Ordenar', 'Vertical']) {
        expect(find.bySemanticsLabel(t), findsOneWidget, reason: t);
      }
      expect(ayudaCon(textoPrivacidadMosaico), findsOneWidget);
    });

    testWidgets('«Ver todas a la vez» encabeza la hoja de habitaciones', (
      tester,
    ) async {
      await abrir(tester, Rutas.inicio, horizontal: false);
      await tocar(tester, find.text('Ver en vivo'));
      expect(find.text('Hasta 4 por página'), findsOneWidget);
      await tocar(tester, find.text('Ver todas a la vez'));
      expect(find.byType(PantallaMosaico), findsOneWidget);
    });

    testWidgets('con una sola cámara no aparece «Ver todas»', (tester) async {
      usarCamaras([camara('c1', 'Sala', 'pc-sala')]);
      await abrir(tester, Rutas.pcs, horizontal: false);
      expect(find.text('Ver todas'), findsNothing);
    });

    testWidgets('«Vertical» se recuerda en este celular', (tester) async {
      await abrir(tester, Rutas.verTodas);
      await tester.tap(find.bySemanticsLabel('Vertical'));
      await tester.pumpAndSettle();
      expect(orientacion.llamadas, ['horizontal', 'liberar']);
      expect(find.text('Todas en vivo'), findsOneWidget);
      expect(cache.datos['dispositivo|mosaico-vertical'], 'si');
      expect(find.byKey(const Key('video-en-vivo')), findsNWidgets(4));

      // Opening again starts in portrait, without turning the phone.
      await tester.pumpWidget(const SizedBox.shrink());
      orientacion.llamadas.clear();
      await abrir(tester, Rutas.verTodas, horizontal: false);
      expect(find.text('Todas en vivo'), findsOneWidget);
      expect(orientacion.llamadas, isNot(contains('horizontal')));
      await tester.tap(find.byTooltip('Ver en horizontal'));
      await tester.pumpAndSettle();
      expect(orientacion.llamadas, contains('horizontal'));
      expect(cache.datos['dispositivo|mosaico-vertical'], 'no');
    });

    testWidgets('en una ventana vertical (la web) el contenido gira', (
      tester,
    ) async {
      await abrir(tester, Rutas.verTodas, horizontal: false);
      expect(find.byType(RotatedBox), findsOneWidget);
      expect(find.byKey(const Key('video-en-vivo')), findsNWidgets(4));
      await tester.tap(celda('Sala'));
      await tester.pumpAndSettle();
      expect(find.text('Volver a todas'), findsOneWidget);
    });
  });

  testWidgets('CA-41.2 con más de 4 hay páginas y solo transmite la visible', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    usarCamaras(seis());
    await abrir(tester, Rutas.verTodas);
    expect(find.text('01/02'), findsOneWidget);
    expect(abiertas(), ['c1', 'c2', 'c3', 'c4']);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Página anterior')),
      isSemantics(hasEnabledState: true, isEnabled: false),
    );
    await tester.tap(find.bySemanticsLabel('Página siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('02/02'), findsOneWidget);
    // The previous page stopped streaming.
    expect(vivo.cerradas, ['v-1', 'v-2', 'v-3', 'v-4']);
    expect(abiertas(), ['c1', 'c2', 'c3', 'c4', 'c5', 'c6']);
    expect(find.byKey(const Key('video-en-vivo')), findsNWidgets(2));
    expect(find.bySemanticsLabel('Página 2 de 2'), findsOneWidget);

    // Swiping goes back.
    await tester.fling(celda('Comedor'), const Offset(400, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('01/02'), findsOneWidget);
    expect(vivo.cerradas, hasLength(6));
    semantica.dispose();
  });

  testWidgets('CA-41.3 «Esqueleto» cambia todas las celdas y se recuerda', (
    tester,
  ) async {
    await abrir(tester, Rutas.verTodas);
    expect(vivo.modosPedidos, everyElement(isNull));
    await tester.tap(find.bySemanticsLabel('Video'));
    await tester.pumpAndSettle();
    expect(vivo.cambios, [
      for (var i = 1; i <= 4; i++) ('v-$i', ModoVista.soloPostura),
    ]);
    expect(cache.datos['dispositivo|modo-vivo'], 'SOLO_POSTURA');
    expect(
      tester.widget<ModosVista>(find.byType(ModosVista)).modo,
      ModoVista.soloPostura,
    );
  });

  group('CA-41.4 pantalla completa, orden y favoritas', () {
    testWidgets('tocar una celda la abre sola y «Volver a todas» regresa', (
      tester,
    ) async {
      await abrir(tester, Rutas.verTodas);
      await tester.tap(celda('Pasillo'));
      await tester.pumpAndSettle();
      expect(vivo.cerradas, ['v-1', 'v-2', 'v-4']);
      expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
      expect(find.text('Pasillo'), findsOneWidget);
      expect(find.text('Volver a todas'), findsOneWidget);
      await tester.tap(find.text('Llamar a Rosa'));
      expect(llamadas, hasLength(1));
      await tester.tap(find.text('Volver a todas'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('video-en-vivo')), findsNWidgets(4));
      // All of it is one access: every session carries the same mosaic.
      expect(vivo.mosaicosPedidos, everyElement('m-1'));
      expect(vivo.mosaicos, 1);
    });

    testWidgets('en vertical abre la vista en vivo de siempre en el mismo '
        'acceso', (tester) async {
      await cache.guardar('dispositivo|mosaico-vertical', 'si');
      await abrir(tester, Rutas.verTodas, horizontal: false);
      await tester.tap(celda('Sala'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaVivo), findsOneWidget);
      expect(vivo.cerradas, ['v-1', 'v-2', 'v-3', 'v-4']);
      expect(vivo.mosaicosPedidos.last, 'm-1');
      await tocar(tester, find.text('Volver a todas'));
      expect(find.byType(PantallaMosaico), findsOneWidget);
      // The live view does not confirm the access: the mosaic does when it closes.
      expect(find.text('Acceso registrado'), findsNothing);
      expect(find.byKey(const Key('video-en-vivo')), findsNWidgets(4));
    });

    testWidgets('«Ordenar» mueve la cámara elegida y el orden rige en '
        'Cámaras', (tester) async {
      await abrir(tester, Rutas.verTodas);
      await tester.tap(find.bySemanticsLabel('Ordenar'));
      await tester.pumpAndSettle();
      expect(find.text('Elige una cámara para moverla'), findsOneWidget);
      await tester.tap(celda('Sala'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Arrastra o mueve', findRichText: true),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('Mover después'));
      await tester.pumpAndSettle();
      expect(
        OrdenCamaras.desdeJson(
          cache.datos[AlmacenOrdenCamarasLocal.clave],
        ).orden,
        ['c2', 'c1', 'c3', 'c4'],
      );
      await tester.tap(find.bySemanticsLabel('Listo'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Ordenar'), findsOneWidget);
    });

    testWidgets('arrastrar una celda sobre otra la mueve', (tester) async {
      await abrir(tester, Rutas.verTodas);
      final desde = tester.getCenter(celda('Cocina'));
      final hasta = tester.getCenter(celda('Sala'));
      final gesto = await tester.startGesture(desde);
      await tester.pump(const Duration(milliseconds: 600));
      await gesto.moveTo(hasta);
      await tester.pump();
      await gesto.up();
      await tester.pumpAndSettle();
      expect(
        OrdenCamaras.desdeJson(
          cache.datos[AlmacenOrdenCamarasLocal.clave],
        ).orden,
        ['c4', 'c1', 'c2', 'c3'],
      );
    });

    testWidgets('mantenerla presionada ofrece moverla, la estrella y la '
        'pantalla completa', (tester) async {
      await abrir(tester, Rutas.verTodas);
      await tester.longPress(celda('Pasillo'));
      await tester.pumpAndSettle();
      for (final t in [
        'Mover antes',
        'Mover después',
        'Marcar como favorita',
        'Ver en pantalla completa',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      await tester.tap(find.text('Marcar como favorita'));
      await tester.pumpAndSettle();
      expect(
        OrdenCamaras.desdeJson(
          cache.datos[AlmacenOrdenCamarasLocal.clave],
        ).favoritas,
        {'c3'},
      );
      await tester.longPress(celda('Sala'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mover después'));
      await tester.pumpAndSettle();
      expect(find.text('Sala se movió'), findsOneWidget);
      expect(
        find.text('Mismo orden en Cámaras y Ver en vivo.'),
        findsOneWidget,
      );
    });
  });

  group('CA-41.5 cámaras no disponibles', () {
    testWidgets('conservan su lugar con el motivo y no transmiten', (
      tester,
    ) async {
      usarCamaras([
        camara(
          'c1',
          'Sala',
          'pc-sala',
          pausadaHasta: DateTime(2026, 9, 23, 11, 42),
        ),
        camara(
          'c2',
          'Dormitorio',
          'pc-sala',
          estado: EstadoConexion.desconectada,
        ),
        camara('c3', 'Pasillo', 'pc-sala'),
        camara('c4', 'Cocina', 'pc-cocina'),
      ], pcSinConexion: true);
      await abrir(tester, Rutas.verTodas);
      expect(abiertas(), ['c3']);
      expect(find.text('En pausa'), findsOneWidget);
      expect(find.text('Hasta las 11:42'), findsOneWidget);
      expect(find.text('Desconectada'), findsOneWidget);
      expect(find.text('Desde las 10:31'), findsOneWidget);
      expect(find.text('Sin conexión'), findsOneWidget);
      expect(find.text('La PC no responde'), findsOneWidget);

      // Tapping it opens it with its notice and «Reanudar».
      await tester.tap(celda('Sala'));
      await tester.pumpAndSettle();
      expect(find.text('Hasta las 11:42'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Reanudar'));
      await tester.pumpAndSettle();
      expect(camaras.reanudaciones, 1);
    });

    testWidgets('sin consentimiento todas dicen «Detenida» y ninguna '
        'transmite', (tester) async {
      await abrir(tester, Rutas.verTodas, consentimiento: false);
      expect(vivo.abiertas, isEmpty);
      expect(find.text('Detenida'), findsNWidgets(4));
      expect(find.text('Sin consentimiento'), findsNWidgets(4));
    });

    testWidgets('una sesión rechazada (en pausa desde otro celular) dice por '
        'qué', (tester) async {
      vivo.errorAbrir = const ProblemaApi(
        codigo: 'CAMARA_EN_PAUSA',
        detalle: 'La cámara está en pausa.',
        estado: 409,
      );
      await abrir(tester, Rutas.verTodas);
      expect(find.text('En pausa'), findsNWidgets(4));
      expect(find.byKey(const Key('video-en-vivo')), findsNothing);
    });
  });

  testWidgets('CA-41.6 al cerrar confirma un solo acceso con las habitaciones '
      'vistas', (tester) async {
    usarCamaras(seis());
    await abrir(tester, Rutas.pcs);
    await tocar(tester, find.text('Ver todas'));
    await tester.tap(find.bySemanticsLabel('Página siguiente'));
    await tester.pumpAndSettle();
    ahora = ahora.add(const Duration(minutes: 2));
    await tester.tap(find.bySemanticsLabel('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMosaico), findsNothing);
    expect(orientacion.llamadas.last, 'liberar');
    expect(vivo.cerradas, hasLength(6));
    expect(find.text('Acceso registrado'), findsOneWidget);
    expect(
      find.text(
        'Viste Sala, Dormitorio, Pasillo, Cocina, Comedor y Estudio · 2\u00a0min.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('con una API sin mosaicos igual transmite (accesos separados)', (
    tester,
  ) async {
    vivo.sinMosaicos = true;
    await abrir(tester, Rutas.verTodas);
    expect(abiertas(), hasLength(4));
    expect(vivo.mosaicosPedidos, everyElement(isNull));
  });

  testWidgets('en segundo plano cierra las sesiones y al volver las abre', (
    tester,
  ) async {
    await abrir(tester, Rutas.verTodas);
    for (final e in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(e);
    }
    await tester.pump();
    expect(vivo.cerradas, hasLength(4));
    for (final e in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(e);
    }
    await tester.pumpAndSettle();
    expect(abiertas(), hasLength(8));
  });

  testWidgets('áreas táctiles, etiquetas y texto al 200 %', (tester) async {
    final semantica = tester.ensureSemantics();
    usarCamaras(seis());
    await abrir(tester, Rutas.verTodas);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    expect(
      tester.getSemantics(celda('Sala')),
      isSemantics(
        label: 'Sala, en vivo. Abrir en pantalla completa',
        isButton: true,
        hasTapAction: true,
        hasLongPressAction: true,
      ),
    );
    semantica.dispose();
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.bySemanticsLabel('Vertical'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Escape sale de la pantalla completa y luego cierra', (
    tester,
  ) async {
    await abrir(tester, Rutas.pcs);
    await tocar(tester, find.text('Ver todas'));
    await tester.tap(celda('Sala'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('video-en-vivo')), findsNWidgets(4));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaMosaico), findsNothing);
  });

  group('registro de accesos', () {
    testWidgets('CA-41.6 una entrada «Carmen (tú) vio Sala, Cocina y '
        'Pasillo» · «Varias cámaras»', (tester) async {
      vivo.lista = [
        AccesoVivo(
          usuarioId: 'u-carmen',
          nombre: 'Carmen Huamán',
          inicio: DateTime(2026, 9, 23, 10, 42),
          duracionSegundos: 120,
          camaraId: 'c1',
          camaraIds: const ['c1', 'c4', 'c3'],
          mosaico: true,
        ),
      ];
      await abrir(tester, Rutas.accesos, horizontal: false);
      expect(
        find.text('Carmen (tú) vio Sala, Cocina y Pasillo'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Varias cámaras · ', findRichText: true),
        findsOneWidget,
      );
      // It is a live view in the filter.
      await tocar(tester, find.text('Repeticiones'));
      expect(find.text('Carmen (tú) vio Sala, Cocina y Pasillo'), findsNothing);
      await tocar(tester, find.text('Vista en vivo'));
      expect(
        find.text('Carmen (tú) vio Sala, Cocina y Pasillo'),
        findsOneWidget,
      );
    });

    test('lee camaraIds y mosaico, y un backend anterior sin ellos', () {
      final json = {
        'usuario': {'id': 'u-1', 'nombre': 'Ana'},
        'inicio': '2026-09-23T15:42:00Z',
        'duracionSegundos': 90,
        'desdeAlerta': false,
        'camaraId': 'c1',
        'vistaPrevia': false,
      };
      final viejo = AccesoVivo.desdeJson(json);
      expect(viejo.mosaico, isFalse);
      expect(viejo.camaraIds, isEmpty);
      final nuevo = AccesoVivo.desdeJson({
        ...json,
        'camaraIds': ['c1', 'c2'],
        'mosaico': true,
      });
      expect(nuevo.mosaico, isTrue);
      expect(nuevo.camaraIds, ['c1', 'c2']);
    });
  });
}
