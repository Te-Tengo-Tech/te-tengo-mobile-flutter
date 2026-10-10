import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/dispositivo/pantalla_completa.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/clip_evento.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/clip_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

/// Records what the clip asked of the full screen.
class PantallaCompletaFalsa implements ModoPantallaCompleta {
  PantallaCompletaFalsa({this.disponible = true});

  @override
  bool disponible;
  int entradas = 0;
  int salidas = 0;
  final _cambios = StreamController<bool>.broadcast();

  /// The browser left full screen by itself (Esc, a swipe).
  void salirDesdeElNavegador() => _cambios.add(false);

  @override
  void entrar() => entradas++;

  @override
  void salir() => salidas++;

  @override
  Stream<bool> get cambios => _cambios.stream;
}

void main() {
  const url1 = 'https://r2.example/a-1.mp4?firma=1';
  const url2 = 'https://r2.example/a-1.mp4?firma=2';
  final inicio = DateTime(2026, 9, 23, 10, 42, 20);
  late DateTime ahora;
  late AlertasRepositorioFalso alertas;
  late FabricaClipFalsa clips;
  late PantallaCompletaFalsa pantalla;

  setUp(() {
    ahora = inicio;
    alertas = AlertasRepositorioFalso([caidaSala()]);
    clips = FabricaClipFalsa();
    pantalla = PantallaCompletaFalsa();
  });

  Future<void> abrir(WidgetTester tester) async {
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
      clips: clips,
      reloj: () => ahora,
      overrides: [pantallaCompletaProvider.overrideWithValue(pantalla)],
    );
    // A fall folds its clip: open «Clip del evento».
    await tocar(tester, find.text('Clip del evento'));
    await verHasta(tester, find.bySemanticsLabel('Avance del clip'));
    await tester.ensureVisible(
      find.bySemanticsLabel('Ver el clip en pantalla completa'),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocarEtiqueta(WidgetTester tester, String etiqueta) async {
    await tester.tap(find.bySemanticsLabel(etiqueta).last);
    await tester.pumpAndSettle();
  }

  /// Lets the retries after a failure run (one second apart).
  Future<void> esperarReintentos(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();
  }

  group('controles', () {
    testWidgets('reproducir y pausar', (tester) async {
      await abrir(tester);
      await tocarEtiqueta(tester, 'Reproducir clip');
      expect(clips.ultimo.reproduciendo, isTrue);
      expect(find.bySemanticsLabel('Pausar clip'), findsOneWidget);
      clips.ultimo.avanzar(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('0:03 / 0:12'), findsOneWidget);
      await tocarEtiqueta(tester, 'Pausar clip');
      expect(clips.ultimo.reproduciendo, isFalse);
      expect(find.bySemanticsLabel('Reproducir clip'), findsOneWidget);
    });

    testWidgets('la pista se toca, se arrastra y se mueve con el lector', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester);
      final pista = tester.getRect(find.bySemanticsLabel('Avance del clip'));
      await tester.tapAt(
        Offset(pista.left + pista.width * .75, pista.center.dy),
      );
      await tester.pumpAndSettle();
      expect(clips.ultimo.buscadas.last, const Duration(seconds: 9));
      expect(find.text('0:09 / 0:12'), findsOneWidget);

      // Dragging while it plays pauses it, seeks along and plays on.
      await tocarEtiqueta(tester, 'Reproducir clip');
      await tester.dragFrom(
        Offset(pista.left + pista.width * .25, pista.center.dy),
        Offset(pista.width * .25, 0),
      );
      await tester.pumpAndSettle();
      expect(clips.ultimo.buscadas.last, const Duration(seconds: 6));
      expect(clips.ultimo.reproduciendo, isTrue);
      expect(find.text('0:06 / 0:12'), findsOneWidget);

      final nodo = tester.getSemantics(
        find.bySemanticsLabel('Avance del clip'),
      );
      expect(nodo.value, '0:06');
      expect(nodo.increasedValue, '0:11');
      tester.semantics.performAction(
        find.semantics.byLabel('Avance del clip'),
        SemanticsAction.increase,
      );
      await tester.pumpAndSettle();
      expect(clips.ultimo.buscadas.last, const Duration(seconds: 11));
      semantica.dispose();
    });

    testWidgets('-5 s y +5 s, sin salir del clip', (tester) async {
      await abrir(tester);
      await tocarEtiqueta(tester, 'Reproducir clip');
      clips.ultimo.avanzar(const Duration(seconds: 6));
      await tocarEtiqueta(tester, 'Pausar clip');
      await tocarEtiqueta(tester, 'Adelantar 5 segundos');
      expect(find.text('0:11 / 0:12'), findsOneWidget);
      await tocarEtiqueta(tester, 'Adelantar 5 segundos');
      expect(find.text('0:12 / 0:12'), findsOneWidget);
      await tocarEtiqueta(tester, 'Retroceder 5 segundos');
      await tocarEtiqueta(tester, 'Retroceder 5 segundos');
      await tocarEtiqueta(tester, 'Retroceder 5 segundos');
      expect(find.text('0:00 / 0:12'), findsOneWidget);
      expect(clips.ultimo.buscadas, const [
        Duration(seconds: 11),
        Duration(seconds: 12),
        Duration(seconds: 7),
        Duration(seconds: 2),
        Duration.zero,
      ]);
    });

    testWidgets('al terminar ofrece volver a verlo desde el inicio', (
      tester,
    ) async {
      await abrir(tester);
      await tocarEtiqueta(tester, 'Reproducir clip');
      clips.ultimo.avanzar(const Duration(seconds: 12));
      await tester.pumpAndSettle();
      expect(find.text('0:12 / 0:12'), findsOneWidget);
      await tocarEtiqueta(tester, 'Volver a ver el clip');
      expect(clips.ultimo.buscadas.last, Duration.zero);
      expect(clips.ultimo.reproduciendo, isTrue);
      expect(find.text('0:00 / 0:12'), findsOneWidget);
      expect(find.bySemanticsLabel('Pausar clip'), findsOneWidget);
    });

    testWidgets('sin duración conocida reproduce, pero no busca', (
      tester,
    ) async {
      clips.duracion = Duration.zero;
      await abrir(tester);
      expect(find.text('0:00 / 0:12'), findsOneWidget);
      await tocarEtiqueta(tester, 'Adelantar 5 segundos');
      await tocarEtiqueta(tester, 'Retroceder 5 segundos');
      final pista = tester.getRect(find.bySemanticsLabel('Avance del clip'));
      await tester.tapAt(pista.centerRight - const Offset(4, 0));
      await tester.pumpAndSettle();
      expect(clips.ultimo.buscadas, isEmpty);

      await tocarEtiqueta(tester, 'Reproducir clip');
      expect(clips.ultimo.reproduciendo, isTrue);
      clips.ultimo.avanzar(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('0:03 / 0:12'), findsOneWidget);
    });

    testWidgets('la velocidad cambia en ciclo y se mantiene al renovar', (
      tester,
    ) async {
      await abrir(tester);
      expect(find.text('1×'), findsOneWidget);
      await tocarEtiqueta(tester, 'Velocidad 1×. Cambiar la velocidad');
      expect(find.text('1,5×'), findsOneWidget);
      expect(clips.ultimo.velocidades, [1.5]);
      await tocarEtiqueta(tester, 'Velocidad 1,5×. Cambiar la velocidad');
      await tocarEtiqueta(tester, 'Velocidad 2×. Cambiar la velocidad');
      expect(find.text('0,5×'), findsOneWidget);
      await tocarEtiqueta(tester, 'Velocidad 0,5×. Cambiar la velocidad');
      expect(find.text('1×'), findsOneWidget);
      expect(clips.ultimo.velocidades, [1.5, 2, 0.5, 1]);
    });

    testWidgets('cada control mide al menos 48 dp', (tester) async {
      await abrir(tester);
      for (final etiqueta in [
        'Reproducir clip',
        'Retroceder 5 segundos',
        'Adelantar 5 segundos',
        'Ver el clip en pantalla completa',
        'Velocidad 1×. Cambiar la velocidad',
        'Avance del clip',
      ]) {
        final tamano = tester.getSize(find.bySemanticsLabel(etiqueta));
        expect(tamano.height, greaterThanOrEqualTo(48), reason: etiqueta);
        expect(tamano.width, greaterThanOrEqualTo(48), reason: etiqueta);
      }
    });
  });

  group('URL del clip que vence', () {
    testWidgets('pausado más allá de expiraEn, pide otra URL y sigue donde '
        'estaba', (tester) async {
      alertas.enlaces.addAll([
        EnlaceClip(url: url1, expiraEn: inicio.add(const Duration(minutes: 5))),
        EnlaceClip(
          url: url2,
          expiraEn: inicio.add(const Duration(minutes: 15)),
        ),
      ]);
      await abrir(tester);
      await tocarEtiqueta(tester, 'Reproducir clip');
      clips.ultimo.avanzar(const Duration(seconds: 4));
      await tocarEtiqueta(tester, 'Pausar clip');

      ahora = inicio.add(const Duration(minutes: 6));
      await tester.pump(const Duration(minutes: 6));
      // An idle screen does not ask for URLs.
      expect(alertas.clips, ['a-1']);
      await tocarEtiqueta(tester, 'Reproducir clip');
      expect(alertas.clips, ['a-1', 'a-1']);
      expect(clips.creados.map((c) => c.url), [url1, url2]);
      expect(clips.creados.first.dispuesto, isTrue);
      expect(clips.ultimo.buscadas, [const Duration(seconds: 4)]);
      expect(clips.ultimo.reproduciendo, isTrue);
      expect(find.text('0:04 / 0:12'), findsOneWidget);
      expect(find.text('Clip no disponible'), findsNothing);
    });

    testWidgets('abierto después de que la URL venció, pide otra antes de '
        'usarla', (tester) async {
      alertas.enlaces.addAll([
        EnlaceClip(
          url: url1,
          expiraEn: inicio.subtract(const Duration(minutes: 1)),
        ),
        EnlaceClip(url: url2, expiraEn: inicio.add(const Duration(minutes: 5))),
      ]);
      await abrir(tester);
      expect(alertas.clips, ['a-1', 'a-1']);
      expect(clips.creados.map((c) => c.url), [url2]);
      expect(find.text('0:00 / 0:12'), findsOneWidget);
    });

    testWidgets('mientras se reproduce, la renueva antes de expiraEn sin '
        'cortar', (tester) async {
      alertas.enlaces.addAll([
        EnlaceClip(url: url1, expiraEn: inicio.add(const Duration(minutes: 5))),
        EnlaceClip(
          url: url2,
          expiraEn: inicio.add(const Duration(minutes: 10)),
        ),
      ]);
      await abrir(tester);
      await tocarEtiqueta(tester, 'Reproducir clip');
      final primero = clips.ultimo;
      // It keeps playing (between 0:03 and 0:04) until 30 s before expiraEn.
      for (var s = 1; s <= 270 && !primero.dispuesto; s++) {
        primero.moverA(Duration(seconds: s.isEven ? 3 : 4));
        ahora = inicio.add(Duration(seconds: s));
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();
      expect(clips.creados.map((c) => c.url), [url1, url2]);
      expect(alertas.clips, ['a-1', 'a-1']);
      expect(primero.dispuesto, isTrue);
      expect(clips.ultimo.buscadas, [primero.posicion]);
      expect(clips.ultimo.reproduciendo, isTrue);
      expect(find.bySemanticsLabel('Pausar clip'), findsOneWidget);
    });

    testWidgets('si el reproductor falla, pide otra URL y sigue en la misma '
        'posición', (tester) async {
      alertas.enlaces.addAll([
        const EnlaceClip(url: url1),
        const EnlaceClip(url: url2),
      ]);
      await abrir(tester);
      await tocarEtiqueta(tester, 'Reproducir clip');
      clips.ultimo.avanzar(const Duration(seconds: 5));
      clips.ultimo.fallar();
      await esperarReintentos(tester);
      expect(alertas.clips, ['a-1', 'a-1']);
      expect(clips.creados.map((c) => c.url), [url1, url2]);
      expect(clips.ultimo.buscadas, [const Duration(seconds: 5)]);
      expect(clips.ultimo.reproduciendo, isTrue);
      expect(find.text('0:05 / 0:12'), findsOneWidget);
      expect(find.text('Clip no disponible'), findsNothing);
    });

    testWidgets('si se queda reproduciendo sin avanzar, pide otra URL y '
        'sigue', (tester) async {
      alertas.enlaces.addAll([
        const EnlaceClip(url: url1),
        const EnlaceClip(url: url2),
      ]);
      await abrir(tester);
      await tocarEtiqueta(tester, 'Reproducir clip');
      clips.ultimo.avanzar(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
      // Stuck at 0:02 (the web plugin can swallow the error of an expired URL).
      await tester.pump(const Duration(seconds: 9));
      await esperarReintentos(tester);
      expect(clips.creados.map((c) => c.url), [url1, url2]);
      expect(clips.ultimo.buscadas, [const Duration(seconds: 2)]);
      expect(clips.ultimo.reproduciendo, isTrue);
      expect(find.text('Clip no disponible'), findsNothing);
    });

    testWidgets('si el reproductor no termina de abrir, prueba con otra URL', (
      tester,
    ) async {
      alertas.enlaces.addAll([
        const EnlaceClip(url: url1),
        const EnlaceClip(url: url2),
      ]);
      clips.cuelgan.add(url1);
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: alertas,
        clips: clips,
        overrides: [pantallaCompletaProvider.overrideWithValue(pantalla)],
      );
      await tocar(tester, find.text('Clip del evento'));
      await tester.pump(const Duration(seconds: 10));
      await esperarReintentos(tester);
      await verHasta(tester, find.text('0:00 / 0:12'));
      expect(clips.creados.map((c) => c.url), [url1, url2]);
      expect(clips.ultimo.listo, isTrue);
    });

    testWidgets('si al renovarla el clip ya se eliminó, lo informa', (
      tester,
    ) async {
      await abrir(tester);
      alertas.errorClip = const ProblemaApi(
        codigo: 'CLIP_ELIMINADO',
        detalle: 'Se eliminó.',
        estado: 410,
      );
      clips.ultimo.fallar();
      await esperarReintentos(tester);
      expect(find.text('La grabación ya no está disponible'), findsOneWidget);
    });

    testWidgets('si el reproductor sigue fallando, el clip no está '
        'disponible', (tester) async {
      clips.fallanAlIniciar.add('https://clips.tetengo.pe/a-1.mp4');
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: alertas,
        clips: clips,
        overrides: [pantallaCompletaProvider.overrideWithValue(pantalla)],
      );
      await tocar(tester, find.text('Clip del evento'));
      await esperarReintentos(tester);
      await verHasta(tester, find.text('Clip no disponible'));
      expect(clips.creados, hasLength(3));
      expect(clips.creados.every((c) => c.dispuesto), isTrue);
    });
  });

  group('pantalla completa', () {
    testWidgets('entra y sale con los mismos controles', (tester) async {
      await abrir(tester);
      await tocarEtiqueta(tester, 'Ver el clip en pantalla completa');
      expect(pantalla.entradas, 1);
      expect(find.byType(PantallaClipCompleta), findsOneWidget);
      expect(
        find.text('Caída en la Sala · 10:42', findRichText: true),
        findsOneWidget,
      );

      await tocarEtiqueta(tester, 'Reproducir clip');
      expect(clips.creados, hasLength(1));
      expect(clips.ultimo.reproduciendo, isTrue);
      await tocarEtiqueta(tester, 'Adelantar 5 segundos');
      expect(find.text('0:05 / 0:12'), findsOneWidget);

      await tocarEtiqueta(tester, 'Salir de pantalla completa');
      expect(find.byType(PantallaClipCompleta), findsNothing);
      expect(pantalla.salidas, 1);
      // The same playback goes on inline.
      expect(find.bySemanticsLabel('Pausar clip'), findsOneWidget);
      expect(find.text('0:05 / 0:12'), findsOneWidget);
    });

    testWidgets('volver atrás también sale y restaura', (tester) async {
      await abrir(tester);
      await tocarEtiqueta(tester, 'Ver el clip en pantalla completa');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PantallaClipCompleta), findsNothing);
      expect(pantalla.salidas, 1);
    });

    testWidgets('si el navegador sale de pantalla completa, la vista se '
        'cierra', (tester) async {
      await abrir(tester);
      await tocarEtiqueta(tester, 'Ver el clip en pantalla completa');
      pantalla.salirDesdeElNavegador();
      await tester.pumpAndSettle();
      expect(find.byType(PantallaClipCompleta), findsNothing);
      expect(pantalla.salidas, 1);
    });

    testWidgets('sin la API (Safari en iPhone) usa la pantalla completa del '
        'video', (tester) async {
      pantalla.disponible = false;
      clips.nativa = true;
      await abrir(tester);
      await tocarEtiqueta(tester, 'Ver el clip en pantalla completa');
      expect(clips.ultimo.pantallasNativas, 1);
      expect(pantalla.entradas, 0);
      expect(find.byType(PantallaClipCompleta), findsNothing);
    });

    testWidgets('sin ninguna de las dos, abre la vista ampliada', (
      tester,
    ) async {
      pantalla.disponible = false;
      await abrir(tester);
      await tocarEtiqueta(tester, 'Ver el clip en pantalla completa');
      expect(clips.ultimo.pantallasNativas, 1);
      expect(pantalla.entradas, 0);
      expect(find.byType(PantallaClipCompleta), findsOneWidget);
    });

    testWidgets('Android e iOS: en horizontal y con barras ocultas, y al '
        'salir se restauran', (tester) async {
      final llamadas = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (llamada) async {
          llamadas.add(llamada);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      const modo = PantallaCompletaSistema();
      expect(modo.disponible, isTrue);
      modo.entrar();
      await tester.pump();
      expect(llamadas, [
        isMethodCall(
          'SystemChrome.setPreferredOrientations',
          arguments: [
            'DeviceOrientation.landscapeLeft',
            'DeviceOrientation.landscapeRight',
          ],
        ),
        isMethodCall(
          'SystemChrome.setEnabledSystemUIMode',
          arguments: 'SystemUiMode.immersiveSticky',
        ),
      ]);
      llamadas.clear();
      modo.salir();
      await tester.pump();
      expect(llamadas, [
        isMethodCall(
          'SystemChrome.setPreferredOrientations',
          arguments: <String>[],
        ),
        isMethodCall(
          'SystemChrome.setEnabledSystemUIMode',
          arguments: 'SystemUiMode.edgeToEdge',
        ),
      ]);
    });
  });
}
