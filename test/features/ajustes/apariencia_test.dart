import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/app.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/core/sesion/sesion_controller.dart';
import 'package:te_tengo/core/sesion/sesion_repositorio.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/ajustes/data/apariencia.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import '../vivo/vivo_falso.dart';

void main() {
  group('almacén de la apariencia', () {
    test('sin nada guardado es automática', () async {
      expect(
        await AlmacenAparienciaLocal(CacheMemoria()).cargar(),
        Apariencia.automatica,
      );
    });

    test('guarda y lee cada opción', () async {
      final cache = CacheMemoria();
      final almacen = AlmacenAparienciaLocal(cache);
      for (final a in Apariencia.values) {
        await almacen.guardar(a);
        expect(await AlmacenAparienciaLocal(cache).cargar(), a);
      }
    });

    test('un valor desconocido vuelve a automática', () async {
      final cache = CacheMemoria();
      await cache.guardar(AlmacenAparienciaLocal.clave, 'sepia');
      expect(
        await AlmacenAparienciaLocal(cache).cargar(),
        Apariencia.automatica,
      );
    });

    test('cerrar sesión no la borra (SQLite de Android e iOS)', () async {
      final cache = CacheDrift(NativeDatabase.memory());
      addTearDown(cache.cerrar);
      await AlmacenAparienciaLocal(cache).guardar(Apariencia.oscura);
      await cache.guardar('h1|/api/camaras?', '[]');
      await cache.vaciar();
      expect(await cache.leer('h1|/api/camaras?'), isNull);
      expect(await AlmacenAparienciaLocal(cache).cargar(), Apariencia.oscura);
    });

    test('cerrar sesión no la borra (localStorage del navegador)', () async {
      final almacen = _AlmacenMapa();
      final cache = CacheEnAlmacen(almacen);
      await AlmacenAparienciaLocal(cache).guardar(Apariencia.clara);
      expect(almacen.datos['tt_cache|dispositivo|apariencia'], 'clara');
      await cache.vaciar();
      expect(await AlmacenAparienciaLocal(cache).cargar(), Apariencia.clara);
    });

    test('un localStorage bloqueado da automática', () async {
      final cache = CacheEnAlmacen(_AlmacenMapa()..bloqueado = true);
      await AlmacenAparienciaLocal(cache).guardar(Apariencia.oscura);
      expect(
        await AlmacenAparienciaLocal(cache).cargar(),
        Apariencia.automatica,
      );
    });

    test('al arrancar no espera a una base que no responde', () async {
      final apariencia = await cargarApariencia(
        _CacheColgada(),
        espera: const Duration(milliseconds: 10),
      );
      expect(apariencia, Apariencia.automatica);
    });
  });

  group('controlador', () {
    test('parte de lo leído al arrancar y guarda lo elegido', () async {
      final almacen = AlmacenAparienciaMemoria();
      final contenedor = ProviderContainer(
        overrides: [
          aparienciaInicialProvider.overrideWithValue(Apariencia.oscura),
          almacenAparienciaProvider.overrideWithValue(almacen),
        ],
      );
      addTearDown(contenedor.dispose);
      expect(contenedor.read(aparienciaProvider), Apariencia.oscura);
      await contenedor
          .read(aparienciaProvider.notifier)
          .elegir(Apariencia.clara);
      expect(contenedor.read(aparienciaProvider), Apariencia.clara);
      expect(almacen.actual, Apariencia.clara);
    });

    test('si no se puede guardar, igual se aplica', () async {
      final contenedor = ProviderContainer(
        overrides: [
          almacenAparienciaProvider.overrideWithValue(_AlmacenQueFalla()),
        ],
      );
      addTearDown(contenedor.dispose);
      await contenedor
          .read(aparienciaProvider.notifier)
          .elegir(Apariencia.oscura);
      expect(contenedor.read(aparienciaProvider), Apariencia.oscura);
    });
  });

  group('Ajustes › Apariencia', () {
    Future<void> abrir(
      WidgetTester tester, {
      required CacheLocal cache,
      Sesion sesion = sesionTitular,
      Apariencia inicial = Apariencia.automatica,
    }) async {
      usarTelefono(tester);
      await tester.pumpWidget(
        appDePrueba(
          ubicacion: Rutas.ajustes,
          sesion: sesion,
          cache: cache,
          overrides: [
            aparienciaInicialProvider.overrideWithValue(inicial),
            sesionRepositorioProvider.overrideWithValue(_SesionesFalsas()),
            hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
            camarasRepositorioProvider.overrideWithValue(
              CamarasRepositorioFalso(),
            ),
            familiaRepositorioProvider.overrideWithValue(
              FamiliaRepositorioFalso(),
            ),
            alertasRepositorioProvider.overrideWithValue(
              AlertasRepositorioFalso([
                caidaSala(estado: EstadoAlerta.atendida),
              ]),
            ),
            vistaEnVivoRepositorioProvider.overrideWithValue(
              VistaEnVivoRepositorioFalso(),
            ),
            relojProvider.overrideWithValue(
              () => DateTime(2026, 9, 23, 10, 42, 6),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    ThemeMode modo(WidgetTester tester) =>
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

    Brightness brillo(WidgetTester tester) =>
        Theme.of(tester.element(find.text('Apariencia').first)).brightness;

    testWidgets('por defecto sigue el tema del celular', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await abrir(tester, cache: CacheMemoria());
      await verHasta(tester, find.text('Apariencia'));
      expect(find.text('Automático'), findsOneWidget);
      expect(modo(tester), ThemeMode.system);
      expect(brillo(tester), Brightness.dark);
    });

    testWidgets('ofrece tres opciones como radio, con 48 dp y lectores de '
        'pantalla', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, cache: CacheMemoria());
      await tocar(tester, find.text('Apariencia'));
      expect(find.byType(OpcionRadio<Apariencia>), findsNWidgets(3));
      expect(find.text('Sigue el tema del celular'), findsOneWidget);
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Automático. Sigue el tema del celular'),
        ),
        isSemantics(
          label: 'Automático. Sigue el tema del celular',
          isButton: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Oscuro')),
        isSemantics(
          label: 'Oscuro',
          isButton: true,
          isChecked: false,
          isInMutuallyExclusiveGroup: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantica.dispose();
    });

    testWidgets('elegir «Oscuro» cambia la app y lo guarda en este celular', (
      tester,
    ) async {
      final cache = CacheMemoria();
      await abrir(tester, cache: cache);
      await tocar(tester, find.text('Apariencia'));
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();
      expect(find.byType(OpcionRadio<Apariencia>), findsNothing);
      expect(modo(tester), ThemeMode.dark);
      expect(brillo(tester), Brightness.dark);
      expect(find.text('Oscuro'), findsOneWidget);
      expect(cache.datos[AlmacenAparienciaLocal.clave], 'oscura');
    });

    testWidgets('«Claro» se mantiene aunque el celular esté en oscuro', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await abrir(tester, cache: CacheMemoria());
      await tocar(tester, find.text('Apariencia'));
      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();
      expect(modo(tester), ThemeMode.light);
      expect(brillo(tester), Brightness.light);
    });

    testWidgets('sobrevive a reiniciar la app', (tester) async {
      final cache = CacheMemoria();
      await abrir(tester, cache: cache);
      await tocar(tester, find.text('Apariencia'));
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();

      // A new launch: main() reads the appearance before the first frame.
      await tester.pumpWidget(const SizedBox.shrink());
      final leida = await cargarApariencia(cache);
      expect(leida, Apariencia.oscura);
      await abrir(tester, cache: cache, inicial: leida);
      expect(modo(tester), ThemeMode.dark);
      expect(brillo(tester), Brightness.dark);
      await verHasta(tester, find.text('Apariencia'));
      expect(find.text('Oscuro'), findsOneWidget);
    });

    testWidgets('cerrar sesión no la cambia ni la borra', (tester) async {
      final cache = CacheMemoria();
      await abrir(tester, cache: cache, inicial: Apariencia.oscura);
      await cache.guardar(AlmacenAparienciaLocal.clave, 'oscura');
      await cache.guardar('h1|/api/camaras?', '[]');
      final contenedor = ProviderScope.containerOf(
        tester.element(find.byType(TeTengoApp)),
      );
      await contenedor.read(sesionControllerProvider.notifier).cerrar();
      await tester.pumpAndSettle();
      expect(contenedor.read(sesionControllerProvider), isNull);
      expect(cache.datos.containsKey('h1|/api/camaras?'), isFalse);
      expect(cache.datos[AlmacenAparienciaLocal.clave], 'oscura');
      expect(modo(tester), ThemeMode.dark);
    });

    testWidgets('el familiar invitado también la cambia (es del celular)', (
      tester,
    ) async {
      await abrir(tester, cache: CacheMemoria(), sesion: sesionInvitado);
      await tocar(tester, find.text('Apariencia'));
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();
      expect(modo(tester), ThemeMode.dark);
    });

    testWidgets('con el texto al 200 % la hoja no se desborda', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await abrir(tester, cache: CacheMemoria());
      await tocar(tester, find.text('Apariencia'));
      expect(tester.takeException(), isNull);
      expect(find.text('Sigue el tema del celular'), findsOneWidget);
      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();
      expect(modo(tester), ThemeMode.light);
    });
  });
}

class _AlmacenMapa implements AlmacenTexto {
  final datos = <String, String>{};
  bool bloqueado = false;

  void _revisar() {
    if (bloqueado) throw StateError('SecurityError');
  }

  @override
  String? leer(String clave) {
    _revisar();
    return datos[clave];
  }

  @override
  void escribir(String clave, String valor) {
    _revisar();
    datos[clave] = valor;
  }

  @override
  void borrar(String clave) => datos.remove(clave);

  @override
  Iterable<String> get claves => datos.keys;
}

class _CacheColgada implements CacheLocal {
  @override
  Future<String?> leer(String clave) => Completer<String?>().future;

  @override
  Future<void> guardar(String clave, String valor) async {}

  @override
  Future<void> vaciar() async {}
}

class _AlmacenQueFalla implements AlmacenApariencia {
  @override
  Future<Apariencia> cargar() async => Apariencia.automatica;

  @override
  Future<void> guardar(Apariencia apariencia) =>
      Future.error(StateError('disco lleno'));
}

class _SesionesFalsas implements SesionRepositorio {
  @override
  Future<void> cerrar(String tokenAcceso) async {}

  @override
  Future<Sesion> cambiarHogar(String hogarId) => throw UnimplementedError();

  @override
  Future<List<HogarResumen>> hogares() async => [];
}
