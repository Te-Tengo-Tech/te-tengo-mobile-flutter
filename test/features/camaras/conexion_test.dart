import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/camaras/presentation/avisos_camara.dart';
import 'package:te_tengo/features/camaras/presentation/pantalla_camara.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/inicio/presentation/pantalla_inicio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'repositorio_falso.dart';

void main() {
  late CamarasRepositorioFalso camaras;
  late HogarRepositorioFalso hogar;

  Future<void> abrir(WidgetTester tester, String ubicacion) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesionTitular,
        overrides: [
          camarasRepositorioProvider.overrideWithValue(camaras),
          hogarRepositorioProvider.overrideWithValue(hogar),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(
            () => DateTime(2026, 9, 23, 10, 42, 6),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer contenedor(WidgetTester tester, Type pantalla) =>
      ProviderScope.containerOf(tester.element(find.byType(pantalla)));

  final desconectada = Camara(
    id: 'c1',
    nombreHabitacion: 'Sala',
    estado: EstadoConexion.desconectada,
    ultimaSenal: DateTime(2026, 9, 23, 10, 31),
  );

  setUp(() {
    camaras = CamarasRepositorioFalso();
    hogar = HogarRepositorioFalso();
  });

  testWidgets(
    'CA-07.1: en línea muestra el estado con la hora de la última señal',
    (tester) async {
      await abrir(tester, Rutas.camara('c1'));
      expect(find.text('En línea'), findsOneWidget);
      expect(
        find.textContaining('10:42 · hace 6 s', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Activa'), findsOneWidget);
    },
  );

  testWidgets('CA-07.2: desconectada indica qué revisar', (tester) async {
    camaras.camaras = [desconectada];
    await abrir(tester, Rutas.camara('c1'));
    expect(find.text('Desconectada'), findsOneWidget);
    expect(
      find.textContaining('a las 10:31', findRichText: true),
      findsOneWidget,
    );
    // The header already says since when: no notice repeats it.
    expect(find.text('No recibimos señal desde las 10:31'), findsNothing);
    await verHasta(tester, find.text('La conexión a internet'));
    expect(find.text('Conectado al puerto USB de la PC'), findsOneWidget);
    expect(find.text('El cable de la cámara'), findsOneWidget);
    expect(find.text('La PC encendida'), findsOneWidget);
    expect(find.text('La conexión a internet'), findsOneWidget);
  });

  testWidgets('CA-07.2: el aviso de desconexión lleva al detalle de la cámara', (
    tester,
  ) async {
    await abrir(tester, Rutas.inicio);
    camaras.camaras = [desconectada];
    final c = contenedor(tester, PantallaInicio);
    var abierta = false;
    c
        .read(avisosCamaraProvider)
        .desconectada(habitacion: 'Sala', abrir: () => abierta = true);
    await tester.pumpAndSettle();
    expect(find.text('La cámara de la Sala se desconectó'), findsOneWidget);
    expect(
      find.text(
        'Revisa el cable de la cámara, que la PC esté encendida y el internet de la casa.',
      ),
      findsOneWidget,
    );
    expect(find.text('La cámara está desconectada'), findsOneWidget);
    await tester.tap(find.text('La cámara de la Sala se desconectó'));
    await tester.pumpAndSettle();
    expect(abierta, isTrue);
  });

  testWidgets(
    'CA-07.3: al reconectarse avisa que el monitoreo se restableció',
    (tester) async {
      camaras.camaras = [desconectada];
      await abrir(tester, Rutas.inicio);
      camaras.camaras = [camaraSala];
      contenedor(tester, PantallaInicio)
          .read(avisosCamaraProvider)
          .reconectada(
            habitacion: 'Sala',
            cuando: DateTime(2026, 9, 23, 10, 52),
          );
      await tester.pumpAndSettle();
      expect(
        find.text('La cámara de la Sala volvió a estar en línea'),
        findsOneWidget,
      );
      expect(
        find.text('El monitoreo se restableció a las 10:52.'),
        findsOneWidget,
      );
      expect(find.text('Todo tranquilo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(
        find.text('La cámara de la Sala volvió a estar en línea'),
        findsNothing,
      );
    },
  );

  testWidgets('sin consentimiento la cámara está detenida', (tester) async {
    hogar.hogar = hogarDeRosa(consentimiento: false);
    await abrir(tester, Rutas.camara('c1'));
    expect(find.text('Detenida'), findsWidgets);
    expect(find.text('Primero registra el consentimiento'), findsOneWidget);
    expect(find.byType(PantallaCamara), findsOneWidget);
  });
}
