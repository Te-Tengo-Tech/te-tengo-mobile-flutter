import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/notificaciones/mensaje_push.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/push_falso.dart';
import '../alertas/alertas_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'repositorio_falso.dart';

void main() {
  late CamarasRepositorioFalso camaras;
  late NotificacionesPushFalsas push;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    DateTime? ahora,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        push: push,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(camaras),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(
            () => ahora ?? DateTime(2026, 9, 23, 10, 42, 6),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  final pausada = Camara(
    id: 'c1',
    nombreHabitacion: 'Sala',
    estado: EstadoConexion.enLinea,
    ultimaSenal: DateTime(2026, 9, 23, 10, 42),
    pausadaHasta: DateTime(2026, 9, 23, 11, 42),
  );

  setUp(() {
    camaras = CamarasRepositorioFalso();
    push = NotificacionesPushFalsas();
  });

  testWidgets('CA-22.1: pausa la cámara eligiendo la duración', (tester) async {
    await abrir(tester, Rutas.camara('c1'));
    expect(
      find.text('Útil si hay visitas en esta habitación.'),
      findsOneWidget,
    );
    await tocar(tester, find.text('Pausar esta cámara'));
    expect(find.text('Pausar la cámara de la Sala'), findsOneWidget);
    expect(
      find.text('Sin detección ni vista en vivo. Se reactiva sola.'),
      findsOneWidget,
    );
    for (final (t, s) in [
      ('30 minutos', 'hasta las 11:12'),
      ('1 hora', 'hasta las 11:42'),
      ('2 horas', 'hasta las 12:42'),
      ('Hasta mañana', 'a las 07:00'),
    ]) {
      expect(find.text(t), findsOneWidget);
      expect(find.text(s), findsOneWidget);
    }
    await tester.tap(find.text('Pausar'));
    await tester.pumpAndSettle();
    expect(camaras.pausas, [DuracionPausa.hora1]);
    expect(find.text('Cámara de la Sala en pausa'), findsOneWidget);
    expect(find.text('Se reactivará sola a las 11:42.'), findsOneWidget);
    // CA-22.2: the detail shows it is paused and until when.
    expect(find.text('En pausa hasta las 11:42'), findsOneWidget);
    expect(find.text('Detenida'), findsOneWidget);
  });

  testWidgets('«Hasta mañana» se reactiva a las 07:00 de mañana', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Pausar esta cámara'));
    await tester.tap(find.text('Hasta mañana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pausar'));
    await tester.pumpAndSettle();
    expect(camaras.pausas, [DuracionPausa.hastaManana]);
    expect(
      find.text('Se reactivará sola a las 07:00 de mañana.'),
      findsOneWidget,
    );
    expect(find.text('En pausa hasta las 07:00 de mañana'), findsOneWidget);
  });

  testWidgets('un familiar invitado también puede pausarla', (tester) async {
    await abrir(tester, Rutas.camara('c1'), sesion: sesionInvitado);
    await tocar(tester, find.text('Pausar esta cámara'));
    await tester.tap(find.text('30 minutos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pausar'));
    await tester.pumpAndSettle();
    expect(camaras.pausas, [DuracionPausa.min30]);
  });

  testWidgets('un error al pausar se muestra en la hoja', (tester) async {
    camaras.errorPausa = const ProblemaApi(
      codigo: 'DURACION_INVALIDA',
      detalle: 'Elige una duración válida.',
      estado: 422,
    );
    await abrir(tester, Rutas.camara('c1'));
    await tocar(tester, find.text('Pausar esta cámara'));
    await tester.tap(find.text('Pausar'));
    await tester.pumpAndSettle();
    expect(find.text('Elige una duración válida.'), findsOneWidget);
    expect(find.text('Pausar la cámara de la Sala'), findsOneWidget);
  });

  testWidgets('CA-22.2: el inicio muestra la pausa y hasta cuándo', (
    tester,
  ) async {
    camaras.camaras = [pausada];
    await abrir(tester, Rutas.inicio);
    expect(find.text('Todo tranquilo, con una pausa'), findsOneWidget);
    expect(
      find.text('La cámara de la Sala está en pausa hasta las 11:42.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('En pausa · hasta las 11:42', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('reanudar ahora reactiva la cámara', (tester) async {
    camaras.camaras = [pausada];
    await abrir(tester, Rutas.camara('c1'));
    expect(find.text('En pausa hasta las 11:42'), findsOneWidget);
    expect(
      find.text(
        'Sin detección ni vista en vivo. Se reactiva sola y te avisaremos.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Reanudar ahora'));
    expect(camaras.reanudaciones, 1);
    expect(find.text('Cámara de la Sala reactivada'), findsOneWidget);
    expect(
      find.text('La detección y la vista en vivo vuelven a estar disponibles.'),
      findsOneWidget,
    );
    expect(find.text('Pausar esta cámara'), findsOneWidget);
    expect(find.text('Activa'), findsOneWidget);
  });

  testWidgets('CA-22.3: al terminar la pausa llega el aviso de reactivación', (
    tester,
  ) async {
    camaras.camaras = [pausada];
    await abrir(tester, Rutas.inicio, ahora: DateTime(2026, 9, 23, 11, 42));
    expect(find.text('Todo tranquilo, con una pausa'), findsOneWidget);
    camaras.camaras = [camaraSala];
    push.recibir(
      MensajePush(
        tipo: TipoPush.pausaFinalizada,
        camaraId: 'c1',
        habitacion: 'Sala',
        ocurridaEn: DateTime(2026, 9, 23, 11, 42),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('La cámara de la Sala se reactivó'), findsOneWidget);
    expect(find.text('Terminó la pausa a las 11:42.'), findsOneWidget);
    expect(find.text('Todo tranquilo'), findsOneWidget);
  });

  test('POST y DELETE /api/camaras/{id}/pausa', () async {
    const json = {
      'id': 'c1',
      'nombreHabitacion': 'Sala',
      'estadoConexion': 'EN_LINEA',
      'ultimaSenal': '2026-09-23T15:42:00Z',
      'pausadaHasta': '2026-09-23T16:42:00Z',
      'deteccionConfiable': true,
    };
    final http = AdaptadorFalso()
      ..cuando('POST', '/api/camaras/c1/pausa', const Respuesta(200, json))
      ..cuando(
        'DELETE',
        '/api/camaras/c1/pausa',
        Respuesta(200, Map<String, Object?>.of(json)..['pausadaHasta'] = null),
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
    final repo = c.read(camarasRepositorioProvider);
    expect(
      (await repo.pausar('c1', DuracionPausa.hastaManana)).pausadaHasta,
      DateTime.utc(2026, 9, 23, 16, 42).toLocal(),
    );
    expect(http.peticiones.first.data, {'duracion': 'HASTA_MANANA'});
    expect((await repo.reanudar('c1')).enPausa, isFalse);
    expect(http.peticiones.last.method, 'DELETE');
  });
}
