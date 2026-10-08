import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/pantalla_accesos.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'vivo_falso.dart';

void main() {
  late VistaEnVivoRepositorioFalso vivo;

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

  setUp(() => vivo = VistaEnVivoRepositorioFalso());

  testWidgets('CA-24.2: muestra los accesos del más reciente al más antiguo', (
    tester,
  ) async {
    vivo.lista = registrados;
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('Registro de accesos'));
    expect(
      find.text('Último: tú, hoy a las 10:42 · 1 min 12 s'),
      findsOneWidget,
    );
    await tocar(tester, find.text('Registro de accesos'));
    expect(find.byType(PantallaAccesos), findsOneWidget);
    expect(
      find.text(
        'Cada vez que alguien de la familia abre la vista en vivo de la Sala, '
        'queda registrado quién la vio, cuándo empezó y cuánto duró. Toda la '
        'familia ve este registro.',
      ),
      findsOneWidget,
    );
    expect(find.text('Hoy, miércoles 23 de septiembre'), findsOneWidget);
    expect(find.text('martes 22 de septiembre'), findsOneWidget);
    expect(find.text('Carmen Huamán (tú)'), findsWidgets);
    expect(find.text('Luis Huamán'), findsOneWidget);
    expect(
      find.textContaining(
        'Empezó a las 08:15 · duró 2 min 5 s',
        findRichText: true,
      ),
      findsOneWidget,
    );
    final arriba = tester.getTopLeft(find.text('Luis Huamán')).dy;
    expect(
      tester.getTopLeft(find.text('martes 22 de septiembre')).dy,
      greaterThan(arriba),
    );
    await verHasta(tester, find.text('Desde una alerta'));
    expect(find.text('lunes 21 de septiembre'), findsOneWidget);
  });

  testWidgets('CA-24.3: sin accesos lo indica', (tester) async {
    await abrir(tester, Rutas.accesos);
    expect(find.text('Aún no hay accesos registrados'), findsOneWidget);
    expect(
      find.text(
        'Cuando alguien de la familia abra la vista en vivo, aquí verás quién '
        'la vio, cuándo empezó y cuánto duró.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Rosa autorizó la vista en vivo en su consentimiento del 3 ago 2026.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CA-24.1: al cerrar la vista en vivo el registro se actualiza', (
    tester,
  ) async {
    await abrir(tester, Rutas.camara('c1'));
    await verHasta(tester, find.text('Aún no hay accesos registrados'));
    await tocar(tester, find.text('Ver en vivo'));
    vivo.lista = [registrados.first];
    await tocar(tester, find.text('Cerrar la vista en vivo'));
    expect(vivo.cerradas, ['v-1']);
    expect(find.text('Acceso registrado'), findsOneWidget);
    await verHasta(tester, find.text('Registro de accesos'));
    expect(
      find.text('Último: tú, hoy a las 10:42 · 1 min 12 s'),
      findsOneWidget,
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
