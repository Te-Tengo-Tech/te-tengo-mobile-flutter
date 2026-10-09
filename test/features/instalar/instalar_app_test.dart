import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/web/entorno.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../../apoyo/dispositivo_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';

const _pestanaIphone = EntornoNavegador(esWeb: true, esIos: true);
const _titulo = 'Agrega Te Tengo a tu pantalla de inicio';

void main() {
  test('solo una pestaña del iPhone debe instalar la app', () {
    expect(_pestanaIphone.debeInstalar, isTrue);
    expect(
      const EntornoNavegador(
        esWeb: true,
        esIos: true,
        instalada: true,
      ).debeInstalar,
      isFalse,
    );
    expect(const EntornoNavegador(esWeb: true).debeInstalar, isFalse);
    expect(const EntornoNavegador().debeInstalar, isFalse);
  });

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    EntornoNavegador entorno = _pestanaIphone,
    bool conSesion = false,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: conSesion ? sesionTitular : null,
        permiso: PermisoFalso(activas: false),
        overrides: [
          entornoNavegadorProvider.overrideWithValue(entorno),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
          relojProvider.overrideWithValue(() => DateTime(2026, 9, 23, 10, 42)),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('en una pestaña del iPhone la bienvenida explica cómo instalar', (
    tester,
  ) async {
    await abrir(tester, Rutas.bienvenida);
    expect(find.text(_titulo), findsOneWidget);
    expect(
      find.text(
        'En el iPhone, las alertas solo llegan si abres Te Tengo desde su ícono.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Ver cómo'));
    expect(find.text('Agregar a la pantalla de inicio'), findsOneWidget);
    expect(find.text('Instala Te Tengo en tu iPhone'), findsOneWidget);
    expect(find.text('Toca Compartir'), findsOneWidget);
    expect(find.text('Elige «Agregar a inicio»'), findsOneWidget);
    expect(find.text('Abre Te Tengo desde su ícono'), findsOneWidget);
  });

  testWidgets('instalada o fuera del iPhone no muestra el aviso', (
    tester,
  ) async {
    await abrir(
      tester,
      Rutas.bienvenida,
      entorno: const EntornoNavegador(
        esWeb: true,
        esIos: true,
        instalada: true,
      ),
    );
    expect(find.text(_titulo), findsNothing);
  });

  testWidgets(
    'en Inicio reemplaza a «Activa las notificaciones», que no se pueden activar',
    (tester) async {
      await abrir(tester, Rutas.inicio, conSesion: true);
      expect(find.text(_titulo), findsOneWidget);
      expect(find.text('Activa las notificaciones'), findsNothing);
    },
  );

  testWidgets(
    'instalada en el iPhone, Inicio pide activar las notificaciones',
    (tester) async {
      await abrir(
        tester,
        Rutas.inicio,
        conSesion: true,
        entorno: const EntornoNavegador(
          esWeb: true,
          esIos: true,
          instalada: true,
        ),
      );
      expect(find.text(_titulo), findsNothing);
      expect(find.text('Activa las notificaciones'), findsOneWidget);
    },
  );
}
