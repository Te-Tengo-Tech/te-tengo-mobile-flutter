import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/dispositivo/llamada.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/ui/chips.dart';
import 'package:te_tengo/core/ui/iconos.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_alerta.dart';
import 'package:te_tengo/features/alertas/presentation/reproductor.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/cliente_whep.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/pantalla_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_webrtc.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/clip_falso.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'vivo_falso.dart';

void main() {
  late CamarasRepositorioFalso camaras;
  late VistaEnVivoRepositorioFalso vivo;
  late FabricaReproductorFalsa reproductores;
  late FabricaReproductorFalsa webrtc;
  late List<String?> llamadas;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    AlertasRepositorioFalso? alertas,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(camaras),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            alertas ?? AlertasRepositorioFalso(),
          ),
          vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
          fabricaReproductorVivoProvider.overrideWithValue(reproductores.crear),
          fabricaReproductorWebrtcProvider.overrideWithValue(
            webrtc.crearWebrtc,
          ),
          relojProvider.overrideWithValue(
            () => DateTime(2026, 9, 23, 10, 42, 6),
          ),
          llamarProvider.overrideWithValue((t) async => llamadas.add(t)),
          fabricaClipProvider.overrideWithValue(ClipFalso.new),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> esperar(WidgetTester tester, int segundos) async {
    for (var i = 0; i < segundos; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  Camara sala({
    EstadoConexion estado = EstadoConexion.enLinea,
    DateTime? pausadaHasta,
  }) => Camara(
    id: 'c1',
    nombreHabitacion: 'Sala',
    estado: estado,
    ultimaSenal: DateTime(2026, 9, 23, 10, 31),
    pausadaHasta: pausadaHasta,
  );

  setUp(() {
    camaras = CamarasRepositorioFalso();
    vivo = VistaEnVivoRepositorioFalso();
    reproductores = FabricaReproductorFalsa();
    webrtc = FabricaReproductorFalsa();
    llamadas = [];
  });

  testWidgets('CA-23.1 y CA-24.1: ve en vivo desde el inicio y al cerrar queda '
      'registrado', (tester) async {
    await abrir(tester, Rutas.inicio);
    await tocar(tester, find.text('Ver en vivo'));
    expect(find.byType(PantallaVivo), findsOneWidget);
    expect(vivo.abiertas, [('c1', null)]);
    expect(
      reproductores.ultimo.url.toString(),
      'https://api.tetengo.pe/vivo/camaras/c1/index.m3u8?token=t-v-1',
    );
    expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
    expect(find.text('En vivo · Sala'), findsOneWidget);
    await verHasta(tester, find.text('Cerrar la vista en vivo'));
    final ya = int.parse(
      RegExp(r'00:(\d\d)')
          .firstMatch(
            tester
                .widget<RichText>(
                  find.textContaining('EN VIVO', findRichText: true).last,
                )
                .text
                .toPlainText(),
          )!
          .group(1)!,
    );
    await esperar(tester, 37 - ya);
    expect(
      find.textContaining('EN VIVO · 00:37', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('Ves la Sala en este momento. La transmisión no se graba.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Tu acceso queda en el registro que ve toda la familia: Carmen Huamán, '
        'desde las 10:42.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Llamar a Rosa'));
    await tester.pump();
    expect(llamadas, hasLength(1));
    await tester.tap(find.text('Cerrar la vista en vivo'));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaVivo), findsNothing);
    expect(vivo.cerradas, ['v-1']);
    expect(find.text('Acceso registrado'), findsOneWidget);
    expect(
      find.text('Viste la Sala en vivo durante 37\u00a0s.'),
      findsOneWidget,
    );
    expect(reproductores.ultimo.desechado, isTrue);
  });

  testWidgets('cerrar con el botón del sistema también cierra la sesión', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('Disponible ahora'));
    await tocar(tester, find.text('Ver en vivo'));
    await esperar(tester, 2);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(vivo.cerradas, ['v-1']);
    expect(
      find.textContaining('Viste la Sala en vivo durante'),
      findsOneWidget,
    );
  });

  testWidgets('CA-23.2: desde una alerta muestra la habitación de la alerta', (
    tester,
  ) async {
    vivo.modo = ModoVista.videoConPostura;
    await abrir(
      tester,
      Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    await tocar(tester, find.text('Ver en vivo'));
    expect(vivo.abiertas, [('c1', 'a-1')]);
    expect(
      find.text(
        'Ves la habitación y la postura detectada. La transmisión no se graba.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Volver a la alerta'));
    expect(find.byType(PantallaAlerta), findsOneWidget);
    expect(vivo.cerradas, ['v-1']);
  });

  testWidgets('CA-23.3: con la cámara desconectada no está disponible', (
    tester,
  ) async {
    camaras.camaras = [sala(estado: EstadoConexion.desconectada)];
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('No disponible ahora'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(vivo.abiertas, isEmpty);
    expect(
      find.text('La cámara de la Sala no está disponible'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Perdió la conexión a las 10:31, así que no podemos mostrarte la '
        'habitación. Revisa el cable de la cámara, que la PC esté encendida y '
        'el internet de la casa.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Llamar a Rosa'), findsNothing);
    await tocar(tester, find.text('Cerrar la vista en vivo'));
    expect(vivo.cerradas, isEmpty);
    expect(find.text('Acceso registrado'), findsNothing);
  });

  testWidgets('CA-23.3: si el servidor responde CAMARA_DESCONECTADA', (
    tester,
  ) async {
    vivo.errorAbrir = const ProblemaApi(
      codigo: 'CAMARA_DESCONECTADA',
      detalle: 'La cámara está desconectada.',
      estado: 409,
    );
    await abrir(
      tester,
      Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    await tocar(tester, find.text('Ver en vivo'));
    expect(
      find.text('La cámara de la Sala no está disponible'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Llama a Rosa o pide a alguien cercano que vaya a verla.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Llamar a Rosa'), findsWidgets);
  });

  testWidgets(
    'CA-05.2: si el servidor responde SIN_CONSENTIMIENTO, la cámara está detenida',
    (tester) async {
      vivo.errorAbrir = const ProblemaApi(
        codigo: 'SIN_CONSENTIMIENTO',
        detalle: 'No hay un consentimiento vigente.',
        estado: 409,
      );
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
      expect(vivo.abiertas, hasLength(1));
      expect(find.text('La cámara está detenida'), findsOneWidget);
      expect(
        find.text(
          'Sin el consentimiento de Rosa la cámara no envía video, así que no '
          'se puede ver en vivo.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('No hay un consentimiento vigente.'), findsNothing);
      expect(reproductores.creados, isEmpty);
      expect(find.text('Llamar a Rosa'), findsNothing);
    },
  );

  testWidgets('CA-23.4: en pausa indica hasta qué hora y permite reanudar', (
    tester,
  ) async {
    camaras.camaras = [sala(pausadaHasta: DateTime(2026, 9, 23, 11, 42))];
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('No disponible hasta las 11:42'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(vivo.abiertas, isEmpty);
    expect(find.text('La vista en vivo no está disponible'), findsOneWidget);
    expect(
      find.textContaining(
        'La cámara de la Sala está en pausa hasta las 11:42. Podrás verla de '
        'nuevo a esa hora, o antes si reanudas la cámara.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Reanudar la cámara ahora'));
    expect(camaras.reanudaciones, 1);
    expect(vivo.abiertas, [('c1', null)]);
    expect(
      find.textContaining('EN VIVO · 00:00', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('CA-23.4: si el servidor responde CAMARA_EN_PAUSA', (
    tester,
  ) async {
    vivo.errorAbrir = const ProblemaApi(
      codigo: 'CAMARA_EN_PAUSA',
      detalle: 'La cámara está en pausa.',
      estado: 409,
      extras: {'pausadaHasta': '2026-09-23T16:42:00Z'},
    );
    await abrir(tester, Rutas.inicio);
    await tocar(tester, find.text('Ver en vivo'));
    expect(
      find.textContaining(
        'en pausa hasta las ${DateTime.utc(2026, 9, 23, 16, 42).toLocal().hour}',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('un familiar invitado también puede verla en vivo', (
    tester,
  ) async {
    await abrir(tester, Rutas.inicio, sesion: sesionInvitado);
    await tocar(tester, find.text('Ver en vivo'));
    expect(
      find.textContaining('Luis Huamán, desde las 10:42.', findRichText: true),
      findsOneWidget,
    );
  });

  test('mm:ss del reloj EN VIVO', () {
    expect(minutosSegundos(125), '02:05');
  });

  testWidgets('mientras llega la primera imagen muestra la espera', (
    tester,
  ) async {
    reproductores.conImagen = false;
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(find.byKey(const Key('video-en-vivo')), findsNothing);
    expect(find.byWidgetPredicate(_iconoVideo), findsOneWidget);
    expect(
      find.textContaining('EN VIVO · 00:00', findRichText: true),
      findsOneWidget,
    );
    reproductores.ultimo.mostrarImagen();
    await tester.pump();
    expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
    expect(find.byWidgetPredicate(_iconoVideo), findsNothing);
  });

  testWidgets('muestra la imagen completa a su proporción, sin recortarla', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    final proporcion = tester.widget<AspectRatio>(
      find
          .ancestor(
            of: find.byKey(const Key('video-en-vivo')),
            matching: find.byType(AspectRatio),
          )
          .first,
    );
    expect(proporcion.aspectRatio, 4 / 3);
    final caja = tester.getSize(find.byKey(const Key('video-en-vivo')));
    expect(caja.width / caja.height, closeTo(4 / 3, 0.01));
  });

  testWidgets('reintenta mientras la cámara empieza a transmitir', (
    tester,
  ) async {
    reproductores.fallasAlIniciar = 2;
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(find.byKey(const Key('video-en-vivo')), findsNothing);
    await esperar(tester, 2 * pausaEntreIntentos.inSeconds);
    expect(reproductores.creados, hasLength(3));
    expect(reproductores.creados.take(2).every((r) => r.desechado), isTrue);
    expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
    expect(vivo.abiertas, hasLength(1));
    expect(vivo.cerradas, isEmpty);
  });

  testWidgets('cambia un reproductor que no termina de iniciar por otro, hasta '
      'que llega la imagen', (tester) async {
    // Like the web player on a playlist that answered 404 before the camera published.
    reproductores.cuelguesAlIniciar = 2;
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(reproductores.creados, hasLength(1));
    await esperar(tester, esperaInicio.inSeconds);
    expect(reproductores.creados.single.desechado, isTrue);
    await esperar(tester, pausaEntreIntentos.inSeconds);
    expect(reproductores.creados, hasLength(2));
    expect(find.byKey(const Key('video-en-vivo')), findsNothing);
    await esperar(
      tester,
      esperaInicio.inSeconds + pausaEntreIntentos.inSeconds,
    );
    // The third player starts within esperaPrimerFotograma: the session goes on.
    expect(reproductores.creados, hasLength(3));
    expect(reproductores.creados.take(2).every((r) => r.desechado), isTrue);
    expect(reproductores.ultimo.desechado, isFalse);
    expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
    await esperar(tester, esperaPrimerFotograma.inSeconds);
    expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
    expect(reproductores.creados, hasLength(3));
    expect(vivo.abiertas, hasLength(1));
    expect(vivo.cerradas, isEmpty);
  });

  group('comprobarLista', () {
    const lista = 'https://api.tetengo.pe/vivo/camaras/c1/index.m3u8?token=t';
    late AdaptadorFalso http;
    late Dio dio;

    setUp(() {
      http = AdaptadorFalso();
      dio = Dio()..httpClientAdapter = http;
    });

    test('con la lista servida sigue', () async {
      http.cuando('GET', lista, const Respuesta(200, '#EXTM3U'));
      await comprobarLista(dio, Uri.parse(lista));
      expect(http.hechas('GET', lista), hasLength(1));
    });

    test('mientras la cámara no publica (404) falla', () async {
      http.cuando('GET', lista, const Respuesta(404));
      await expectLater(
        comprobarLista(dio, Uri.parse(lista)),
        throwsA(
          isA<ListaNoDisponible>().having((e) => e.estado, 'estado', 404),
        ),
      );
    });

    test(
      'si la petición no llega a responder, deja probar al reproductor',
      () async {
        http.sinConexion = true;
        await comprobarLista(dio, Uri.parse(lista));
      },
    );

    test(
      'ReproductorHls no crea el reproductor de la plataforma sin lista',
      () async {
        http.cuando('GET', lista, const Respuesta(404));
        final r = ReproductorHls(Uri.parse(lista), dio: dio);
        addTearDown(r.dispose);
        // With no platform plugin in tests, reaching video_player would fail differently.
        await expectLater(r.iniciar(), throwsA(isA<ListaNoDisponible>()));
        expect(r.listo, isFalse);
      },
    );
  });

  group('si la transmisión se corta', () {
    Future<void> verCorte(WidgetTester tester) async {
      expect(vivo.cerradas, ['v-1']);
      expect(reproductores.ultimo.desechado, isTrue);
      expect(
        find.text('La cámara de la Sala no está disponible'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Perdió la conexión a las 10:42, así que no podemos mostrarte la '
          'habitación.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.textContaining('EN VIVO', findRichText: true), findsNothing);
      // A session that ended cannot resume: «Ver en vivo» opens a new one.
      reproductores
        ..conImagen = true
        ..fallasAlIniciar = 0
        ..cuelguesAlIniciar = 0;
      await tocar(tester, find.text('Ver en vivo'));
      expect(vivo.abiertas, hasLength(2));
      expect(reproductores.ultimo.url.queryParameters['token'], 't-v-2');
      expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
      expect(
        find.textContaining('EN VIVO · 00:00', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Ver en vivo'), findsNothing);
    }

    testWidgets('por un error de reproducción', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
      reproductores.ultimo.cortar();
      await tester.pumpAndSettle();
      await verCorte(tester);
    });

    testWidgets('porque la imagen deja de avanzar', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
      reproductores.ultimo.congelado = true;
      await esperar(tester, esperaSinImagen.inSeconds + 1);
      await verCorte(tester);
    });

    testWidgets('porque la primera imagen no llega a tiempo', (tester) async {
      reproductores.conImagen = false;
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
      await esperar(tester, esperaPrimerFotograma.inSeconds - 1);
      expect(vivo.cerradas, isEmpty);
      await esperar(tester, 1);
      await verCorte(tester);
    });

    testWidgets('porque ningún reproductor termina de iniciar a tiempo', (
      tester,
    ) async {
      reproductores.cuelguesAlIniciar = 1000;
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
      await esperar(tester, esperaPrimerFotograma.inSeconds - 1);
      expect(vivo.cerradas, isEmpty);
      // One attempt every esperaInicio + pausaEntreIntentos: 0 s, 8 s and 16 s.
      expect(reproductores.creados, hasLength(3));
      await esperar(tester, 1);
      expect(reproductores.creados.every((r) => r.desechado), isTrue);
      await verCorte(tester);
      // The last attempt's time limit runs out during the new session and leaves it alone.
      await esperar(tester, esperaInicio.inSeconds);
      expect(reproductores.creados, hasLength(4));
      expect(reproductores.ultimo.desechado, isFalse);
      expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
      expect(vivo.cerradas, ['v-1']);
    });

    testWidgets('al salir confirma el acceso registrado', (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
      await esperar(tester, 5);
      reproductores.ultimo.cortar();
      await tester.pumpAndSettle();
      await tocar(tester, find.text('Cerrar la vista en vivo'));
      expect(vivo.cerradas, ['v-1']);
      expect(find.text('Viste la Sala en vivo durante 5 s.'), findsOneWidget);
    });
  });

  testWidgets('cambia lo que muestra la transmisión y explica cada modo', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    expect(_elegido(tester, 'Video'), isTrue);
    expect(_elegido(tester, 'Video y postura'), isFalse);

    await tocar(tester, find.text('Video y postura'));
    expect(vivo.cambios, [('v-1', ModoVista.videoConPostura)]);
    expect(_elegido(tester, 'Video y postura'), isTrue);
    expect(_elegido(tester, 'Video'), isFalse);
    expect(
      find.text(
        'Ves la Sala y la postura de Rosa en este momento. La transmisión no '
        'se graba.',
      ),
      findsOneWidget,
    );

    await tocar(tester, find.text('Solo postura'));
    expect(vivo.cambios.last, ('v-1', ModoVista.soloPostura));
    expect(
      find.text(
        'Ves la postura de Rosa en este momento. La transmisión no se graba.',
      ),
      findsOneWidget,
    );

    // Tapping the current mode sends nothing.
    await tocar(tester, find.text('Solo postura'));
    expect(vivo.cambios, hasLength(2));

    // A new session keeps the chosen mode.
    reproductores.ultimo.cortar();
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Ver en vivo'));
    expect(vivo.modosPedidos, [null, ModoVista.soloPostura]);
    expect(_elegido(tester, 'Solo postura'), isTrue);
  });

  testWidgets('desde una alerta cada modo se explica sin el nombre', (
    tester,
  ) async {
    await abrir(
      tester,
      Rutas.alerta('a-1'),
      alertas: AlertasRepositorioFalso([caidaSala()]),
    );
    await tocar(tester, find.text('Ver en vivo'));
    expect(
      find.text('Ves la habitación. La transmisión no se graba.'),
      findsOneWidget,
    );
    await tocar(tester, find.text('Solo postura'));
    expect(
      find.text('Ves la postura detectada. La transmisión no se graba.'),
      findsOneWidget,
    );
  });

  testWidgets('si el cambio de modo falla, lo dice y mantiene el modo', (
    tester,
  ) async {
    vivo.errorCambiar = const ProblemaApi(
      codigo: 'VALIDACION',
      detalle: 'Detalle del backend.',
      estado: 400,
    );
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    await tocar(tester, find.text('Video y postura'));
    expect(find.text('Detalle del backend.'), findsOneWidget);
    expect(_elegido(tester, 'Video'), isTrue);
    expect(
      find.text('Ves la Sala en este momento. La transmisión no se graba.'),
      findsOneWidget,
    );
  });

  testWidgets('en segundo plano cierra la sesión y al volver abre otra', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    final primero = reproductores.ultimo;
    segundoPlano(tester);
    await tester.pump();
    expect(vivo.cerradas, ['v-1']);
    expect(primero.desechado, isTrue);
    await esperar(tester, esperaPrimerFotograma.inSeconds + 1);
    expect(vivo.abiertas, hasLength(1));

    primerPlano(tester);
    await tester.pumpAndSettle();
    expect(vivo.abiertas, hasLength(2));
    expect(reproductores.creados, hasLength(2));
    expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);

    await tocar(tester, find.text('Cerrar la vista en vivo'));
    expect(vivo.cerradas, ['v-1', 'v-2']);
  });

  testWidgets('con la cámara no disponible, el segundo plano no abre sesión', (
    tester,
  ) async {
    camaras.camaras = [sala(estado: EstadoConexion.desconectada)];
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Ver en vivo'));
    segundoPlano(tester);
    await tester.pump();
    primerPlano(tester);
    await tester.pumpAndSettle();
    expect(vivo.abiertas, isEmpty);
  });

  group('WebRTC (WHEP) con LL-HLS de respaldo', () {
    const whep =
        'https://api.tetengo.pe/vivo-webrtc/camaras/c1/whep?token=t-v-1';

    setUp(() => vivo.conWebrtc = true);

    Future<void> verEnVivo(WidgetTester tester) async {
      await abrir(tester, Rutas.camara('c1'));
      await tocar(tester, find.text('Ver en vivo'));
    }

    /// The session went on over LL-HLS: one session, the WebRTC players gone, the HLS one showing.
    void verHls() {
      expect(webrtc.creados.every((r) => r.desechado), isTrue);
      expect(reproductores.creados, hasLength(1));
      expect(
        reproductores.ultimo.url.toString(),
        'https://api.tetengo.pe/vivo/camaras/c1/index.m3u8?token=t-v-1',
      );
      expect(reproductores.ultimo.desechado, isFalse);
      expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
      expect(vivo.abiertas, hasLength(1));
      expect(vivo.cerradas, isEmpty);
    }

    testWidgets('con urlWebrtc ve en vivo por WebRTC', (tester) async {
      await verEnVivo(tester);
      expect(webrtc.creados, hasLength(1));
      expect(webrtc.ultimo.url.toString(), whep);
      expect(webrtc.tokens, ['t-v-1']);
      expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
      await esperar(tester, esperaPrimerFotograma.inSeconds + 5);
      expect(reproductores.creados, isEmpty);
      expect(webrtc.creados, hasLength(1));
      expect(webrtc.ultimo.desechado, isFalse);
      expect(
        find.textContaining('EN VIVO · 00:25', findRichText: true),
        findsOneWidget,
      );
      await tocar(tester, find.text('Cerrar la vista en vivo'));
      expect(webrtc.ultimo.desechado, isTrue);
      expect(vivo.cerradas, ['v-1']);
    });

    testWidgets('sin urlWebrtc ve en vivo solo por LL-HLS', (tester) async {
      vivo.conWebrtc = false;
      await verEnVivo(tester);
      expect(webrtc.creados, isEmpty);
      expect(reproductores.creados, hasLength(1));
      expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
    });

    testWidgets('si WebRTC no muestra imagen a tiempo pasa a LL-HLS', (
      tester,
    ) async {
      webrtc.conImagen = false;
      await verEnVivo(tester);
      expect(find.byKey(const Key('video-en-vivo')), findsNothing);
      await esperar(tester, esperaWebrtc.inSeconds - 1);
      expect(reproductores.creados, isEmpty);
      await esperar(tester, 1);
      verHls();
      // The session stays on LL-HLS.
      await esperar(tester, esperaPrimerFotograma.inSeconds);
      expect(webrtc.creados, hasLength(1));
      expect(reproductores.creados, hasLength(1));
    });

    testWidgets('si la oferta WebRTC no recibe respuesta pasa a LL-HLS', (
      tester,
    ) async {
      webrtc.cuelguesAlIniciar = 1;
      await verEnVivo(tester);
      await esperar(tester, esperaWebrtc.inSeconds);
      verHls();
    });

    testWidgets('si MediaMTX rechaza la oferta pasa a LL-HLS en el acto', (
      tester,
    ) async {
      webrtc
        ..fallasAlIniciar = 1
        ..falla = () => const OfertaRechazada(400);
      await verEnVivo(tester);
      verHls();
    });

    testWidgets(
      'mientras la cámara empieza a publicar (404) vuelve a ofrecer',
      (tester) async {
        webrtc
          ..fallasAlIniciar = 2
          ..falla = () => const OfertaRechazada(404);
        await verEnVivo(tester);
        expect(find.byKey(const Key('video-en-vivo')), findsNothing);
        await tester.pump(pausaEntreOfertas);
        await tester.pump(pausaEntreOfertas);
        expect(webrtc.creados, hasLength(3));
        expect(webrtc.creados.take(2).every((r) => r.desechado), isTrue);
        expect(find.byKey(const Key('video-en-vivo')), findsOneWidget);
        expect(reproductores.creados, isEmpty);
      },
    );

    testWidgets('si WebRTC responde 404 demasiado tiempo pasa a LL-HLS', (
      tester,
    ) async {
      // A route that always answers 404 (e.g. a proxy without WebRTC) must not cost the live view.
      webrtc
        ..fallasAlIniciar = 1000
        ..falla = () => const OfertaRechazada(404);
      await verEnVivo(tester);
      await esperar(tester, esperaPublicacionWebrtc.inSeconds - 1);
      expect(reproductores.creados, isEmpty);
      await esperar(tester, 1);
      await tester.pump(pausaEntreOfertas);
      verHls();
    });

    testWidgets('si WebRTC se corta a mitad sigue la misma sesión por LL-HLS', (
      tester,
    ) async {
      await verEnVivo(tester);
      await esperar(tester, 5);
      webrtc.ultimo.cortar();
      await tester.pump();
      verHls();
      expect(
        find.textContaining('EN VIVO · 00:05', findRichText: true),
        findsOneWidget,
      );
      // An HLS cut afterwards ends the session as before, and a new one tries WebRTC again.
      reproductores.ultimo.cortar();
      await tester.pumpAndSettle();
      expect(vivo.cerradas, ['v-1']);
      await tocar(tester, find.text('Ver en vivo'));
      expect(webrtc.creados, hasLength(2));
      expect(webrtc.tokens.last, 't-v-2');
      expect(reproductores.creados, hasLength(1));
    });

    testWidgets('si la imagen WebRTC se congela pasa a LL-HLS', (tester) async {
      await verEnVivo(tester);
      webrtc.ultimo.congelado = true;
      await esperar(tester, esperaSinImagenWebrtc.inSeconds - 1);
      expect(reproductores.creados, isEmpty);
      await esperar(tester, 1);
      verHls();
    });

    testWidgets('si WebRTC se corta a mitad, LL-HLS tiene esperaRescateHls', (
      tester,
    ) async {
      reproductores.conImagen = false;
      await verEnVivo(tester);
      await esperar(tester, 3);
      webrtc.ultimo.cortar();
      await tester.pump();
      await esperar(tester, esperaRescateHls.inSeconds - 1);
      expect(vivo.cerradas, isEmpty);
      await esperar(tester, 1);
      expect(vivo.cerradas, ['v-1']);
      expect(
        find.text('La cámara de la Sala no está disponible'),
        findsOneWidget,
      );
    });
  });

  group('preparar', () {
    testWidgets('la pantalla de la cámara pide preparar una vez al abrirse', (
      tester,
    ) async {
      await abrir(tester, Rutas.camara('c1'));
      await verHasta(tester, find.text('Disponible ahora'));
      await esperar(tester, 5);
      expect(vivo.preparadas, ['c1']);
      await tocar(tester, find.text('Ver en vivo'));
      expect(vivo.preparadas, ['c1']);
      expect(vivo.abiertas, [('c1', null)]);
    });

    testWidgets('una alerta abierta pide preparar su cámara una vez', (
      tester,
    ) async {
      await abrir(
        tester,
        Rutas.alerta('a-1'),
        alertas: AlertasRepositorioFalso([caidaSala()]),
      );
      await esperar(tester, 2 * PantallaAlerta.refresco.inSeconds + 1);
      expect(vivo.preparadas, ['c1']);
    });

    testWidgets('el inicio no pide preparar', (tester) async {
      await abrir(tester, Rutas.inicio);
      expect(vivo.preparadas, isEmpty);
    });
  });

  group('VistaEnVivoRepositorioApi', () {
    late AdaptadorFalso http;
    late VistaEnVivoRepositorio repo;

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
      repo = c.read(vistaEnVivoRepositorioProvider);
    });

    const url = 'https://api.tetengo.pe/vivo/camaras/c1/index.m3u8?token=abc';

    test('POST /api/camaras/{id}/vista-en-vivo', () async {
      http.cuando(
        'POST',
        '/api/camaras/c1/vista-en-vivo',
        const Respuesta(201, {
          'sesionId': 'v-9',
          'urlTransmision': url,
          'expiraEn': '2026-09-23T15:52:00Z',
          'modo': 'VIDEO_CON_POSTURA',
        }),
      );
      final s = await repo.abrir('c1', alertaId: 'a-1');
      expect(s.sesionId, 'v-9');
      expect(s.urlTransmision.toString(), url);
      expect(s.expiraEn!.toUtc(), DateTime.utc(2026, 9, 23, 15, 52));
      expect(s.modo, ModoVista.videoConPostura);
      expect(http.peticiones.single.method, 'POST');
      // Without a chosen mode the camera keeps its own.
      expect(http.peticiones.single.data, {'alertaId': 'a-1'});

      await repo.abrir('c1', modo: ModoVista.soloPostura);
      expect(http.peticiones.last.data, {
        'alertaId': null,
        'modo': 'SOLO_POSTURA',
      });
    });

    test('POST con errores del contrato', () async {
      http.cuando(
        'POST',
        '/api/camaras/c1/vista-en-vivo',
        Respuesta.problema(
          409,
          'CAMARA_EN_PAUSA',
          extras: {'pausadaHasta': '2026-09-23T16:42:00Z'},
        ),
      );
      await expectLater(
        repo.abrir('c1'),
        throwsA(
          isA<ProblemaApi>()
              .having((p) => p.codigo, 'codigo', 'CAMARA_EN_PAUSA')
              .having(
                (p) => p.extras['pausadaHasta'],
                'pausadaHasta',
                '2026-09-23T16:42:00Z',
              ),
        ),
      );
    });

    test('urlWebrtc cuando la API ofrece WebRTC', () async {
      const whep =
          'https://api.tetengo.pe/vivo-webrtc/camaras/c1/whep?token=abc';
      http
        ..cuando(
          'POST',
          '/api/camaras/c1/vista-en-vivo',
          const Respuesta(201, {
            'sesionId': 'v-9',
            'urlTransmision': url,
            'urlWebrtc': whep,
          }),
        )
        ..cuando(
          'POST',
          '/api/camaras/c1/vista-en-vivo',
          const Respuesta(201, {
            'sesionId': 'v-10',
            'urlTransmision': url,
            'urlWebrtc': null,
          }),
        );
      final s = await repo.abrir('c1');
      expect(s.urlWebrtc.toString(), whep);
      expect(s.tokenEspectador, 'abc');
      // Null or absent (an older API): HLS only.
      final sinWebrtc = await repo.abrir('c1');
      expect(sinWebrtc.urlWebrtc, isNull);
      expect(sinWebrtc.tokenEspectador, 'abc');
    });

    test('POST /api/vista-en-vivo/preparar', () async {
      http.cuando(
        'POST',
        '/api/vista-en-vivo/preparar',
        const Respuesta(204, null),
      );
      await repo.preparar('c1');
      expect(http.peticiones.single.method, 'POST');
      expect(http.peticiones.single.path, '/api/vista-en-vivo/preparar');
      expect(http.peticiones.single.data, {'camaraId': 'c1'});
    });

    test('sin modo en la respuesta es VIDEO', () async {
      http.cuando(
        'POST',
        '/api/camaras/c1/vista-en-vivo',
        const Respuesta(201, {'sesionId': 'v-9', 'urlTransmision': url}),
      );
      expect((await repo.abrir('c1')).modo, ModoVista.video);
    });

    test('PATCH /api/vista-en-vivo/{sesionId}', () async {
      http.cuando(
        'PATCH',
        '/api/vista-en-vivo/v-9',
        const Respuesta(200, {'sesionId': 'v-9', 'modo': 'SOLO_POSTURA'}),
      );
      expect(
        await repo.cambiarModo('v-9', ModoVista.soloPostura),
        ModoVista.soloPostura,
      );
      expect(http.peticiones.single.method, 'PATCH');
      expect(http.peticiones.single.data, {'modo': 'SOLO_POSTURA'});
    });

    test('PATCH con un error', () async {
      http.cuando(
        'PATCH',
        '/api/vista-en-vivo/v-9',
        Respuesta.problema(400, 'VALIDACION'),
      );
      await expectLater(
        repo.cambiarModo('v-9', ModoVista.video),
        throwsA(isA<ProblemaApi>()),
      );
    });

    test('DELETE /api/vista-en-vivo/{sesionId}', () async {
      http.cuando(
        'DELETE',
        '/api/vista-en-vivo/v-9',
        const Respuesta(204, null),
      );
      await repo.cerrar('v-9');
      expect(http.hechas('DELETE', '/api/vista-en-vivo/v-9'), hasLength(1));
    });
  });
}

/// The app goes to the background, through the states the platform reports.
void segundoPlano(WidgetTester tester) {
  for (final e in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(e);
  }
}

void primerPlano(WidgetTester tester) {
  for (final e in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(e);
  }
}

bool _iconoVideo(Widget w) => w is Icono && w.icono == Ico.video;

/// Whether the mode chip [texto] is the chosen one.
bool _elegido(WidgetTester tester, String texto) => tester
    .widget<ChipOpcion>(
      find.ancestor(of: find.text(texto), matching: find.byType(ChipOpcion)),
    )
    .elegido;
