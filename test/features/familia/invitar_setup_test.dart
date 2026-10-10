import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../camaras/repositorio_falso.dart';
import '../hogar/hogar_falso.dart';
import 'familia_falso.dart';

Finder get campoCorreo => find.descendant(
  of: find.widgetWithText(CampoTexto, 'Correo de tu familiar'),
  matching: find.byType(TextField),
);

void main() {
  late FamiliaRepositorioFalso familia;
  late HogarRepositorioFalso hogar;

  Future<void> abrir(WidgetTester tester, String ubicacion) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        sesion: sesionTitular,
        overrides: [
          familiaRepositorioProvider.overrideWithValue(familia),
          hogarRepositorioProvider.overrideWithValue(hogar),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    familia = FamiliaRepositorioFalso([carmen]);
    hogar = HogarRepositorioFalso();
  });

  testWidgets('CA-08.1: envía la invitación al correo del familiar', (
    tester,
  ) async {
    await abrir(tester, Rutas.configFamilia);
    expect(find.text('Paso 4 de 5'), findsOneWidget);
    expect(
      find.text(
        'Recibirá las alertas de Rosa y, si no atiendes una en 5 min, le '
        'avisaremos.',
      ),
      findsOneWidget,
    );
    await tester.enterText(campoCorreo, 'luis.huaman.r@gmail.com');
    await tocar(tester, find.text('Enviar invitación'));
    expect(familia.invitaciones, ['luis.huaman.r@gmail.com']);
    expect(find.text('Invitación enviada'), findsOneWidget);
    await tocar(tester, find.text('Continuar'));
    // Step 5 explains the notifications before the phone asks.
    expect(find.text('Paso 5 de 5'), findsOneWidget);
    expect(find.text('Que no se te pase ninguna caída'), findsOneWidget);
    await tocar(tester, find.text('Continuar'));
    expect(find.text('Todo listo. Ya estás cerca de Rosa.'), findsOneWidget);
    expect(find.text('1 familiar invitado'), findsOneWidget);
    expect(find.text('luis.huaman.r@gmail.com'), findsOneWidget);
    expect(find.text('Consentimiento registrado'), findsOneWidget);
    expect(find.text('Cámara de la Sala'), findsOneWidget);
  });

  testWidgets('no permite invitarse a sí misma ni un correo incompleto', (
    tester,
  ) async {
    await abrir(tester, Rutas.configFamilia);
    await tocar(tester, find.text('Enviar invitación'));
    expect(find.text('Escribe el correo de tu familiar.'), findsOneWidget);
    await tester.enterText(campoCorreo, 'carmen.huaman@gmail.com');
    await tocar(tester, find.text('Enviar invitación'));
    expect(
      find.text('Ese es tu propio correo. Invita a otra persona.'),
      findsOneWidget,
    );
    expect(familia.invitaciones, isEmpty);
  });

  testWidgets('409 YA_ES_FAMILIAR marca el correo', (tester) async {
    familia.errorInvitar = const ProblemaApi(
      codigo: 'YA_ES_FAMILIAR',
      detalle: 'Esa persona ya está en la familia de Rosa.',
      estado: 409,
    );
    await abrir(tester, Rutas.configFamilia);
    await tester.enterText(campoCorreo, 'luis.huaman.r@gmail.com');
    await tocar(tester, find.text('Enviar invitación'));
    expect(
      find.text('Esa persona ya está en la familia de Rosa.'),
      findsOneWidget,
    );
  });

  testWidgets('se puede hacer después y lo dice el resumen', (tester) async {
    hogar.hogar = hogarDeRosa(consentimiento: false);
    await abrir(tester, Rutas.configFamilia);
    await tocar(tester, find.text('Hacerlo después'));
    await tocar(tester, find.text('Continuar'));
    expect(find.text('Sin contacto secundario'), findsOneWidget);
    expect(find.text('Falta el consentimiento'), findsOneWidget);
    await tocar(tester, find.text('Ir al inicio'));
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  test('POST /api/invitaciones con el correo', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'POST',
        '/api/invitaciones',
        const Respuesta(201, {
          'id': 'i-1',
          'correo': 'luis.huaman.r@gmail.com',
          'expiraEn': '2026-10-14T15:00:00Z',
        }),
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
    final i = await c
        .read(familiaRepositorioProvider)
        .invitar('luis.huaman.r@gmail.com');
    expect(i.expiraEn, isNotNull);
    expect(http.peticiones.single.data, {'correo': 'luis.huaman.r@gmail.com'});
  });
}
