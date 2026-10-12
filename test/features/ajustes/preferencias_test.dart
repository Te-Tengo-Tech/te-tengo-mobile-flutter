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
import 'package:te_tengo/app/tema/paleta.dart';
import 'package:te_tengo/features/ajustes/data/apariencia.dart';
import 'package:te_tengo/features/ajustes/data/contraste.dart';
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

  group('almacén del contraste', () {
    test('sin nada guardado está apagado', () async {
      expect(await AlmacenContrasteLocal(CacheMemoria()).cargar(), isFalse);
    });

    test('guarda y lee las dos opciones; cerrar sesión no lo borra', () async {
      final cache = CacheDrift(NativeDatabase.memory());
      addTearDown(cache.cerrar);
      await AlmacenContrasteLocal(cache).guardar(true);
      expect(await AlmacenContrasteLocal(cache).cargar(), isTrue);
      await cache.vaciar();
      expect(await AlmacenContrasteLocal(cache).cargar(), isTrue);
      await AlmacenContrasteLocal(cache).guardar(false);
      expect(await AlmacenContrasteLocal(cache).cargar(), isFalse);
    });

    test('un localStorage bloqueado lo deja apagado', () async {
      final cache = CacheEnAlmacen(_AlmacenMapa()..bloqueado = true);
      await AlmacenContrasteLocal(cache).guardar(true);
      expect(await AlmacenContrasteLocal(cache).cargar(), isFalse);
    });

    test('al arrancar no espera a una base que no responde', () async {
      expect(
        await cargarContraste(
          _CacheColgada(),
          espera: const Duration(milliseconds: 10),
        ),
        isFalse,
      );
    });
  });

  group('Ajustes › Preferencias', () {
    Future<void> abrir(
      WidgetTester tester, {
      required CacheLocal cache,
      Sesion sesion = sesionTitular,
      Apariencia inicial = Apariencia.automatica,
      bool contraste = false,
    }) async {
      usarTelefono(tester);
      await tester.pumpWidget(
        appDePrueba(
          ubicacion: Rutas.ajustes,
          sesion: sesion,
          cache: cache,
          overrides: [
            aparienciaInicialProvider.overrideWithValue(inicial),
            contrasteInicialProvider.overrideWithValue(contraste),
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
        Theme.of(tester.element(find.text('Preferencias').first)).brightness;

    Paleta paleta(WidgetTester tester) =>
        tester.element(find.text('Preferencias').first).colores;

    testWidgets('por defecto sigue el tema del celular', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await abrir(tester, cache: CacheMemoria());
      await verHasta(tester, find.text('Preferencias'));
      expect(find.text('Tema automático'), findsOneWidget);
      expect(modo(tester), ThemeMode.system);
      expect(brillo(tester), Brightness.dark);
    });

    testWidgets('el tema ofrece tres opciones como radio, con 48 dp y '
        'lectores de pantalla', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, cache: CacheMemoria());
      await tocar(tester, find.text('Preferencias'));
      expect(find.byType(OpcionRadio<Apariencia>), findsNWidgets(3));
      expect(find.text('Igual que tu celular'), findsOneWidget);
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Automático. Igual que tu celular'),
        ),
        isSemantics(
          label: 'Automático. Igual que tu celular',
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
      await tocar(tester, find.text('Preferencias'));
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();
      expect(modo(tester), ThemeMode.dark);
      expect(brillo(tester), Brightness.dark);
      expect(cache.datos[AlmacenAparienciaLocal.clave], 'oscura');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await verHasta(tester, find.text('Tema oscuro'));
      expect(find.text('Tema oscuro'), findsOneWidget);
    });

    testWidgets('«Claro» se mantiene aunque el celular esté en oscuro', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await abrir(tester, cache: CacheMemoria());
      await tocar(tester, find.text('Preferencias'));
      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();
      expect(modo(tester), ThemeMode.light);
      expect(brillo(tester), Brightness.light);
    });

    testWidgets('sobrevive a reiniciar la app', (tester) async {
      final cache = CacheMemoria();
      await abrir(tester, cache: cache);
      await tocar(tester, find.text('Preferencias'));
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aumentar el contraste'));
      await tester.pumpAndSettle();

      // A new launch: main() reads both before the first frame.
      await tester.pumpWidget(const SizedBox.shrink());
      final leida = await cargarApariencia(cache);
      final contraste = await cargarContraste(cache);
      expect(leida, Apariencia.oscura);
      expect(contraste, isTrue);
      await abrir(tester, cache: cache, inicial: leida, contraste: contraste);
      expect(modo(tester), ThemeMode.dark);
      expect(brillo(tester), Brightness.dark);
      expect(paleta(tester).contraste, isTrue);
      await verHasta(tester, find.text('Tema oscuro · más contraste'));
      expect(find.text('Tema oscuro · más contraste'), findsOneWidget);
    });

    testWidgets('«Aumentar el contraste» marca texto y bordes, en claro y en '
        'oscuro, y lo guarda en este celular', (tester) async {
      final semantica = tester.ensureSemantics();
      final cache = CacheMemoria();
      await abrir(tester, cache: cache);
      await tocar(tester, find.text('Preferencias'));
      expect(find.text('Texto y bordes más marcados'), findsOneWidget);
      expect(find.text('Las alertas conservan su color.'), findsOneWidget);
      expect(paleta(tester).contraste, isFalse);
      expect(
        tester.getSemantics(find.byType(Switch)),
        isSemantics(
          label: 'Aumentar el contraste\nTexto y bordes más marcados',
          hasToggledState: true,
          isToggled: false,
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(cache.datos[AlmacenContrasteLocal.clave], 'si');
      final clara = paleta(tester);
      expect(clara.contraste, isTrue);
      expect(clara.tinta, Paleta.claraContraste.tinta);
      expect(clara.anchoBorde, 2);
      expect(
        tester.getSemantics(find.byType(Switch)),
        isSemantics(isToggled: true),
      );

      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();
      final oscura = paleta(tester);
      expect(oscura.oscura && oscura.contraste, isTrue);
      expect(oscura.tinta, const Color(0xFFFFFFFF));

      // The whole row toggles it, not only the switch.
      await tester.tap(find.text('Aumentar el contraste'));
      await tester.pumpAndSettle();
      expect(paleta(tester).contraste, isFalse);
      expect(cache.datos[AlmacenContrasteLocal.clave], 'no');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      semantica.dispose();
    });

    testWidgets('el ajuste de contraste del celular también lo activa', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures.allOn;
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await abrir(tester, cache: CacheMemoria());
      expect(paleta(tester).contraste, isTrue);
    });

    testWidgets('cerrar sesión no cambia ni borra las preferencias', (
      tester,
    ) async {
      final cache = CacheMemoria();
      await abrir(
        tester,
        cache: cache,
        inicial: Apariencia.oscura,
        contraste: true,
      );
      await cache.guardar(AlmacenAparienciaLocal.clave, 'oscura');
      await cache.guardar(AlmacenContrasteLocal.clave, 'si');
      await cache.guardar('h1|/api/camaras?', '[]');
      final contenedor = ProviderScope.containerOf(
        tester.element(find.byType(TeTengoApp)),
      );
      await contenedor.read(sesionControllerProvider.notifier).cerrar();
      await tester.pumpAndSettle();
      expect(contenedor.read(sesionControllerProvider), isNull);
      expect(cache.datos.containsKey('h1|/api/camaras?'), isFalse);
      expect(cache.datos[AlmacenAparienciaLocal.clave], 'oscura');
      expect(cache.datos[AlmacenContrasteLocal.clave], 'si');
      expect(modo(tester), ThemeMode.dark);
      expect(contenedor.read(contrasteProvider), isTrue);
    });

    testWidgets('el familiar invitado también las cambia (son del celular)', (
      tester,
    ) async {
      await abrir(tester, cache: CacheMemoria(), sesion: sesionInvitado);
      await tocar(tester, find.text('Preferencias'));
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();
      expect(modo(tester), ThemeMode.dark);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(paleta(tester).contraste, isTrue);
    });

    testWidgets('con el texto al 200 % no se desborda', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await abrir(tester, cache: CacheMemoria(), contraste: true);
      await tocar(tester, find.text('Preferencias'));
      expect(tester.takeException(), isNull);
      expect(find.text('Igual que tu celular'), findsOneWidget);
      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();
      expect(modo(tester), ThemeMode.light);
      await verHasta(tester, find.text('Aumentar el contraste'));
      expect(tester.takeException(), isNull);
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
