import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/dispositivo/conectividad.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/ui/avisos_flotantes.dart';
import 'package:te_tengo/features/actualizaciones/data/actualizacion_controller.dart';
import 'package:te_tengo/features/actualizaciones/data/interrupcion.dart';
import 'package:te_tengo/features/actualizaciones/data/plataforma.dart';
import 'package:te_tengo/features/actualizaciones/domain/estado_actualizacion.dart';
import 'package:te_tengo/features/actualizaciones/domain/versiones.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/alertas/domain/alerta.dart';

import '../../apoyo/dispositivo_falso.dart';
import '../alertas/alertas_falso.dart';
import 'actualizaciones_falso.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late VersionesFalsas versiones;
  late InstaladorFalso instalador;
  late PlayFalso play;
  late AdaptadorDescarga descarga;
  late Directory carpeta;
  late ConectividadFalsa conectividad;
  late CacheMemoria cache;
  late List<Uri> enlaces;
  late List<int> recargas;
  Alerta? alertaActiva;

  setUp(() {
    versiones = VersionesFalsas(versionesEn('0.6.0'));
    instalador = InstaladorFalso();
    play = PlayFalso();
    descarga = AdaptadorDescarga();
    carpeta = Directory.systemTemp.createTempSync('tt-actualizaciones');
    addTearDown(() async {
      // alAbrir() may be deleting it too.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      try {
        if (carpeta.existsSync()) carpeta.deleteSync(recursive: true);
      } on FileSystemException {
        // Already gone.
      }
    });
    conectividad = ConectividadFalsa();
    cache = CacheMemoria();
    enlaces = [];
    recargas = [];
    alertaActiva = null;
  });

  ProviderContainer contenedor({InfoApp? info = infoApk}) {
    final c = ProviderContainer(
      overrides: [
        ...overridesActualizacion(
          info: info,
          versiones: versiones,
          instalador: instalador,
          play: play,
          descarga: descarga,
          carpeta: carpeta,
          enlaces: enlaces,
          recargas: recargas,
        ),
        conectividadProvider.overrideWithValue(conectividad),
        cacheLocalProvider.overrideWithValue(cache),
        alertaActivaProvider.overrideWith((ref) async => alertaActiva),
        relojProvider.overrideWithValue(() => DateTime(2026, 10, 11, 10, 42)),
      ],
    );
    addTearDown(c.dispose);
    // The active alert is read synchronously.
    c.listen(alertaActivaProvider, (_, _) {});
    return c;
  }

  Future<ProviderContainer> conVersionNueva({InfoApp? info = infoApk}) async {
    final c = contenedor(info: info);
    await c.read(alertaActivaProvider.future);
    await c.read(actualizacionProvider.notifier).buscar(MotivoBusqueda.abrir);
    return c;
  }

  EstadoActualizacion estado(ProviderContainer c) =>
      c.read(actualizacionProvider);

  group('buscar', () {
    test('encuentra la versión nueva del canal (CA-43.5)', () async {
      final c = await conVersionNueva();
      expect(estado(c).nueva!.version, '0.6.0');
      expect(estado(c).obligatoria, isFalse);
      expect(estado(c).revisadoEn, DateTime(2026, 10, 11, 10, 42));
    });

    test('al día, sin versión nueva', () async {
      versiones.respuesta = versionesEn('0.5.0');
      final c = await conVersionNueva();
      expect(estado(c).nueva, isNull);
    });

    test('debajo de versionMinima es obligatoria (CA-43.8)', () async {
      versiones.respuesta = versionesEn('0.6.0', minima: '0.5.1');
      final c = await conVersionNueva();
      expect(estado(c).obligatoria, isTrue);
    });

    test('sin saber la versión de la app no pregunta nada', () async {
      final c = contenedor(info: null);
      await c.read(actualizacionProvider.notifier).buscar(MotivoBusqueda.abrir);
      expect(versiones.lecturas, 0);
      expect(estado(c).nueva, isNull);
    });

    test('un backend anterior (404) no muestra nada', () async {
      versiones.respuesta = null;
      final c = await conVersionNueva();
      expect(estado(c).nueva, isNull);
      expect(estado(c).error, isNull);
    });

    test('al volver de segundo plano espera 5 minutos', () async {
      final c = await conVersionNueva();
      await c
          .read(actualizacionProvider.notifier)
          .buscar(MotivoBusqueda.reanudar);
      expect(versiones.lecturas, 1);
      await c
          .read(actualizacionProvider.notifier)
          .buscar(MotivoBusqueda.diaria);
      expect(versiones.lecturas, 2);
    });

    test(
      '«Buscar actualizaciones» sin internet: «No pudimos buscar.»',
      () async {
        final c = contenedor();
        conectividad.hay = false;
        await c
            .read(actualizacionProvider.notifier)
            .buscar(MotivoBusqueda.manual);
        expect(estado(c).error, ErrorActualizacion.sinInternetAlBuscar);
        expect(versiones.lecturas, 0);
        conectividad.hay = true;
        versiones.error = const ProblemaApi(
          codigo: ProblemaApi.sinConexion,
          detalle: '',
        );
        await c
            .read(actualizacionProvider.notifier)
            .buscar(MotivoBusqueda.manual);
        expect(estado(c).error, ErrorActualizacion.sinInternetAlBuscar);
        expect(estado(c).fase, FaseActualizacion.quieta);
        versiones.error = null;
        await c
            .read(actualizacionProvider.notifier)
            .buscar(MotivoBusqueda.manual);
        expect(estado(c).error, isNull);
      },
    );

    test('una búsqueda automática sin conexión no muestra errores', () async {
      versiones.error = const ProblemaApi(
        codigo: ProblemaApi.sinConexion,
        detalle: '',
      );
      final c = await conVersionNueva();
      expect(estado(c).error, isNull);
    });
  });

  group('APK (CA-43.5)', () {
    test('descarga, comprueba el SHA-256 y abre el instalador', () async {
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(
        descarga.pedidos.single.uri.toString(),
        'https://tetengo.example/te-tengo.apk',
      );
      expect(
        descarga.pedidos.single.headers.containsKey('Authorization'),
        isFalse,
      );
      final ruta = instalador.instalados.single;
      expect(ruta, '${carpeta.path}/te-tengo-0.6.0.apk');
      expect(File(ruta).readAsBytesSync(), bytesApk);
      expect(estado(c).fase, FaseActualizacion.quieta);
      expect(estado(c).error, isNull);
      expect(await cache.leer(claveActualizacionPedida), '0.5.0');
    });

    test('si la suma no coincide borra el archivo y no instala', () async {
      versiones.respuesta = versionesEn('0.6.0', shaApk: 'f' * 64);
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(instalador.instalados, isEmpty);
      expect(estado(c).error, ErrorActualizacion.verificacion);
      expect(File('${carpeta.path}/te-tengo-0.6.0.apk').existsSync(), isFalse);
      expect(estado(c).apkVerificado, isNull);
    });

    test('un error del servidor: «No se pudo descargar»', () async {
      descarga.estado = 500;
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(estado(c).error, ErrorActualizacion.descarga);
      expect(instalador.instalados, isEmpty);
      expect(File('${carpeta.path}/te-tengo-0.6.0.apk').existsSync(), isFalse);
    });

    test('sin conexión: «Sin internet»', () async {
      final c = await conVersionNueva();
      conectividad.hay = false;
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(estado(c).error, ErrorActualizacion.sinInternet);
      expect(descarga.pedidos, isEmpty);
      conectividad.hay = true;
      descarga.sinConexion = true;
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(estado(c).error, ErrorActualizacion.sinInternet);
    });

    test('«Cancelar» detiene la descarga y deja el aviso', () async {
      descarga.colgada = true;
      final c = await conVersionNueva();
      final enCurso = c.read(actualizacionProvider.notifier).actualizar();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(estado(c).fase, FaseActualizacion.descargando);
      c.read(actualizacionProvider.notifier).cancelarDescarga();
      await enCurso;
      expect(estado(c).fase, FaseActualizacion.quieta);
      expect(estado(c).error, isNull);
      expect(estado(c).nueva, isNotNull);
      expect(instalador.instalados, isEmpty);
    });

    test('sin SHA-256 publicado no instala nada', () async {
      versiones.respuesta = versionesEn('0.6.0', shaApk: '');
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(descarga.pedidos, isEmpty);
      expect(estado(c).error, ErrorActualizacion.descarga);
    });

    test('sin el permiso de Android pide explicarlo primero', () async {
      instalador.permiso = false;
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(estado(c).pedirPermiso, isTrue);
      expect(instalador.instalados, isEmpty);
      expect(estado(c).apkVerificado, isNotNull);
      final controller = c.read(actualizacionProvider.notifier)
        ..permisoMostrado();
      // «Ahora no».
      controller.permisoAhoraNo();
      expect(estado(c).error, ErrorActualizacion.sinPermiso);
      // «Actualizar» again with the permission: no new download.
      instalador.permiso = true;
      await controller.actualizar();
      expect(descarga.pedidos, hasLength(1));
      expect(instalador.instalados, hasLength(1));
    });

    test('con el permiso dado no se explica', () async {
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(estado(c).pedirPermiso, isFalse);
    });

    test(
      'al volver de los ajustes con el permiso abre el instalador',
      () async {
        instalador.permiso = false;
        final c = await conVersionNueva();
        final controller = c.read(actualizacionProvider.notifier);
        await controller.actualizar();
        expect(await controller.alVolverDeAjustes(), isFalse);
        instalador.permiso = true;
        expect(await controller.alVolverDeAjustes(), isTrue);
        expect(instalador.instalados, hasLength(1));
      },
    );

    test('instalador cancelado: «Actualizar» reusa el archivo', () async {
      instalador.resultado = ResultadoInstalador.cancelada;
      final c = await conVersionNueva();
      final controller = c.read(actualizacionProvider.notifier);
      await controller.actualizar();
      expect(estado(c).error, ErrorActualizacion.cancelada);
      instalador.resultado = ResultadoInstalador.instalada;
      await controller.actualizar();
      expect(descarga.pedidos, hasLength(1));
      expect(instalador.instalados, hasLength(2));
      expect(estado(c).error, isNull);
    });

    test('el instalador falla: «No se instaló»', () async {
      instalador.resultado = ResultadoInstalador.fallo;
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(estado(c).error, ErrorActualizacion.instalacion);
    });
  });

  group('sin interrumpir (CA-43.9)', () {
    test('con una alerta activa «Actualizar» no hace nada', () async {
      alertaActiva = caidaSala();
      final c = await conVersionNueva();
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(descarga.pedidos, isEmpty);
    });

    test('el instalador espera a que se cierre la vista en vivo', () async {
      final c = await conVersionNueva();
      final controller = c.read(actualizacionProvider.notifier);
      descarga.colgada = false;
      final enCurso = controller.actualizar();
      // The family opens the live view while it downloads.
      c.read(rutaActualProvider.notifier).cambiar('/vivo');
      await enCurso;
      expect(estado(c).fase, FaseActualizacion.esperando);
      expect(instalador.instalados, isEmpty);
      c.read(rutaActualProvider.notifier).cambiar('/inicio');
      await controller.continuar();
      expect(instalador.instalados, hasLength(1));
    });

    test('rutas protegidas', () {
      expect(esRutaProtegida('/alerta/a-1'), isTrue);
      expect(esRutaProtegida('/alertas/h1'), isTrue);
      expect(esRutaProtegida('/vivo'), isTrue);
      expect(esRutaProtegida(Rutas.verTodas), isTrue);
      expect(esRutaProtegida('/inicio'), isFalse);
      expect(esRutaProtegida('/ajustes/acerca-de'), isFalse);
    });
  });

  group('otros canales', () {
    test('PWA: «Actualizando…» y recarga (CA-43.4)', () async {
      final c = await conVersionNueva(info: infoPwa);
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(recargas, [1]);
      expect(estado(c).fase, FaseActualizacion.recargando);
    });

    test('iPhone: abre TestFlight, sin descargar (CA-43.6)', () async {
      final c = await conVersionNueva(info: infoIos);
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(enlaces.single.host, 'testflight.apple.com');
      expect(descarga.pedidos, isEmpty);
    });

    test('Google Play: el flujo flexible; si Play no puede, nada', () async {
      final c = await conVersionNueva(info: infoPlay);
      await c.read(actualizacionProvider.notifier).actualizar();
      expect(play.flexibles, 1);
      expect(estado(c).fase, FaseActualizacion.quieta);
      expect(estado(c).error, isNull);
      expect(enlaces, isEmpty);
    });

    test(
      'Google Play obligatoria: inmediata, o la página de la tienda',
      () async {
        versiones.respuesta = versionesEn('0.6.0', minima: '0.6.0');
        final c = await conVersionNueva(info: infoPlay);
        await c.read(actualizacionProvider.notifier).actualizar();
        expect(play.inmediatas, 1);
        expect(enlaces.single.host, 'play.google.com');
      },
    );

    test('Google Play sin el plugin (no vino de Play) no falla', () async {
      const real = ActualizacionPlayEnApp();
      expect(await real.flexible(), isFalse);
      expect(await real.inmediata(), isFalse);
    });
  });

  group('al abrir', () {
    test('«Te Tengo se actualizó · Versión 0.6.0.»', () async {
      await cache.guardar(claveActualizacionPedida, '0.5.0');
      final c = contenedor(
        info: const InfoApp(version: '0.6.0', canal: Canal.apk),
      );
      await c.read(actualizacionProvider.notifier).alAbrir();
      final aviso = c.read(avisoFlotanteProvider);
      expect(aviso!.titulo, 'Te Tengo se actualizó');
      expect(aviso.texto, 'Versión 0.6.0.');
      expect(await cache.leer(claveActualizacionPedida), '');
    });

    test('sin actualización no dice nada', () async {
      await cache.guardar(claveActualizacionPedida, '0.5.0');
      final c = contenedor();
      await c.read(actualizacionProvider.notifier).alAbrir();
      expect(c.read(avisoFlotanteProvider), isNull);
    });

    test('borra las descargas anteriores', () async {
      File('${carpeta.path}/te-tengo-0.4.0.apk').writeAsStringSync('x');
      final c = contenedor();
      await c.read(actualizacionProvider.notifier).alAbrir();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(carpeta.existsSync(), isFalse);
    });
  });
}
