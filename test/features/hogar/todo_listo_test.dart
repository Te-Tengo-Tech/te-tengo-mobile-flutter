import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/core/web/entorno.dart';
import 'package:te_tengo/features/ajustes/presentation/permiso_avisos.dart';
import 'package:te_tengo/features/instalar/presentation/instalar_app.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/dispositivo_falso.dart';
import '../alertas/alertas_falso.dart';
import '../alertas/apoyo_alertas.dart';

/// «Todo listo», after setup step 2 (docs/ONBOARDING.md): the notifications are asked for here,
/// explained first, and the PC and the family are left for later.
void main() {
  Future<void> abrir(WidgetTester tester, PermisoFalso permiso) =>
      abrirConAlertas(
        tester,
        ubicacion: Rutas.configListo,
        alertas: AlertasRepositorioFalso(),
        permiso: permiso,
      );

  testWidgets('explica por qué antes de que el celular pida el permiso de '
      'notificaciones (CA-16.2)', (tester) async {
    final permiso = PermisoFalso(activas: false);
    await abrir(tester, permiso);
    expect(find.text('Todo listo. Ya estás cerca de Rosa.'), findsOneWidget);
    expect(find.text('Que no se te pase ninguna caída'), findsOneWidget);
    await verHasta(
      tester,
      find.text('Aunque la app esté cerrada o el celular en silencio.'),
    );
    expect(
      find.text('Aunque la app esté cerrada o el celular en silencio.'),
      findsOneWidget,
    );
    await verHasta(tester, find.text('Para recibir las alertas'));
    expect(find.text('Para recibir las alertas'), findsOneWidget);
    // The system prompt only comes after the explanation, from «Permitir».
    expect(permiso.pedidos, 0);
    await tocar(tester, find.text('Permitir').first);
    expect(permiso.pedidos, 1);
    expect(find.byType(PermisoActivado), findsOneWidget);
  });

  testWidgets('no es un paso: no muestra «Paso N de 2» y lleva al inicio', (
    tester,
  ) async {
    await abrir(tester, PermisoFalso(activas: false));
    expect(find.textContaining('Paso '), findsNothing);
    await verHasta(tester, find.text('Ir al inicio'));
    await tocar(tester, find.text('Ir al inicio'));
    expect(find.text('Hola, Carmen'), findsOneWidget);
    // Without the permission, Inicio keeps asking for it (CA-16.3).
    expect(find.text('Activa las notificaciones'), findsOneWidget);
  });

  testWidgets('deja la familia para después y dice dónde hacerlo', (
    tester,
  ) async {
    await abrir(tester, PermisoFalso());
    await verHasta(tester, find.text('Sin contacto secundario'));
    expect(find.text('Invítalo desde Familia'), findsOneWidget);
  });

  testWidgets('«Sonar en silencio» abre los ajustes del celular y no '
      'dice que quedó activado', (tester) async {
    final permiso = PermisoFalso();
    await abrir(tester, permiso);
    await verHasta(tester, find.text('Sonar en silencio'));
    expect(find.text('Las caídas suenan igual'), findsOneWidget);
    await tocar(tester, find.text('Permitir'));
    expect(permiso.ajustesAbiertos, 1);
    // The app cannot read the system choice back: the row keeps «Permitir».
    expect(find.text('Permitir'), findsOneWidget);
  });

  testWidgets('en una pestaña de iPhone primero pide agregarla a la pantalla '
      'de inicio', (tester) async {
    final permiso = PermisoFalso(activas: false, ajustesDeSonido: false);
    await abrirConAlertas(
      tester,
      ubicacion: Rutas.configListo,
      alertas: AlertasRepositorioFalso(),
      permiso: permiso,
      overrides: [
        entornoNavegadorProvider.overrideWithValue(
          const EntornoNavegador(esWeb: true, esIos: true),
        ),
      ],
    );
    await verHasta(tester, find.byType(AvisoInstalarApp));
    expect(find.byType(AvisoInstalarApp), findsOneWidget);
    await verHasta(tester, find.text('Notificaciones'));
    expect(find.text('Permitir'), findsNothing);
    expect(find.text('Sonar en silencio'), findsNothing);
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
    expect(find.text('Aunque el celular esté en silencio'), findsOneWidget);
    await tocar(tester, find.text('Permitir'));
    expect(permiso.ajustesAbiertos, 1);
  });
}
