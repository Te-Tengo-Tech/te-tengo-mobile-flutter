import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/cliente_api.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/alertas/data/alertas_repositorio.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/familia/presentation/gestion_familia.dart';
import 'package:te_tengo/features/familia/presentation/pantallas_invitacion.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';
import 'package:te_tengo/features/inicio/presentation/pantalla_inicio.dart';

import '../../apoyo/adaptador_falso.dart';
import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../alertas/alertas_falso.dart';
import '../camaras/repositorio_falso.dart';
import '../hogar/hogar_falso.dart';
import 'familia_falso.dart';

void main() {
  late FamiliaRepositorioFalso familia;
  late AlmacenSesionMemoria almacen;

  Future<void> abrir(
    WidgetTester tester,
    String ubicacion, {
    Sesion? sesion = sesionTitular,
  }) async {
    usarTelefono(tester);
    almacen = AlmacenSesionMemoria(sesion);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        almacen: almacen,
        overrides: [
          familiaRepositorioProvider.overrideWithValue(familia),
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          camarasRepositorioProvider.overrideWithValue(
            CamarasRepositorioFalso(),
          ),
          alertasRepositorioProvider.overrideWithValue(
            AlertasRepositorioFalso(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => familia = FamiliaRepositorioFalso());

  group('CA-08.1 invitar', () {
    testWidgets('envía la invitación y vuelve a la familia', (tester) async {
      await abrir(tester, Rutas.familia);
      await tocar(tester, find.text('Invitar a un familiar'));
      expect(find.byType(PantallaInvitar), findsOneWidget);
      expect(
        find.text('Le enviaremos un enlace para crear su acceso.'),
        findsOneWidget,
      );
      expect(find.text('Qué podrá hacer'), findsOneWidget);
      expect(
        find.text(
          'No podrá cambiar los datos de Rosa, el consentimiento, la cámara ni '
          'la familia',
        ),
        findsOneWidget,
      );
      await tocar(tester, find.text('Enviar invitación'));
      expect(find.text('Escribe su correo electrónico.'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'milagros@');
      await tocar(tester, find.text('Enviar invitación'));
      expect(find.text('Revisa el correo: parece incompleto.'), findsOneWidget);
      await tester.enterText(
        find.byType(EditableText),
        'luis.huaman.r@gmail.com',
      );
      await tocar(tester, find.text('Enviar invitación'));
      expect(
        find.text('Esa persona ya está en la familia de Rosa.'),
        findsOneWidget,
      );
      expect(familia.invitaciones, isEmpty);
      await tester.enterText(
        find.byType(EditableText),
        'milagros.quispe@outlook.com',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tocar(tester, find.text('Enviar invitación'));
      expect(familia.invitaciones, ['milagros.quispe@outlook.com']);
      expect(find.byType(PantallaInvitar), findsNothing);
      expect(find.text('Invitación enviada'), findsOneWidget);
      expect(
        find.text('Le enviamos un enlace a milagros.quispe@outlook.com.'),
        findsOneWidget,
      );
    });

    testWidgets('409 YA_ES_FAMILIAR se muestra en el campo', (tester) async {
      familia.errorInvitar = const ProblemaApi(
        codigo: 'YA_ES_FAMILIAR',
        detalle: 'Esa persona ya es parte de la familia.',
        estado: 409,
      );
      await abrir(tester, Rutas.invitar);
      await tester.enterText(find.byType(EditableText), 'otra@correo.com');
      await tocar(tester, find.text('Enviar invitación'));
      expect(
        find.text('Esa persona ya es parte de la familia.'),
        findsOneWidget,
      );
    });
  });

  group('CA-08.2 aceptar la invitación', () {
    const enlace =
        '/invitacion/tok-1?titular=Carmen&adultoMayor=Rosa%20Huam%C3%A1n'
        '&correo=milagros.quispe%40outlook.com';

    testWidgets('crea el acceso y queda vinculado con las alertas activas', (
      tester,
    ) async {
      await abrir(tester, enlace, sesion: null);
      expect(find.byType(PantallaAceptarInvitacion), findsOneWidget);
      expect(find.text('Carmen te invitó a cuidar a Rosa'), findsOneWidget);
      expect(
        find.text(
          'Crea tu acceso para recibir las alertas de Rosa Huamán en este '
          'celular.',
        ),
        findsOneWidget,
      );
      expect(find.text('milagros.quispe@outlook.com'), findsOneWidget);
      expect(
        find.text('Es el correo al que llegó la invitación.'),
        findsOneWidget,
      );
      await tocar(tester, find.text('Crear mi acceso'));
      expect(find.text('Escribe tu nombre y apellido.'), findsOneWidget);
      expect(find.text('Crea una contraseña.'), findsOneWidget);
      final campos = find.byType(EditableText);
      await tester.enterText(campos.at(0), 'Milagros Quispe');
      await tester.enterText(campos.at(2), 'clave1234');
      await tocar(tester, find.text('Crear mi acceso'));
      expect(familia.aceptaciones, [('tok-1', 'Milagros Quispe', 'clave1234')]);
      expect(almacen.actual?.rol, Rol.invitado);
      expect(find.byType(PantallaAccesoCreado), findsOneWidget);
      expect(
        find.text('Listo, Luis. Ya recibes las alertas de Rosa.'),
        findsOneWidget,
      );
      expect(
        find.text('Te llegarán aunque tengas la app cerrada.'),
        findsOneWidget,
      );
      expect(find.text('Solo Carmen puede'), findsOneWidget);
      await tocar(tester, find.text('Ir al inicio'));
      expect(find.byType(PantallaInicio), findsOneWidget);
    });

    testWidgets('410 INVITACION_VENCIDA muestra el detalle', (tester) async {
      familia.errorAceptar = const ProblemaApi(
        codigo: 'INVITACION_VENCIDA',
        detalle: 'Esta invitación ya venció. Pide una nueva.',
        estado: 410,
      );
      await abrir(tester, enlace, sesion: null);
      final campos = find.byType(EditableText);
      await tester.enterText(campos.at(0), 'Milagros Quispe');
      await tester.enterText(campos.at(2), 'clave1234');
      await tocar(tester, find.text('Crear mi acceso'));
      expect(
        find.text('Esta invitación ya venció. Pide una nueva.'),
        findsOneWidget,
      );
      expect(almacen.actual, isNull);
    });

    testWidgets('con una cuenta abierta se une sin crear otra', (tester) async {
      await abrir(tester, '/invitacion/tok-2', sesion: sesionSinHogar);
      expect(find.byType(EditableText), findsNothing);
      await tocar(tester, find.text('Crear mi acceso').last);
      expect(familia.aceptaciones, [('tok-2', null, null)]);
      expect(find.byType(PantallaAccesoCreado), findsOneWidget);
    });
  });

  group('CA-08.3 opciones de un familiar', () {
    testWidgets('retira el acceso tras confirmarlo', (tester) async {
      await abrir(tester, Rutas.familia);
      await tocar(tester, find.text('Luis Huamán'));
      expect(find.text('luis.huaman.r@gmail.com'), findsOneWidget);
      expect(find.text('Hacer contacto principal'), findsOneWidget);
      expect(find.text('Hacer contacto secundario'), findsNothing);
      await tocar(tester, find.text('Retirar acceso'));
      expect(find.text('¿Retirar el acceso de Luis Huamán?'), findsOneWidget);
      expect(
        find.text(
          'Dejará de recibir las alertas de Rosa y no podrá ver el historial ni '
          'los clips. Te quedarás sin contacto secundario.',
        ),
        findsOneWidget,
      );
      await tocar(tester, find.text('Cancelar'));
      expect(familia.retirados, isEmpty);
      await tocar(tester, find.text('Retirar acceso'));
      await tocar(tester, find.text('Retirar acceso').last);
      expect(familia.retirados, ['u-luis']);
      expect(find.text('Luis ya no recibe alertas'), findsOneWidget);
      expect(find.text('Te quedaste sin contacto secundario.'), findsOneWidget);
      expect(find.text('Luis Huamán'), findsNothing);
      expect(find.text('No hay contacto secundario'), findsOneWidget);
    });

    testWidgets('lo hace contacto principal', (tester) async {
      await abrir(tester, Rutas.familia);
      await tocar(tester, find.text('Luis Huamán'));
      await tocar(tester, find.text('Hacer contacto principal'));
      final guardado = familia.avisosGuardados.single;
      expect(guardado.principalId, 'u-luis');
      expect(guardado.secundarioId, 'u-carmen');
      expect(find.text('Luis ahora es contacto principal'), findsOneWidget);
      expect(find.text('El orden de aviso se actualizó.'), findsOneWidget);
    });

    testWidgets('el titular no puede retirarse a sí mismo', (tester) async {
      await abrir(tester, Rutas.familia);
      await tocar(tester, find.text('Carmen Huamán (tú)'));
      expect(find.textContaining('Eres titular:'), findsOneWidget);
      expect(find.text('Retirar acceso'), findsNothing);
      // The family always keeps a principal: it changes by choosing another one.
      expect(find.text('Hacer contacto secundario'), findsNothing);
    });

    testWidgets('un familiar invitado no ve las opciones', (tester) async {
      await abrir(tester, Rutas.familia, sesion: sesionInvitado);
      await tester.tap(find.text('Carmen Huamán'));
      await tester.pumpAndSettle();
      expect(find.text('Retirar acceso'), findsNothing);
      expect(find.text('Invitar a un familiar'), findsNothing);
    });
  });

  test('aceptación y retiro contra la API', () async {
    final http = AdaptadorFalso()
      ..cuando(
        'POST',
        '/api/invitaciones/tok-1/aceptacion',
        Respuesta(201, sesionJson(rol: 'INVITADO')),
      )
      ..cuando('DELETE', '/api/familiares/u-luis', const Respuesta(204, null));
    final c = ProviderContainer(
      overrides: [
        almacenSesionProvider.overrideWithValue(
          AlmacenSesionMemoria(sesionTitular),
        ),
        adaptadorHttpProvider.overrideWithValue(http),
      ],
    );
    addTearDown(c.dispose);
    final repo = c.read(familiaRepositorioProvider);
    final s = await repo.aceptarInvitacion(
      'tok-1',
      nombre: 'Milagros Quispe',
      contrasena: 'clave1234',
    );
    expect(s.rol, Rol.invitado);
    expect(http.peticiones.first.data, {
      'nombre': 'Milagros Quispe',
      'contrasena': 'clave1234',
    });
    await repo.retirar('u-luis');
    expect(http.peticiones.last.method, 'DELETE');
  });
}
