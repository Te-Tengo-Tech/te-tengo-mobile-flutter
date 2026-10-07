import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/features/arranque/pantalla_arranque.dart';

import '../apoyo/app_de_prueba.dart';
import '../apoyo/datos.dart';

void main() {
  testWidgets('el arranque muestra el lema y pasa a la bienvenida sin sesión', (
    tester,
  ) async {
    await tester.pumpWidget(appDePrueba(ubicacion: Rutas.arranque));
    await tester.pump();
    expect(find.byType(PantallaArranque), findsOneWidget);
    expect(find.text(lemaTeTengo), findsOneWidget);
    await tester.pump(PantallaArranque.duracionAnimacion);
    await tester.pumpAndSettle();
    expect(
      find.text('Cuida a tu familiar aunque no estés en casa.'),
      findsOneWidget,
    );
  });

  testWidgets('con una sesión, el arranque pasa al inicio', (tester) async {
    await tester.pumpWidget(
      appDePrueba(ubicacion: Rutas.arranque, sesion: sesionTitular),
    );
    await tester.pump(PantallaArranque.duracionAnimacion);
    await tester.pumpAndSettle();
    expect(find.text('Inicio'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('sin animaciones muestra el cuadro final quieto', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(appDePrueba(ubicacion: Rutas.arranque));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    final lema = tester.widget<Opacity>(
      find.ancestor(of: find.text(lemaTeTengo), matching: find.byType(Opacity)),
    );
    expect(lema.opacity, 1);
    await tester.pump(PantallaArranque.duracionQuieta);
    await tester.pumpAndSettle();
    expect(find.text('Ya tengo una cuenta'), findsOneWidget);
  });

  testWidgets('tocar el arranque lo omite', (tester) async {
    await tester.pumpWidget(appDePrueba(ubicacion: Rutas.arranque));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(PantallaArranque));
    await tester.pumpAndSettle();
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('la barra inferior tiene 4 pestañas y cambia de sección', (
    tester,
  ) async {
    await tester.pumpWidget(
      appDePrueba(ubicacion: Rutas.inicio, sesion: sesionTitular),
    );
    await tester.pumpAndSettle();
    for (final pestana in ['Inicio', 'Historial', 'Familia', 'Ajustes']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(pestana),
        ),
        findsOneWidget,
      );
    }
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
  });

  testWidgets('una sesión sin hogar va a la configuración inicial', (
    tester,
  ) async {
    await tester.pumpWidget(
      appDePrueba(ubicacion: Rutas.inicio, sesion: sesionSinHogar),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Persona cuidada'), findsOneWidget);
  });
}
