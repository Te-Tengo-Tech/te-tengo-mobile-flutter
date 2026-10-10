import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/ui/iconos.dart';
import 'package:te_tengo/core/ui/lista.dart';
import 'package:te_tengo/core/ui/plegable.dart';

import '../apoyo/app_de_prueba.dart';

void main() {
  Future<void> abrir(WidgetTester tester, Widget hijo) async {
    usarTelefono(tester);
    await tester.pumpWidget(
      pantallaDePrueba(Scaffold(body: ListView(children: [hijo]))),
    );
    await tester.pumpAndSettle();
  }

  group('FilaPlegable', () {
    testWidgets('el resumen da paso al texto completo al abrirla', (
      tester,
    ) async {
      await abrir(
        tester,
        const ListaTarjeta(
          children: [
            FilaPlegable(
              icono: Ico.info,
              titulo: 'Más detalles',
              resumen: 'Dirección, teléfono, aviso y registro',
              child: Text('Jr. Los Pinos 482'),
            ),
          ],
        ),
      );
      expect(
        find.text('Dirección, teléfono, aviso y registro'),
        findsOneWidget,
      );
      expect(find.text('Jr. Los Pinos 482'), findsNothing);
      await tester.tap(find.text('Más detalles'));
      await tester.pumpAndSettle();
      expect(find.text('Dirección, teléfono, aviso y registro'), findsNothing);
      expect(find.text('Jr. Los Pinos 482'), findsOneWidget);
      await tester.tap(find.text('Más detalles'));
      await tester.pumpAndSettle();
      expect(find.text('Jr. Los Pinos 482'), findsNothing);
    });

    testWidgets('puede empezar abierta', (tester) async {
      await abrir(
        tester,
        const FilaPlegable(
          titulo: 'Clip del evento',
          resumen: '12 s, antes y después',
          abierta: true,
          child: Text('clip'),
        ),
      );
      expect(find.text('clip'), findsOneWidget);
      expect(find.text('12 s, antes y después'), findsNothing);
    });

    testWidgets('el lector la anuncia como botón con su estado', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await abrir(
        tester,
        const FilaPlegable(
          icono: Ico.clock,
          titulo: 'Registro del evento',
          resumen: '4 momentos',
          child: Text('10:42 Caída detectada'),
        ),
      );
      final nodo = find.bySemanticsLabel(RegExp('Registro del evento'));
      expect(
        tester.getSemantics(nodo),
        matchesSemantics(
          label: 'Registro del evento\n4 momentos',
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      await tester.tap(find.text('Registro del evento'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(nodo),
        isSemantics(isButton: true, hasExpandedState: true, isExpanded: true),
      );
      // The whole row is the target.
      expect(
        tester.getSize(find.byType(InkWell)).height,
        greaterThanOrEqualTo(48),
      );
      semantica.dispose();
    });
  });

  group('VerMas', () {
    testWidgets('muestra el detalle dentro de la tarjeta al tocarlo', (
      tester,
    ) async {
      await abrir(
        tester,
        const VerMas(
          etiqueta: 'Datos de la instalación',
          child: Text('PC de la casa'),
        ),
      );
      expect(find.text('PC de la casa'), findsNothing);
      expect(
        tester.getSize(find.byType(InkWell)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Datos de la instalación'));
      await tester.pumpAndSettle();
      expect(find.text('PC de la casa'), findsOneWidget);
    });
  });
}
