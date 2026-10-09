import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/formato.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion_repositorio.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/arranque/pantalla_arranque.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/sesion/data/cuentas_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../hogar/hogar_falso.dart';
import 'cuentas_falso.dart';

Finder campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoTexto, etiqueta),
  matching: find.byType(TextField),
);

class _SesionRepoFalso implements SesionRepositorio {
  final cerradas = <String>[];

  @override
  Future<void> cerrar(String tokenAcceso) async => cerradas.add(tokenAcceso);

  @override
  Future<Sesion> cambiarHogar(String hogarId) => throw UnimplementedError();

  @override
  Future<List<HogarResumen>> hogares() async => [];
}

Future<void> entrar(WidgetTester tester, String correo, String clave) async {
  await tester.enterText(campo('Correo electrónico'), correo);
  await tester.enterText(campo('Contraseña'), clave);
  await tocar(tester, find.text('Iniciar sesión'));
}

void main() {
  late CuentasRepositorioFalso repo;

  Future<void> abrir(WidgetTester tester, {AlmacenSesion? almacen}) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: Rutas.iniciarSesion,
        almacen: almacen,
        overrides: [
          cuentasRepositorioProvider.overrideWithValue(repo),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => repo = CuentasRepositorioFalso(sesion: sesionTitular));

  testWidgets('CA-02.1: con credenciales correctas entra a la app', (
    tester,
  ) async {
    final almacen = AlmacenSesionMemoria();
    await abrir(tester, almacen: almacen);
    expect(find.text('Inicia sesión'), findsOneWidget);
    await entrar(tester, 'carmen.huaman@gmail.com', 'Cuidar2026');
    expect(repo.inicios.single, {
      'correo': 'carmen.huaman@gmail.com',
      'contrasena': 'Cuidar2026',
    });
    expect(almacen.actual?.tokenAcceso, 'acceso-1');
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets(
    'CA-02.2: con credenciales incorrectas niega el acceso con un mensaje',
    (tester) async {
      repo.errorSesion = const ProblemaApi(
        codigo: 'CREDENCIALES_INVALIDAS',
        detalle: 'No.',
        estado: 401,
      );
      await abrir(tester);
      await entrar(tester, 'carmen.huaman@gmail.com', 'mala');
      expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
      expect(
        find.text('Revisa que estén bien escritos e inténtalo otra vez.'),
        findsOneWidget,
      );
      await tocar(tester, find.text('Iniciar sesión'));
      await tocar(tester, find.text('Iniciar sesión'));
      expect(
        find.text(
          'Te quedan 2 intentos antes de un bloqueo temporal de 15 minutos.',
        ),
        findsOneWidget,
      );
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets(
    'CA-02.3: con la cuenta bloqueada informa a qué hora reintentar',
    (tester) async {
      repo.errorSesion = const ProblemaApi(
        codigo: 'CUENTA_BLOQUEADA',
        detalle: 'Bloqueada.',
        estado: 423,
        extras: {'bloqueadaHasta': '2026-10-07T15:57:00Z'},
      );
      await abrir(tester);
      await entrar(tester, 'carmen.huaman@gmail.com', 'mala');
      expect(find.text('Acceso bloqueado por 15 minutos'), findsOneWidget);
      final horaDesbloqueo = hora(
        DateTime.parse('2026-10-07T15:57:00Z').toLocal(),
      );
      expect(
        find.textContaining(horaDesbloqueo, findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Recuperar contraseña'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsNothing);
      final campos = tester.widgetList<TextField>(find.byType(TextField));
      expect(campos.every((c) => c.enabled == false), isTrue);
    },
  );

  testWidgets('pide correo y contraseña antes de enviar', (tester) async {
    await abrir(tester);
    await tocar(tester, find.text('Iniciar sesión'));
    expect(find.text('Faltan datos'), findsOneWidget);
    expect(find.text('Escribe tu correo.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
    expect(repo.inicios, isEmpty);
  });

  testWidgets('CA-02.4: cerrar sesión la termina y exige autenticarse de nuevo', (
    tester,
  ) async {
    usarTelefono(tester);
    final almacen = AlmacenSesionMemoria(sesionTitular);
    final sesiones = _SesionRepoFalso();
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: Rutas.ajustes,
        almacen: almacen,
        overrides: [
          cuentasRepositorioProvider.overrideWithValue(repo),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          sesionRepositorioProvider.overrideWithValue(sesiones),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Cerrar sesión'));
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
    expect(
      find.text(
        'Dejarás de recibir las alertas de Rosa en este celular hasta que vuelvas a iniciar sesión.',
      ),
      findsOneWidget,
    );
    await tocar(tester, find.text('Cancelar'));
    expect(almacen.actual, isNotNull);

    await tocar(tester, find.text('Cerrar sesión'));
    await tester.tap(find.widgetWithText(InkWell, 'Cerrar sesión').last);
    await tester.pump();
    expect(find.byType(PantallaArranque), findsOneWidget);
    await tester.pump(PantallaArranque.duracionAnimacion);
    await tester.pumpAndSettle();
    expect(almacen.actual, isNull);
    expect(sesiones.cerradas, ['acceso-1']);
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Sesión cerrada'), findsOneWidget);
    expect(find.text('carmen.huaman@gmail.com'), findsOneWidget);
  });

  group('CuentasRepositorioApi.iniciarSesion', () {
    ProviderContainer contenedor(AdaptadorFalso http) {
      final c = ProviderContainer(
        overrides: [
          almacenSesionProvider.overrideWithValue(AlmacenSesionMemoria()),
          adaptadorHttpProvider.overrideWithValue(http),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test(
      'POST /api/sesiones con correo y contrasena devuelve la Sesion',
      () async {
        final http = AdaptadorFalso()
          ..cuando('POST', '/api/sesiones', Respuesta(200, sesionJson()));
        final s = await contenedor(http)
            .read(cuentasRepositorioProvider)
            .iniciarSesion(
              correo: 'carmen.huaman@gmail.com',
              contrasena: 'Cuidar2026',
            );
        expect(s.hogarId, 'h-1');
        expect(http.peticiones.single.data, {
          'correo': 'carmen.huaman@gmail.com',
          'contrasena': 'Cuidar2026',
        });
      },
    );

    test('423 CUENTA_BLOQUEADA trae bloqueadaHasta', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/sesiones',
          Respuesta.problema(
            423,
            'CUENTA_BLOQUEADA',
            extras: {'bloqueadaHasta': '2026-10-07T15:57:00Z'},
          ),
        );
      await expectLater(
        contenedor(http)
            .read(cuentasRepositorioProvider)
            .iniciarSesion(correo: 'a@b.pe', contrasena: 'x'),
        throwsA(
          isA<ProblemaApi>().having(
            (p) => p.extras['bloqueadaHasta'],
            'bloqueadaHasta',
            '2026-10-07T15:57:00Z',
          ),
        ),
      );
    });
  });
}
