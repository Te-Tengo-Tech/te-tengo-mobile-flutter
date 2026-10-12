import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/actividad/data/actividad_repositorio.dart';
import 'package:te_tengo/features/actividad/domain/actividad.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/pantalla_accesos.dart';
import 'package:te_tengo/features/camaras/presentation/pantalla_camara.dart';
import 'package:te_tengo/features/repeticion/data/repeticiones_repositorio.dart';
import 'package:te_tengo/features/repeticion/domain/repeticion.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../actividad/actividad_falso.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../repeticion/repeticiones_falso.dart';
import 'vivo_falso.dart';

void main() {
  late VistaEnVivoRepositorioFalso vivo;
  late RepeticionesRepositorioFalso repeticiones;
  late ActividadRepositorioFalso actividadFalsa;

  Future<void> abrir(WidgetTester tester, String ubicacion) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesionTitular,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso(),
          ),
          vistaEnVivoRepositorioProvider.overrideWithValue(vivo),
          repeticionesRepositorioProvider.overrideWithValue(repeticiones),
          actividadRepositorioProvider.overrideWithValue(actividadFalsa),
          fabricaReproductorVivoProvider.overrideWithValue(
            FabricaReproductorFalsa().crear,
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 44)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  final registrados = [
    AccesoVivo(
      usuarioId: 'u-carmen',
      nombre: 'Carmen Huamán',
      inicio: DateTime(2026, 9, 23, 10, 42),
      duracionSegundos: 72,
    ),
    AccesoVivo(
      usuarioId: 'u-luis',
      nombre: 'Luis Huamán',
      inicio: DateTime(2026, 9, 23, 8, 15),
      duracionSegundos: 125,
    ),
    AccesoVivo(
      usuarioId: 'u-carmen',
      nombre: 'Carmen Huamán',
      inicio: DateTime(2026, 9, 22, 21, 40),
      duracionSegundos: 48,
    ),
    AccesoVivo(
      usuarioId: 'u-carmen',
      nombre: 'Carmen Huamán',
      inicio: DateTime(2026, 9, 21, 12, 6),
      duracionSegundos: 94,
      desdeAlerta: true,
    ),
  ];

  setUp(() {
    vivo = VistaEnVivoRepositorioFalso();
    repeticiones = RepeticionesRepositorioFalso();
    actividadFalsa = ActividadRepositorioFalso([]);
  });

  testWidgets('CA-39.3: una repetición vista en la PC está en el registro', (
    tester,
  ) async {
    actividadFalsa.lista = [
      actividad(
        'ac-r',
        'REPETICION_VISTA',
        DateTime(2026, 9, 23, 9, 30),
        actor: TipoActor.pc,
        pcId: 'pc-sala',
        pc: 'Sala-Rosa',
        camaraId: 'c1',
        objeto: 'Sala',
        antes:
            '${DateTime(2026, 9, 22, 7, 54).toUtc().toIso8601String()}/'
            '${DateTime(2026, 9, 22, 8, 4).toUtc().toIso8601String()}',
        despues: '95',
      ),
      // Other types are not accesses.
      actividad(
        'ac-m',
        'MODO_AVANZADO_ACTIVADO',
        DateTime(2026, 9, 23, 9, 0),
        actor: TipoActor.pc,
        pc: 'Sala-Rosa',
      ),
    ];
    await abrir(tester, Rutas.accesos);
    expect(find.text('Repetición · Sala, 22/09 07:54'), findsOneWidget);
    expect(
      find.text(
        'PC Sala-Rosa · 09:30 · 1\u00a0min 35\u00a0s',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Repeticiones'));
    expect(find.text('Repetición · Sala, 22/09 07:54'), findsOneWidget);
  });

  testWidgets('una API sin repeticiones en la PC muestra el resto', (
    tester,
  ) async {
    vivo.lista = [registrados.first];
    actividadFalsa.error = const ProblemaApi(
      codigo: 'VALIDACION',
      detalle: 'Tipo desconocido',
    );
    await abrir(tester, Rutas.accesos);
    expect(find.text('Vista en vivo · Sala'), findsOneWidget);
  });

  Future<void> abrirAjustes(WidgetTester tester) async {
    await tocar(tester, find.text('Ajustes de la cámara'));
    await verHasta(tester, find.text('Registro de accesos'));
  }

  testWidgets('CA-24.2: muestra los accesos del más reciente al más antiguo', (
    tester,
  ) async {
    vivo.lista = registrados;
    await abrir(tester, Rutas.camara('c1'));
    await abrirAjustes(tester);
    expect(find.text('Tú · hoy 10:42'), findsOneWidget);
    await tocar(tester, find.text('Registro de accesos'));
    expect(find.byType(PantallaAccesos), findsOneWidget);
    expect(
      find.text('Quién miró, cuándo y cuánto. Toda la familia lo ve.'),
      findsOneWidget,
    );
    expect(find.text('Hoy'), findsWidgets);
    expect(find.text('Ayer'), findsOneWidget);
    expect(find.text('Vista en vivo · Sala'), findsWidgets);
    expect(
      find.text(
        'Carmen (tú) · 10:42 · 1\u00a0min 12\u00a0s',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(
      find.text('Luis · 08:15 · 2\u00a0min 5\u00a0s', findRichText: true),
      findsOneWidget,
    );
    final arriba = tester
        .getTopLeft(
          find.text('Luis · 08:15 · 2\u00a0min 5\u00a0s', findRichText: true),
        )
        .dy;
    expect(tester.getTopLeft(find.text('Ayer')).dy, greaterThan(arriba));
    await verHasta(tester, find.text('Desde una alerta'));
    expect(find.text('lun 21 sep'), findsOneWidget);
  });

  testWidgets('CA-24.3: sin accesos lo indica', (tester) async {
    await abrir(tester, Rutas.accesos);
    expect(find.text('Aún no hay accesos registrados'), findsOneWidget);
    expect(find.text('Todo'), findsNothing);
    expect(
      find.text('Quién miró, cuándo y cuánto. Toda la familia lo ve.'),
      findsOneWidget,
    );
  });

  testWidgets('CA-24.1: al cerrar la vista en vivo el registro se actualiza', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await abrirAjustes(tester);
    expect(find.text('Sin accesos'), findsOneWidget);
    await tocar(tester, find.text('En vivo'));
    vivo.lista = [registrados.first];
    await tocar(tester, find.text('Cerrar la vista en vivo'));
    expect(vivo.cerradas, ['v-1']);
    expect(find.text('Acceso registrado'), findsOneWidget);
    await verHasta(tester, find.text('Tú · hoy 10:42'));
  });

  testWidgets('CA-39.3: las repeticiones y las vistas previas, con filtros', (
    tester,
  ) async {
    vivo.lista = [
      AccesoVivo(
        usuarioId: 'u-luis',
        nombre: 'Luis Huamán',
        inicio: DateTime(2026, 9, 23, 8, 15),
        duracionSegundos: 125,
        camaraId: 'c1',
      ),
      AccesoVivo(
        usuarioId: 'u-carmen',
        nombre: 'Carmen Huamán',
        inicio: DateTime(2026, 9, 22, 21, 40),
        duracionSegundos: 15,
        camaraId: 'c1',
        vistaPrevia: true,
      ),
    ];
    repeticiones.lista = [
      AccesoRepeticion(
        id: 'ar-1',
        usuarioId: 'u-carmen',
        nombre: 'Carmen Huamán',
        camaraId: 'c1',
        habitacion: 'Sala',
        momentoDesde: DateTime(2026, 9, 15, 7, 54),
        inicio: DateTime(2026, 9, 22, 21, 46),
        duracionSegundos: 130,
      ),
    ];
    await abrir(tester, Rutas.accesos);
    expect(find.text('Repetición · Sala, 15/09 07:54'), findsOneWidget);
    expect(
      find.text(
        'Carmen (tú) · 21:46 · 2\u00a0min 10\u00a0s',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('Abrir de nuevo'), findsOneWidget);
    expect(find.text('Vista previa al elegir cámaras'), findsOneWidget);
    await tocar(tester, find.text('Repeticiones'));
    expect(find.text('Vista en vivo · Sala'), findsNothing);
    expect(find.text('Repetición · Sala, 15/09 07:54'), findsOneWidget);
    await tocar(tester, find.text('Vista en vivo'));
    expect(find.text('Repetición · Sala, 15/09 07:54'), findsNothing);
    expect(find.text('Vista en vivo · Sala'), findsOneWidget);
    await tocar(tester, find.text('Todo'));
    await tocar(tester, find.text('Repetición · Sala, 15/09 07:54'));
    expect(find.byType(PantallaCamara), findsOneWidget);
    expect(
      tester.widget<PantallaCamara>(find.byType(PantallaCamara)).momento,
      DateTime(2026, 9, 15, 7, 54),
    );
  });

  test('GET /api/accesos-vista-en-vivo', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'GET',
        '/api/accesos-vista-en-vivo',
        const Respuesta(200, [
          {
            'usuario': {'id': 'u-luis', 'nombre': 'Luis Huamán'},
            'inicio': '2026-09-23T13:15:00Z',
            'duracionSegundos': 125,
            'desdeAlerta': true,
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
    final a = (await c.read(vistaEnVivoRepositorioProvider).accesos()).single;
    expect(a.nombre, 'Luis Huamán');
    expect(a.duracionSegundos, 125);
    expect(a.desdeAlerta, isTrue);
  });
}
