import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/cache/cache_local.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/reloj.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/pcs/data/pcs_repositorio.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';
import 'package:te_tengo/features/pcs/presentation/escaner_qr.dart';
import 'package:te_tengo/features/pcs/presentation/pantalla_escanear.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../camaras/repositorio_falso.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'escaner_falso.dart';
import 'pcs_falso.dart';

const _qrDeLaPc = 'https://app.tetengo.reqsai.tech/vincular?codigo=KQWT-MXHD';

void main() {
  late PcsRepositorioFalso pcs;
  late EscanerFalso escaner;
  late CacheMemoria cache;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion sesion = sesionTitular,
    bool consentimiento = true,
  }) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesion,
        cache: cache,
        overrides: [
          pcsRepositorioProvider.overrideWithValue(pcs),
          fabricaEscanerQrProvider.overrideWithValue(() => escaner),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          hogarRepositorioProvider.overrideWithValue(
            HogarRepositorioFalso(hogarDeRosa(consentimiento: consentimiento)),
          ),
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

  Finder campoCodigo() => find.byType(TextField);

  /// Scrolls the visible list back up until [finder] is built.
  Future<void> verArriba(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isNotEmpty) return;
    await tester.scrollUntilVisible(
      finder,
      -200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    pcs = PcsRepositorioFalso(pcs: []);
    escaner = EscanerFalso();
    cache = CacheMemoria();
  });

  group('el código de la PC', () {
    test(
      'acepta minúsculas, con o sin guion, y solo las letras del código',
      () {
        expect(limpiarCodigo('kqwt-mxhd'), 'KQWTMXHD');
        expect(limpiarCodigo('KQWTMXHD'), 'KQWTMXHD');
        expect(limpiarCodigo('kqa1wt'), 'KQWT');
        expect(limpiarCodigo('KQWTMXHDBC'), 'KQWTMXHD');
        expect(formatoCodigo('KQWTMX'), 'KQWT-MX');
        expect(tieneLetrasAjenas('kqa'), isTrue);
        expect(tieneLetrasAjenas('KQW-T'), isFalse);
        expect(codigoValido('kqwtmxhd'), 'KQWT-MXHD');
        expect(codigoValido('KQWT-MXH'), isNull);
        expect(codigoValido('KQWT-MXHA'), isNull);
      },
    );

    test('lee el código del QR de la PC, y no de otros QR', () {
      expect(codigoDeQr(_qrDeLaPc), 'KQWT-MXHD');
      expect(
        codigoDeQr(
          'https://staging.te-tengo-app.pages.dev/vincular?codigo=kqwtmxhd',
        ),
        'KQWT-MXHD',
      );
      expect(codigoDeQr('https://example.com/menu'), isNull);
      expect(codigoDeQr('Hola'), isNull);
      expect(codigoDeQr('https://app.tetengo.reqsai.tech/vincular'), isNull);
    });
  });

  group('Vincula la PC de la casa', () {
    testWidgets(
      'CA-28.1: explica cómo instalar Te Tengo Captura y abre el escáner',
      (tester) async {
        await abrir(tester, Rutas.vincular);
        expect(find.text('Agregar PC'), findsOneWidget);
        expect(find.text('Vincula la PC de la casa'), findsOneWidget);
        expect(find.text('Instala Te Tengo Captura en la PC'), findsOneWidget);
        await tocar(tester, find.text('Escanear el código QR'));
        expect(
          find.text(
            'Para escanear el código, Te Tengo necesita usar la cámara de este celular.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('CA-28.5: el familiar invitado no puede agregar una PC', (
      tester,
    ) async {
      await abrir(tester, Rutas.vincular, sesion: sesionInvitado);
      expect(
        find.text('Solo Carmen (titular) puede agregar una PC.'),
        findsOneWidget,
      );
      await tocar(tester, find.text('Escanear el código QR'));
      expect(find.text('Vincula la PC de la casa'), findsOneWidget);
    });
  });

  group('Escanear el código QR', () {
    testWidgets('CA-28.1: explica la cámara antes del permiso; una vez', (
      tester,
    ) async {
      await abrir(tester, Rutas.escanear);
      expect(find.text('No guardamos ninguna imagen.'), findsOneWidget);
      expect(escaner.abierto, isFalse);
      await tocar(tester, find.text('Permitir'));
      expect(escaner.abierto, isTrue);
      expect(
        find.text('Apunta al código QR que muestra la PC'),
        findsOneWidget,
      );
      expect(cache.datos[claveCamaraExplicada], isNotNull);
    });

    testWidgets('lee el QR de la PC y abre la aprobación con sus datos', (
      tester,
    ) async {
      cache.datos[claveCamaraExplicada] = 'si';
      await abrir(tester, Rutas.escanear);
      escaner.leer(_qrDeLaPc);
      await tester.pumpAndSettle();
      expect(pcs.consultas, ['KQWT-MXHD']);
      expect(
        find.text('¿Vinculamos esta PC a la casa de Rosa?'),
        findsOneWidget,
      );
      expect(find.text('Windows 11 Home'), findsOneWidget);
      expect(find.text('Te Tengo Captura 0.5.0'), findsOneWidget);
    });

    testWidgets('un QR que no es de Te Tengo Captura no se usa', (
      tester,
    ) async {
      cache.datos[claveCamaraExplicada] = 'si';
      await abrir(tester, Rutas.escanear);
      escaner.leer('https://example.com/menu');
      await tester.pump();
      expect(find.text('Ese código no es de Te Tengo Captura'), findsOneWidget);
      expect(pcs.consultas, isEmpty);
      await tester.pump(const Duration(seconds: 7));
      expect(find.text('Ese código no es de Te Tengo Captura'), findsNothing);
    });

    testWidgets('CA-28.2: con la cámara bloqueada ofrece escribir el código', (
      tester,
    ) async {
      cache.datos[claveCamaraExplicada] = 'si';
      await abrir(tester, Rutas.escanear);
      escaner.fallar(FalloEscaner.permisoDenegado);
      await tester.pumpAndSettle();
      expect(
        find.text('La cámara del celular está bloqueada para Te Tengo'),
        findsOneWidget,
      );
      expect(find.text('Abrir los ajustes del celular'), findsOneWidget);
      await tocar(tester, find.text('Escribir el código').first);
      expect(find.text('Escribe el código de la PC'), findsOneWidget);
    });

    testWidgets('CA-28.3: un QR vencido pide escanear el nuevo', (
      tester,
    ) async {
      cache.datos[claveCamaraExplicada] = 'si';
      pcs.errorConsulta = const ProblemaApi(
        codigo: 'CODIGO_VENCIDO',
        detalle: 'Vencido',
      );
      await abrir(tester, Rutas.escanear);
      escaner.leer(_qrDeLaPc);
      await tester.pumpAndSettle();
      expect(find.text('Este código ya venció o ya se usó'), findsOneWidget);
      expect(
        find.text('La PC ya muestra uno nuevo: escríbelo o escanéalo.'),
        findsOneWidget,
      );
    });

    testWidgets('la linterna se enciende desde el visor', (tester) async {
      cache.datos[claveCamaraExplicada] = 'si';
      await abrir(tester, Rutas.escanear);
      await tester.tap(find.bySemanticsLabel('Linterna'));
      await tester.pump();
      expect(escaner.linterna, 1);
    });
  });

  group('Escribir el código', () {
    testWidgets(
      'CA-28.2: acepta minúsculas y guion, e ignora vocales y números',
      (tester) async {
        await abrir(tester, Rutas.escribirCodigo);
        expect(find.text('Código de 8 letras'), findsOneWidget);
        await tester.enterText(campoCodigo(), 'kqa1');
        await tester.pump();
        expect(
          find.text('El código solo lleva consonantes, sin números'),
          findsOneWidget,
        );
        expect(find.text('K'), findsOneWidget);
        expect(find.text('Q'), findsOneWidget);
        await tester.enterText(campoCodigo(), 'kqwt-mxhd');
        await tester.pump();
        await tocar(tester, find.text('Continuar'));
        expect(pcs.consultas, ['KQWT-MXHD']);
        expect(find.text('Aprobar la PC'), findsOneWidget);
        expect(find.text('KQWT-MXHD'), findsOneWidget);
      },
    );

    testWidgets('Continuar espera las 8 letras', (tester) async {
      await abrir(tester, Rutas.escribirCodigo);
      await tester.enterText(campoCodigo(), 'KQWT');
      await tester.pump();
      await tocar(tester, find.text('Continuar'));
      expect(pcs.consultas, isEmpty);
    });

    testWidgets('CA-28.6: un código incorrecto se marca', (tester) async {
      pcs.errorConsulta = const ProblemaApi(
        codigo: 'CODIGO_INCORRECTO',
        detalle: 'No existe',
        extras: {'intentosRestantes': 3},
      );
      await abrir(tester, Rutas.escribirCodigo);
      await tester.enterText(campoCodigo(), 'KQWTMXHB');
      await tocar(tester, find.text('Continuar'));
      expect(
        find.text('Ese código no existe. Revísalo letra por letra.'),
        findsOneWidget,
      );
    });

    testWidgets('CA-28.3: un código vencido o usado pide el nuevo', (
      tester,
    ) async {
      pcs.errorConsulta = const ProblemaApi(
        codigo: 'CODIGO_VENCIDO',
        detalle: 'Vencido',
      );
      await abrir(tester, Rutas.escribirCodigo);
      await tester.enterText(campoCodigo(), 'KQWTMXHD');
      await tocar(tester, find.text('Continuar'));
      expect(
        find.text(
          'Este código ya venció o ya se usó. La PC ya muestra uno nuevo: '
          'escríbelo o escanéalo.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('CA-28.6: 5 códigos incorrectos bloquean hasta la hora', (
      tester,
    ) async {
      pcs.errorConsulta = const ProblemaApi(
        codigo: 'VINCULACION_BLOQUEADA',
        detalle: 'Bloqueada',
        extras: {'bloqueadaHasta': '2026-09-23T15:57:00Z'},
      );
      await abrir(tester, Rutas.escribirCodigo);
      await tester.enterText(campoCodigo(), 'KQWTMXHB');
      await tocar(tester, find.text('Continuar'));
      expect(find.text('Demasiados intentos'), findsOneWidget);
      final hasta = DateTime.parse('2026-09-23T15:57:00Z').toLocal();
      final hh =
          '${hasta.hour.toString().padLeft(2, '0')}:'
          '${hasta.minute.toString().padLeft(2, '0')}';
      expect(
        find.textContaining(
          'Podrás volver a intentarlo a las $hh',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Escanear el código QR'), findsNothing);
      final campo = tester.widget<TextField>(campoCodigo());
      expect(campo.enabled, isFalse);
    });

    testWidgets('sin internet lo dice en el campo', (tester) async {
      pcs.errorConsulta = const ProblemaApi(
        codigo: ProblemaApi.sinConexion,
        detalle: 'Sin conexión',
      );
      await abrir(tester, Rutas.escribirCodigo);
      await tester.enterText(campoCodigo(), 'KQWTMXHD');
      await tocar(tester, find.text('Continuar'));
      expect(
        find.text('Sin internet. Revisa tu conexión y vuelve a intentarlo.'),
        findsOneWidget,
      );
    });
  });

  group('Aprobar la PC', () {
    testWidgets('CA-28.4: el enlace del QR muestra la PC antes de aprobarla', (
      tester,
    ) async {
      await abrir(tester, Rutas.aprobarPc('kqwtmxhd'));
      expect(pcs.consultas, ['KQWT-MXHD']);
      expect(find.text('Sala-Rosa'), findsOneWidget);
      expect(find.text('Windows 11 Home'), findsOneWidget);
      expect(find.text('Te Tengo Captura 0.5.0'), findsOneWidget);
      expect(
        find.text(
          'Usar sus cámaras para detectar caídas y movimientos inestables',
        ),
        findsOneWidget,
      );
      await verHasta(tester, find.text('No reconozco esta PC'));
      expect(find.text('No reconozco esta PC'), findsOneWidget);
    });

    testWidgets('CA-28.1: aprobar vincula la PC y lleva a elegir sus cámaras', (
      tester,
    ) async {
      await abrir(tester, Rutas.aprobarPc('KQWT-MXHD'));
      await tocar(tester, find.text('Aprobar'));
      expect(pcs.aprobaciones, ['KQWT-MXHD']);
      expect(find.text('La PC Sala-Rosa está vinculada'), findsOneWidget);
      expect(
        find.textContaining('Falta elegir las cámaras', findRichText: true),
        findsWidgets,
      );
      expect(find.text('Elegir las cámaras'), findsOneWidget);
    });

    testWidgets(
      'CA-28.1: sin consentimiento, la PC queda vinculada sin enviar video',
      (tester) async {
        await abrir(
          tester,
          Rutas.aprobarPc('KQWT-MXHD'),
          consentimiento: false,
        );
        await tocar(tester, find.text('Aprobar'));
        expect(find.text('Falta el consentimiento de Rosa'), findsOneWidget);
        expect(
          find.text(
            'Las cámaras no enviarán nada hasta que registres el consentimiento.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('CA-28.4: «No reconozco esta PC» no la vincula', (
      tester,
    ) async {
      await abrir(tester, Rutas.aprobarPc('KQWT-MXHD'));
      await tocar(tester, find.text('No reconozco esta PC'));
      expect(pcs.rechazos, ['KQWT-MXHD']);
      expect(pcs.aprobaciones, isEmpty);
      expect(find.text('No vinculamos la PC'), findsOneWidget);
      await tocar(tester, find.text('Entendido'));
      expect(find.text('No vinculamos la PC'), findsNothing);
      expect(find.text('Aprobar la PC'), findsNothing);
    });

    testWidgets('CA-28.3: el código venció mientras decidía', (tester) async {
      cache.datos[claveCamaraExplicada] = 'si';
      pcs.errorAprobacion = const ProblemaApi(
        codigo: 'CODIGO_VENCIDO',
        detalle: 'Vencido',
      );
      await abrir(tester, Rutas.aprobarPc('KQWT-MXHD'));
      await tocar(tester, find.text('Aprobar'));
      expect(
        find.text('Apunta al código QR que muestra la PC'),
        findsOneWidget,
      );
      expect(find.text('Este código ya venció o ya se usó'), findsOneWidget);
    });

    testWidgets('sin internet al aprobar lo dice y deja reintentar', (
      tester,
    ) async {
      pcs.errorAprobacion = const ProblemaApi(
        codigo: ProblemaApi.sinConexion,
        detalle: 'Sin conexión',
      );
      await abrir(tester, Rutas.aprobarPc('KQWT-MXHD'));
      await tocar(tester, find.text('Aprobar'));
      await verArriba(tester, find.text('No pudimos vincular la PC'));
      expect(find.text('No pudimos vincular la PC'), findsOneWidget);
      await verHasta(tester, find.text('Aprobar'));
      expect(find.text('Aprobar'), findsOneWidget);
    });

    testWidgets('CA-28.5: el familiar invitado no ve «Aprobar»', (
      tester,
    ) async {
      await abrir(tester, Rutas.aprobarPc('KQWT-MXHD'), sesion: sesionInvitado);
      expect(pcs.consultas, isEmpty);
      await verHasta(
        tester,
        find.textContaining('Solo Carmen (titular) puede vincular una PC.'),
      );
      expect(find.text('Aprobar'), findsNothing);
      expect(find.text('No reconozco esta PC'), findsNothing);
      expect(
        find.text(
          'Solo Carmen (titular) puede vincular una PC. Pídele que escanee el '
          'código.',
        ),
        findsOneWidget,
      );
      expect(find.text('KQWT-MXHD'), findsOneWidget);
    });

    testWidgets('CA-28.3: un enlace con un código vencido ofrece el nuevo', (
      tester,
    ) async {
      pcs.errorConsulta = const ProblemaApi(
        codigo: 'CODIGO_VENCIDO',
        detalle: 'Vencido',
      );
      await abrir(tester, Rutas.aprobarPc('KQWT-MXHD'));
      expect(find.text('Este código ya venció o ya se usó'), findsOneWidget);
      expect(find.text('Escanear el código QR'), findsOneWidget);
      expect(find.text('Escribir el código'), findsOneWidget);
    });
  });

  group('Paso 3 de la configuración', () {
    testWidgets('sin PC, pide vincularla y permite hacerlo después', (
      tester,
    ) async {
      await abrir(tester, Rutas.configCamara);
      expect(find.text('Paso 3 de 5'), findsOneWidget);
      expect(find.text('Vincula la PC de la casa'), findsOneWidget);
      await verHasta(
        tester,
        find.text('Sin una PC vinculada no detectamos caídas.'),
      );
      await tocar(tester, find.text('Hacerlo después'));
      expect(find.text('Paso 4 de 5'), findsOneWidget);
    });

    testWidgets('aprobar dentro del paso vuelve al paso con la PC vinculada', (
      tester,
    ) async {
      await abrir(tester, Rutas.configCamara);
      await tocar(tester, find.text('Escribir el código'));
      await tester.enterText(campoCodigo(), 'KQWTMXHD');
      await tocar(tester, find.text('Continuar'));
      await tocar(tester, find.text('Aprobar'));
      expect(find.text('Paso 3 de 5'), findsOneWidget);
      expect(find.text('La PC Sala-Rosa está vinculada'), findsOneWidget);
      await tocar(tester, find.text('Hacerlo después'));
      expect(find.text('Paso 4 de 5'), findsOneWidget);
    });

    testWidgets('con las cámaras elegidas, continúa al paso 4', (tester) async {
      pcs = PcsRepositorioFalso();
      await abrir(tester, Rutas.configCamara);
      expect(find.text('Sus cámaras ya están elegidas.'), findsOneWidget);
      expect(find.text('Sala'), findsOneWidget);
      await tocar(tester, find.text('Continuar'));
      expect(find.text('Paso 4 de 5'), findsOneWidget);
    });
  });

  test('sin sesión, el enlace del QR pide entrar primero', () {
    expect(Rutas.redirigir(null, Rutas.vincular), Rutas.bienvenida);
  });

  test('las rutas de la vinculación se arman con el código', () {
    expect(Rutas.aprobarPc('KQWT-MXHD'), '/vincular?codigo=KQWT-MXHD');
    expect(
      Rutas.aprobarPc('KQWT-MXHD', config: true),
      '/vincular?codigo=KQWT-MXHD&config=1',
    );
    expect(
      Rutas.elegirCamaras('pc-1', config: true),
      '/pcs/pc-1/camaras?config=1',
    );
  });

  testWidgets('la configuración guarda que ya se explicó la cámara', (
    tester,
  ) async {
    await abrir(tester, Rutas.escanear);
    await tocar(tester, find.text('Permitir'));
    final contenedor = ProviderScope.containerOf(
      tester.element(find.byType(PantallaEscanear)),
    );
    expect(
      await contenedor.read(cacheLocalProvider).leer(claveCamaraExplicada),
      'si',
    );
  });
}
