import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/clip_falso.dart';
import '../../apoyo/datos.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

void main() {
  testWidgets('CA-18.1: la alerta muestra el clip de 6 s antes y 6 s después', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso([caidaSala()]);
    final clips = FabricaClipFalsa();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
      clips: clips,
    );
    // A fall folds its clip behind «Clip del evento».
    expect(find.text('12 s, antes y después'), findsOneWidget);
    await tocar(tester, find.text('Clip del evento'));
    await verHasta(tester, find.text('0:00 / 0:12'));
    expect(find.text('Sala · 10:42'), findsOneWidget);
    expect(alertas.clips, ['a-1']);
    expect(
      find.text('Con la postura detectada · 6 s antes y 6 s después.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Ver el clip en pantalla completa'),
      findsOneWidget,
    );
    await tocar(tester, find.bySemanticsLabel('Reproducir clip'));
    clips.ultimo.avanzar(const Duration(seconds: 8));
    await tester.pump();
    expect(find.text('0:08 / 0:12'), findsOneWidget);
    expect(find.bySemanticsLabel('Pausar clip'), findsOneWidget);
  });

  testWidgets(
    'CA-18.2: sin video la alerta se muestra e informa que no está disponible',
    (tester) async {
      await abrirConAlertas(
        tester,
        ubicacion: Rutas.alerta('a-1'),
        alertas: AlertasRepositorioFalso([
          caidaSala(clip: EstadoClip.noDisponible),
        ]),
      );
      expect(find.text('Rosa pudo haberse caído'), findsOneWidget);
      expect(find.text('No se pudo guardar'), findsOneWidget);
      await tocar(tester, find.text('Clip del evento'));
      await verHasta(tester, find.text('Clip no disponible'));
      expect(
        find.text(
          'No se pudo guardar el video. La alerta sigue siendo válida.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('CA-18.2: un 404 CLIP_NO_DISPONIBLE también se informa así', (
    tester,
  ) async {
    final alertas = AlertasRepositorioFalso([caidaSala()])
      ..errorClip = const ProblemaApi(
        codigo: 'CLIP_NO_DISPONIBLE',
        detalle: 'No.',
        estado: 404,
      );
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.alerta('a-1'),
      alertas: alertas,
    );
    await tocar(tester, find.text('Clip del evento'));
    await verHasta(tester, find.text('Clip no disponible'));
    expect(find.text('Clip no disponible'), findsOneWidget);
  });

  test('GET /api/alertas/{id}/clip y su descarga', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'GET',
        '/api/alertas/a-1/clip',
        const Respuesta(200, {
          'url': 'https://s3.example/clip.mp4?firma',
          'expiraEn': '2026-09-23T16:00:00Z',
        }),
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
    final repo = c.read(alertasRepositorioProvider);
    final enlace = await repo.clip('a-1');
    expect(enlace.url, 'https://s3.example/clip.mp4?firma');
    expect(http.peticiones.single.queryParameters, isEmpty);
    await repo.clip('a-1', descarga: true);
    expect(http.peticiones.last.queryParameters, {'descarga': true});
  });
}
