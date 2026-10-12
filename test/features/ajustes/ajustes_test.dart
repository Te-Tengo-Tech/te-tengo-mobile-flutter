import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/sesion/sesion.dart';
import 'package:te_tengo/features/familia/data/familia_repositorio.dart';
import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../familia/familia_falso.dart';
import '../hogar/hogar_falso.dart';

void main() {
  Future<void> abrir(WidgetTester tester, Sesion sesion) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      appDePrueba(
        ubicacion: Rutas.ajustes,
        sesion: sesion,
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

  /// Vertical position of [texto] in the scrolled list (it is built on the way).
  Future<double> alturaDe(WidgetTester tester, String texto) async {
    await verHasta(tester, find.text(texto));
    final lista = tester.state<ScrollableState>(
      find.byType(Scrollable).hitTestable().first,
    );
    return tester.getTopLeft(find.text(texto).first).dy + lista.position.pixels;
  }

  for (final (nombre, sesion) in [
    ('titular', sesionTitular),
    ('familiar invitado', sesionInvitado),
  ]) {
    testWidgets('Ajustes del $nombre va en secciones, como la pantalla 100', (
      tester,
    ) async {
      await abrir(tester, sesion);
      // Persona cuidada › Rosa; Monitoreo › Cámaras, orden, privacidad, actividad.
      final persona = await alturaDe(tester, 'Persona cuidada');
      final rosa = await alturaDe(tester, 'Rosa Huamán');
      final monitoreo = await alturaDe(tester, 'Monitoreo');
      final camaras = await alturaDe(tester, 'Cámaras y PCs');
      final privacidad = await alturaDe(tester, 'Privacidad y consentimiento');
      final actividad = await alturaDe(tester, 'Actividad');
      expect(persona < rosa && rosa < monitoreo, isTrue);
      expect(monitoreo < camaras, isTrue);
      expect(camaras < privacidad && privacidad < actividad, isTrue);
      // Este celular › Notificaciones, Preferencias; Cuenta › Tu cuenta, Cerrar sesión.
      final celular = await alturaDe(tester, 'Este celular');
      final notificaciones = await alturaDe(tester, 'Notificaciones');
      final preferencias = await alturaDe(tester, 'Preferencias');
      expect(actividad < celular, isTrue);
      expect(celular < notificaciones && notificaciones < preferencias, isTrue);
      final cuenta = await alturaDe(tester, 'Cuenta');
      final tuCuenta = await alturaDe(
        tester,
        sesion.esTitular
            ? 'Tu cuenta · Titular'
            : 'Tu cuenta · Familiar invitado',
      );
      final cerrar = await alturaDe(tester, 'Cerrar sesión');
      expect(preferencias < cuenta, isTrue);
      expect(cuenta < tuCuenta && tuCuenta < cerrar, isTrue);
    });
  }

  testWidgets('el familiar invitado también abre «Tu perfil»', (tester) async {
    await abrir(tester, sesionInvitado);
    await tocar(tester, find.text('Tu cuenta · Familiar invitado'));
    expect(find.text('Tu perfil'), findsOneWidget);
  });
}
