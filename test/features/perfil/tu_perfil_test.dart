import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/core/sesion/almacen_sesion.dart';
import 'package:te_tengo/core/ui/formulario.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';
import 'perfil_falso.dart';

Finder campo(String etiqueta) => find.descendant(
  of: find.widgetWithText(CampoTexto, etiqueta),
  matching: find.byType(TextField),
);

void main() {
  late PerfilRepositorioFalso perfil;
  late AlmacenSesionMemoria almacen;

  Future<void> abrir(
    WidgetTester tester, {
    String ubicacion = Rutas.ajustes,
  }) async {
    usarTelefono(tester);
    almacen = AlmacenSesionMemoria(sesionTitular);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: ubicacion,
        almacen: almacen,
        perfil: perfil,
        overrides: [
          hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          familiaRepositorioProvider.overrideWithValue(
            FamiliaRepositorioFalso(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => perfil = PerfilRepositorioFalso(perfilCarmen()));

  group('Tu perfil (pantalla 102)', () {
    testWidgets('se abre desde «Tu cuenta» en Ajustes con sus datos', (
      tester,
    ) async {
      await abrir(tester);
      await tocar(tester, find.text('Tu cuenta · Titular'));
      expect(find.text('Tu perfil'), findsOneWidget);
      expect(find.text('Cambiar foto'), findsOneWidget);
      expect(find.text('Carmen Huamán'), findsOneWidget);
      expect(find.text('981 220 417'), findsOneWidget);
      expect(find.text('Parentesco con Rosa'), findsOneWidget);
      expect(find.text('Hija'), findsOneWidget);
      expect(find.text('Con él inicias sesión.'), findsOneWidget);
      final correo = tester.widget<TextField>(campo('Correo electrónico'));
      expect(correo.enabled, isFalse);
      expect(correo.controller!.text, 'carmen.huaman@gmail.com');
    });

    testWidgets('guarda nombre, teléfono y parentesco; la familia ve el nombre '
        'nuevo', (tester) async {
      await abrir(tester, ubicacion: Rutas.tuPerfil);
      await tester.enterText(
        campo('Nombre y apellido'),
        ' Carmen  Rosa Huamán ',
      );
      await tester.enterText(campo('Teléfono'), '');
      await tester.enterText(campo('Parentesco con Rosa'), 'Hija mayor');
      await tocar(tester, find.text('Guardar cambios'));
      expect(perfil.guardados, [('Carmen Rosa Huamán', null, 'Hija mayor')]);
      expect(find.text('Cambios guardados'), findsOneWidget);
      expect(find.text('Tu familia verá tu nombre nuevo.'), findsOneWidget);
      // The session keeps the new name for the greetings and the notices.
      expect(almacen.actual!.usuario.nombre, 'Carmen Rosa Huamán');
    });

    testWidgets('pide el nombre y un teléfono con solo números', (
      tester,
    ) async {
      await abrir(tester, ubicacion: Rutas.tuPerfil);
      await tester.enterText(campo('Nombre y apellido'), '  ');
      await tester.enterText(campo('Teléfono'), '98-12');
      await tocar(tester, find.text('Guardar cambios'));
      expect(find.text('Escribe tu nombre y apellido.'), findsOneWidget);
      expect(find.text('Revisa el teléfono: solo números.'), findsOneWidget);
      expect(perfil.guardados, isEmpty);
    });

    testWidgets('muestra el error de un campo que el servidor rechaza', (
      tester,
    ) async {
      perfil.errorGuardar = const ProblemaApi(
        codigo: 'VALIDACION',
        detalle: 'Revisa los datos.',
        campos: {'parentesco': 'Usa 40 caracteres o menos.'},
      );
      await abrir(tester, ubicacion: Rutas.tuPerfil);
      await tocar(tester, find.text('Guardar cambios'));
      expect(find.text('Usa 40 caracteres o menos.'), findsOneWidget);
    });

    testWidgets('con un servidor sin perfiles muestra la cuenta sin editarla', (
      tester,
    ) async {
      perfil = PerfilRepositorioFalso();
      await abrir(tester, ubicacion: Rutas.tuPerfil);
      expect(find.text('Carmen Huamán'), findsOneWidget);
      expect(find.text('Cambiar foto'), findsNothing);
      expect(find.text('Guardar cambios'), findsNothing);
      expect(
        tester.widget<TextField>(campo('Nombre y apellido')).enabled,
        isFalse,
      );
    });
  });

  group('Cambiar contraseña', () {
    testWidgets('pide la actual y la nueva dos veces, y la guarda', (
      tester,
    ) async {
      await abrir(tester, ubicacion: Rutas.tuPerfil);
      await tocar(tester, find.text('Cambiar contraseña'));
      await tocar(tester, find.text('Guardar contraseña'));
      expect(find.text('Escribe tu contraseña actual.'), findsOneWidget);
      expect(
        find.text('Usa al menos 8 caracteres y un número.'),
        findsOneWidget,
      );
      await tester.enterText(campo('Contraseña actual'), 'rosa2026');
      await tester.enterText(campo('Nueva contraseña'), 'cuidamos2026');
      await tester.enterText(campo('Repite la nueva contraseña'), 'cuidamos');
      await tocar(tester, find.text('Guardar contraseña'));
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      await tester.enterText(
        campo('Repite la nueva contraseña'),
        'cuidamos2026',
      );
      await tocar(tester, find.text('Guardar contraseña'));
      expect(perfil.contrasenas, [('rosa2026', 'cuidamos2026')]);
      expect(find.text('Contraseña actualizada'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
    });

    testWidgets('una contraseña actual incorrecta se marca en su campo', (
      tester,
    ) async {
      perfil.errorContrasena = const ProblemaApi(
        codigo: 'CONTRASENA_ACTUAL_INCORRECTA',
        detalle: 'La contraseña actual no coincide.',
        estado: 422,
      );
      await abrir(tester, ubicacion: Rutas.cambiarContrasena);
      await tester.enterText(campo('Contraseña actual'), 'otra1234');
      await tester.enterText(campo('Nueva contraseña'), 'cuidamos2026');
      await tester.enterText(
        campo('Repite la nueva contraseña'),
        'cuidamos2026',
      );
      await tocar(tester, find.text('Guardar contraseña'));
      expect(
        find.text('No coincide con tu contraseña actual.'),
        findsOneWidget,
      );
      expect(find.text('Contraseña actualizada'), findsNothing);
    });
  });
}
