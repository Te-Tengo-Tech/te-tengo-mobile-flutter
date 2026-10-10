import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/features/ajustes/presentation/pantalla_avisos_setup.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/dispositivo_falso.dart';
import '../alertas/alertas_falso.dart';
import '../alertas/apoyo_alertas.dart';

void main() {
  Future<void> abrir(WidgetTester tester, PermisoFalso permiso) =>
      abrirConAlertas(
        tester,
        ubicacion: '${Rutas.configAvisos}?invitado=luis.huaman.r@gmail.com',
        alertas: AlertasRepositorioFalso(),
        permiso: permiso,
      );

  testWidgets('paso 5: explica por qué antes de que el celular pida permiso', (
    tester,
  ) async {
    final permiso = PermisoFalso(activas: false);
    await abrir(tester, permiso);
    expect(find.text('Paso 5 de 5'), findsOneWidget);
    expect(find.text('Que no se te pase ninguna caída'), findsOneWidget);
    expect(
      find.text(
        'Te llegará la alerta aunque tengas la app cerrada o el celular en '
        'silencio.',
      ),
      findsOneWidget,
    );
    expect(find.text('Para recibir las alertas'), findsOneWidget);
    await verHasta(tester, find.text('Continuar sin activar todo'));
    expect(find.text('Continuar sin activar todo'), findsOneWidget);
    // The system prompt only comes after the explanation, from «Permitir».
    expect(permiso.pedidos, 0);
    await tocar(tester, find.text('Permitir').first);
    expect(permiso.pedidos, 1);
    expect(find.byType(PermisoActivado), findsOneWidget);
    await verHasta(tester, find.text('Continuar'));
    await tocar(tester, find.text('Continuar'));
    expect(find.text('Todo listo. Ya estás cerca de Rosa.'), findsOneWidget);
    expect(find.text('luis.huaman.r@gmail.com'), findsOneWidget);
  });

  testWidgets('«Sonar en silencio» abre los ajustes del celular y no '
      'dice que quedó activado', (tester) async {
    final permiso = PermisoFalso();
    await abrir(tester, permiso);
    expect(find.text('Sonar en silencio'), findsOneWidget);
    expect(find.text('Las caídas suenan igual'), findsOneWidget);
    await tocar(tester, find.text('Permitir'));
    expect(permiso.ajustesAbiertos, 1);
    // The app cannot read the system choice back: the row keeps «Permitir».
    expect(find.text('Permitir'), findsOneWidget);
  });

  testWidgets('en el navegador no ofrece «Sonar en silencio»', (tester) async {
    await abrir(tester, PermisoFalso(ajustesDeSonido: false));
    expect(find.text('Sonar en silencio'), findsNothing);
  });

  testWidgets('Notificaciones también ofrece «Sonar en silencio»', (
    tester,
  ) async {
    final permiso = PermisoFalso();
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.notificaciones,
      alertas: AlertasRepositorioFalso(),
      permiso: permiso,
    );
    expect(
      find.text('Las caídas suenan aunque el celular esté en silencio'),
      findsOneWidget,
    );
    await tocar(tester, find.text('Permitir'));
    expect(permiso.ajustesAbiertos, 1);
  });
}
