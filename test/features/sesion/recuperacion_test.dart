import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/sesion/data/cuentas_repositorio.dart';
import 'package:te_tengo/features/sesion/presentation/pantallas_recuperacion.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import 'cuentas_falso.dart';

Finder campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoTexto, etiqueta),
  matching: find.byType(TextField),
);

void main() {
  late CuentasRepositorioFalso repo;

  Future<void> abrir(WidgetTester tester, String ubicacion) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        overrides: [cuentasRepositorioProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => repo = CuentasRepositorioFalso());

  testWidgets('el inicio de sesión lleva a recuperar con el correo escrito', (
    tester,
  ) async {
    await abrir(tester, Rutas.iniciarSesion);
    await tester.enterText(
      campo('Correo electrónico'),
      'carmen.huaman@gmail.com',
    );
    await tocar(tester, find.text('¿Olvidaste tu contraseña?'));
    expect(find.text('Recuperar contraseña'), findsOneWidget);
    expect(find.text('carmen.huaman@gmail.com'), findsOneWidget);
  });

  testWidgets('CA-03.1: envía el enlace al correo registrado', (tester) async {
    await abrir(tester, Rutas.recuperar);
    await tester.enterText(
      campo('Correo electrónico'),
      'carmen.huaman@gmail.com',
    );
    await tocar(tester, find.text('Enviar enlace'));
    expect(repo.recuperaciones, ['carmen.huaman@gmail.com']);
    expect(find.text('Revisa tu correo'), findsOneWidget);
    expect(
      find.textContaining('Vence en 30 minutos.', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Reenviar enlace en', findRichText: true),
      findsOneWidget,
    );
    await tester.pump(PantallaEnlaceEnviado.espera);
    await tester.pumpAndSettle();
    await tocar(tester, find.text('Reenviar enlace'));
    expect(repo.recuperaciones, hasLength(2));
  });

  testWidgets(
    'CA-03.2: con un correo no registrado muestra el mismo mensaje genérico',
    (tester) async {
      await abrir(tester, Rutas.recuperar);
      await tester.enterText(campo('Correo electrónico'), 'nadie@correo.com');
      await tocar(tester, find.text('Enviar enlace'));
      expect(find.text('Revisa tu correo'), findsOneWidget);
      expect(
        find.textContaining(
          'Si nadie@correo.com tiene cuenta, te llegará un enlace.',
          findRichText: true,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('pide un correo válido antes de enviar', (tester) async {
    await abrir(tester, Rutas.recuperar);
    await tocar(tester, find.text('Enviar enlace'));
    expect(find.text('Escribe tu correo electrónico.'), findsOneWidget);
    expect(repo.recuperaciones, isEmpty);
  });

  testWidgets(
    'el enlace válido guarda la nueva contraseña y vuelve a iniciar sesión',
    (tester) async {
      await abrir(
        tester,
        '${Rutas.nuevaContrasena}?token=t-1&correo=carmen.huaman@gmail.com',
      );
      expect(
        find.textContaining('carmen.huaman@gmail.com', findRichText: true),
        findsOneWidget,
      );
      await tester.enterText(campo('Nueva contraseña'), 'Nueva2026');
      await tester.enterText(campo('Repite la contraseña'), 'Otra2026');
      await tocar(tester, find.text('Guardar contraseña'));
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      await tester.enterText(campo('Repite la contraseña'), 'Nueva2026');
      await tocar(tester, find.text('Guardar contraseña'));
      expect(repo.confirmaciones.single, {
        'token': 't-1',
        'nuevaContrasena': 'Nueva2026',
      });
      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.text('Contraseña actualizada'), findsOneWidget);
    },
  );

  testWidgets('CA-03.3: rechaza el enlace vencido y permite pedir uno nuevo', (
    tester,
  ) async {
    repo.errorConfirmacion = const ProblemaApi(
      codigo: 'ENLACE_VENCIDO',
      detalle: 'Vencido.',
      estado: 410,
    );
    await abrir(tester, '${Rutas.nuevaContrasena}?token=viejo');
    await tester.enterText(campo('Nueva contraseña'), 'Nueva2026');
    await tester.enterText(campo('Repite la contraseña'), 'Nueva2026');
    await tocar(tester, find.text('Guardar contraseña'));
    expect(find.text('Este enlace ya venció'), findsOneWidget);
    await tocar(tester, find.text('Pedir un enlace nuevo'));
    expect(
      find.text('Te enviaremos un enlace para crear una nueva.'),
      findsOneWidget,
    );
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

    test('POST /api/recuperaciones con el correo', () async {
      final http = AdaptadorFalso()
        ..cuando('POST', '/api/recuperaciones', const Respuesta(202));
      await contenedor(
        http,
      ).read(cuentasRepositorioProvider).solicitarRecuperacion('a@b.pe');
      expect(http.peticiones.single.data, {'correo': 'a@b.pe'});
    });

    test('410 ENLACE_VENCIDO en la confirmación', () async {
      final http = AdaptadorFalso()
        ..cuando(
          'POST',
          '/api/recuperaciones/confirmacion',
          Respuesta.problema(410, 'ENLACE_VENCIDO'),
        );
      await expectLater(
        contenedor(http)
            .read(cuentasRepositorioProvider)
            .confirmarRecuperacion(token: 't', nuevaContrasena: 'Nueva2026'),
        throwsA(
          isA<ProblemaApi>().having(
            (p) => p.codigo,
            'codigo',
            'ENLACE_VENCIDO',
          ),
        ),
      );
      expect(http.peticiones.single.data, {
        'token': 't',
        'nuevaContrasena': 'Nueva2026',
      });
    });
  });
}
