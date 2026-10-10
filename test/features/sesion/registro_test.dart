import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/sesion/data/cuentas_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import 'cuentas_falso.dart';

Finder campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoTexto, etiqueta),
  matching: find.byType(TextField),
);

Future<void> abrirRegistro(
  WidgetTester tester,
  CuentasRepositorioFalso repo,
) async {
  await tester.pumpWidget(
    appDePrueba(
      ubicacion: Rutas.registro,
      overrides: [cuentasRepositorioProvider.overrideWithValue(repo)],
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> llenar(
  WidgetTester tester, {
  String nombre = '',
  String correo = '',
  String clave = '',
}) async {
  await tester.enterText(campo('Tu nombre y apellido'), nombre);
  await tester.enterText(campo('Correo electrónico'), correo);
  await tester.enterText(campo('Contraseña'), clave);
  await tester.ensureVisible(find.widgetWithText(InkWell, 'Crear cuenta').last);
  await tester.tap(find.widgetWithText(InkWell, 'Crear cuenta').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la bienvenida lleva a crear una cuenta', (tester) async {
    usarTelefono(tester);
    await tester.pumpWidget(appDePrueba(ubicacion: Rutas.bienvenida));
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Crear cuenta'));
    expect(find.text('Tu nombre y apellido'), findsOneWidget);
  });

  testWidgets(
    'CA-01.1: crea la cuenta, inicia sesión y muestra la confirmación',
    (tester) async {
      final repo = CuentasRepositorioFalso();
      await abrirRegistro(tester, repo);
      await llenar(
        tester,
        nombre: 'Carmen Huamán',
        correo: 'carmen.huaman@gmail.com',
        clave: 'Cuidar2026',
      );
      expect(repo.registros.single, {
        'nombre': 'Carmen Huamán',
        'correo': 'carmen.huaman@gmail.com',
        'contrasena': 'Cuidar2026',
      });
      expect(repo.inicios.single['correo'], 'carmen.huaman@gmail.com');
      expect(find.text('Tu cuenta está lista, Carmen.'), findsOneWidget);
      expect(find.text('Su cámara, ya instalada'), findsOneWidget);
      await tester.tap(find.text('Empezar'));
      await tester.pumpAndSettle();
      expect(find.text('Persona cuidada'), findsOneWidget);
    },
  );

  testWidgets('CA-01.2: rechaza un correo ya registrado', (tester) async {
    final repo = CuentasRepositorioFalso(
      errorRegistro: const ProblemaApi(
        codigo: 'CORREO_EN_USO',
        detalle: 'En uso.',
        estado: 409,
      ),
    );
    await abrirRegistro(tester, repo);
    await llenar(
      tester,
      nombre: 'Carmen Huamán',
      correo: 'carmen.huaman@gmail.com',
      clave: 'Cuidar2026',
    );
    expect(find.text('Ese correo ya tiene una cuenta'), findsOneWidget);
    expect(find.text('Este correo ya está registrado.'), findsOneWidget);
    expect(find.text('Iniciar sesión con este correo'), findsOneWidget);
    expect(find.text('Recuperar mi contraseña'), findsOneWidget);
    expect(repo.inicios, isEmpty);
  });

  testWidgets(
    'CA-01.3: con campos vacíos no registra y resalta los faltantes',
    (tester) async {
      final repo = CuentasRepositorioFalso();
      await abrirRegistro(tester, repo);
      await llenar(tester, nombre: 'Carmen Huamán');
      expect(find.text('Completa los campos marcados'), findsOneWidget);
      expect(find.text('Escribe tu correo electrónico.'), findsOneWidget);
      expect(find.text('Crea una contraseña.'), findsOneWidget);
      expect(find.text('Escribe tu nombre y apellido.'), findsNothing);
      expect(repo.registros, isEmpty);
    },
  );

  testWidgets(
    'CA-01.3: resalta los campos que marca el backend (400 VALIDACION)',
    (tester) async {
      final repo = CuentasRepositorioFalso(
        errorRegistro: const ProblemaApi(
          codigo: 'VALIDACION',
          detalle: 'Datos inválidos.',
          campos: {'nombre': 'Escribe tu nombre y apellido.'},
        ),
      );
      await abrirRegistro(tester, repo);
      await llenar(
        tester,
        nombre: 'C',
        correo: 'carmen.huaman@gmail.com',
        clave: 'Cuidar2026',
      );
      expect(find.text('Escribe tu nombre y apellido.'), findsOneWidget);
    },
  );

  testWidgets('pide una contraseña de 8 caracteres con un número', (
    tester,
  ) async {
    final repo = CuentasRepositorioFalso();
    await abrirRegistro(tester, repo);
    await llenar(
      tester,
      nombre: 'Carmen Huamán',
      correo: 'carmen@x',
      clave: 'corta',
    );
    expect(find.text('Revisa el correo: parece incompleto.'), findsOneWidget);
    expect(find.text('Usa al menos 8 caracteres y un número.'), findsOneWidget);
    expect(repo.registros, isEmpty);
  });

  group('CuentasRepositorioApi', () {
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

    test('POST /api/cuentas con correo, contrasena y nombre', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/cuentas',
          const Respuesta(201, {
            'id': 'u-1',
            'correo': 'a@b.pe',
            'nombre': 'Ana',
          }),
        );
      final cuenta = await contenedor(http)
          .read(cuentasRepositorioProvider)
          .registrar(nombre: 'Ana', correo: 'a@b.pe', contrasena: 'Clave2026');
      expect(cuenta.id, 'u-1');
      expect(http.peticiones.single.data, {
        'correo': 'a@b.pe',
        'contrasena': 'Clave2026',
        'nombre': 'Ana',
      });
    });

    test('409 CORREO_EN_USO llega como ProblemaApi', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/cuentas',
          Respuesta.problema(409, 'CORREO_EN_USO'),
        );
      await expectLater(
        contenedor(http)
            .read(cuentasRepositorioProvider)
            .registrar(
              nombre: 'Ana',
              correo: 'a@b.pe',
              contrasena: 'Clave2026',
            ),
        throwsA(
          isA<ProblemaApi>().having((p) => p.codigo, 'codigo', 'CORREO_EN_USO'),
        ),
      );
    });
  });
}
