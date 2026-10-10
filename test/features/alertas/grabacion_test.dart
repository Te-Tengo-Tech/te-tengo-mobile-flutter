import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/ui/iconos.dart';
import 'package:te_tengo/features/alertas/data/descarga_grabacion.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/alertas/presentation/pantalla_detalle_alerta.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/clip_falso.dart';
import 'alertas_falso.dart';
import 'apoyo_alertas.dart';

void main() {
  late List<(Uri, String)> guardados;

  final pasada = caidaSala(
    id: 'h1',
    tipo: TipoAlerta.movimientoInestable,
    estado: EstadoAlerta.atendida,
    atendidaPor: 'Carmen Huamán',
    atendidaPorId: 'u-carmen',
    atendidaEn: DateTime(2026, 9, 21, 12, 9),
    ocurridaEn: DateTime(2026, 9, 21, 12, 5),
  );

  Future<AlertasRepositorioFalso> abrir(
    WidgetTester tester,
    List<Alerta> lista, {
    String? ubicacion,
    FabricaClipFalsa? clips,
  }) async {
    final alertas = AlertasRepositorioFalso(lista);
    await abrirConAlertas(
      tester,
      ubicacion: ubicacion ?? Rutas.historial,
      alertas: alertas,
      clips: clips,
      ahora: DateTime(2026, 9, 23, 10, 42),
      overrides: [
        guardarArchivoProvider.overrideWithValue((url, nombre) async {
          guardados.add((url, nombre));
          return nombre;
        }),
      ],
    );
    return alertas;
  }

  setUp(() => guardados = []);

  testWidgets('CA-26.1: desde el historial reproduce la grabación', (
    tester,
  ) async {
    final clips = FabricaClipFalsa();
    final alertas = await abrir(tester, [pasada], clips: clips);
    await tocar(tester, find.text('Movimiento inestable'));
    expect(find.byType(PantallaDetalleAlerta), findsOneWidget);
    expect(find.text('Alerta del lun 21 sep'), findsOneWidget);
    await verHasta(tester, find.text('0:00 / 0:12'));
    expect(alertas.clips, ['h1']);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is Icono && w.etiqueta == 'Reproducir clip',
      ),
    );
    await tester.pumpAndSettle();
    clips.ultimo.avanzar(const Duration(seconds: 8));
    await tester.pump();
    expect(find.text('0:08 / 0:12'), findsOneWidget);
  });

  testWidgets('CA-26.2: descarga la grabación como archivo', (tester) async {
    final alertas = await abrir(tester, [
      pasada,
    ], ubicacion: Rutas.detalleAlerta('h1'));
    await verHasta(tester, find.text('Descargar grabación'));
    expect(
      find.text('MP4 · 12 s · disponible hasta el 21 oct 2026'),
      findsOneWidget,
    );
    await tocar(tester, find.text('Descargar grabación'));
    expect(alertas.descargas, ['h1']);
    expect(
      guardados.single.$1.toString(),
      'https://clips.tetengo.pe/h1.mp4?descarga',
    );
    expect(guardados.single.$2, 'alerta-21-sep-1205.mp4');
    expect(find.text('Grabación descargada'), findsOneWidget);
    expect(find.text('alerta-21-sep-1205.mp4 en Archivos'), findsOneWidget);
  });

  testWidgets('CA-26.3: la grabación eliminada por retención lo informa', (
    tester,
  ) async {
    await abrir(tester, [
      caidaSala(
        id: 'h7',
        estado: EstadoAlerta.atendida,
        clip: EstadoClip.eliminado,
        ocurridaEn: DateTime(2026, 8, 11, 9, 30),
      ),
    ], ubicacion: Rutas.detalleAlerta('h7'));
    expect(find.text('Alerta del mar 11 ago'), findsOneWidget);
    await verHasta(tester, find.text('La grabación ya no está disponible'));
    expect(
      find.text(
        'Se eliminó el 10 sep 2026 por la política de retención de 30 días. '
        'El registro de la alerta se conserva.',
      ),
      findsOneWidget,
    );
    expect(find.text('Descargar grabación'), findsNothing);
  });

  testWidgets('CA-26.3: si se elimina al descargar, se avisa', (tester) async {
    final alertas = await abrir(tester, [
      pasada,
    ], ubicacion: Rutas.detalleAlerta('h1'));
    await verHasta(tester, find.text('Descargar grabación'));
    alertas.errorClip = const ProblemaApi(
      codigo: 'CLIP_ELIMINADO',
      detalle: 'La grabación ya no está disponible.',
      estado: 410,
    );
    await tocar(tester, find.text('Descargar grabación'));
    expect(find.text('La grabación ya no está disponible.'), findsOneWidget);
    expect(guardados, isEmpty);
  });

  test('nombre del archivo descargado', () {
    expect(nombreGrabacion(pasada), 'alerta-21-sep-1205.mp4');
  });
}
