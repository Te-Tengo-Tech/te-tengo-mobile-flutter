import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/tema/tema.dart';
import 'package:te_tengo/core/ui/ayuda.dart';

const _texto = 'Nadie puede borrar ni cambiar este registro.';

Widget _pantalla({bool largo = false}) => MaterialApp(
  theme: temaTeTengo(),
  home: Scaffold(
    appBar: AppBar(
      title: const Text('Actividad'),
      actions: const [AyudaInfo(texto: _texto, tema: 'registro de actividad')],
    ),
    body: ListView(
      children: [
        const Text('Arriba'),
        SizedBox(height: largo ? 3000 : 200),
        const Text('Fuera'),
      ],
    ),
  ),
);

void main() {
  testWidgets('es un botón de 48 dp con nombre y estado para lectores de '
      'pantalla', (tester) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(_pantalla());
    final boton = find.bySemanticsLabel(
      'Más información: registro de actividad',
    );
    expect(
      tester.getSemantics(boton),
      isSemantics(
        label: 'Más información: registro de actividad',
        isButton: true,
        hasExpandedState: true,
        isExpanded: false,
        hasTapAction: true,
      ),
    );
    expect(tester.getSize(find.byType(AyudaInfo)), const Size(48, 48));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await tester.tap(find.byType(AyudaInfo));
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsOneWidget);
    expect(
      tester.getSemantics(boton),
      isSemantics(isExpanded: true, hasExpandedState: true),
    );
    // The card is a live region, so its text is read when it appears.
    expect(
      tester.getSemantics(find.text(_texto)),
      isSemantics(isLiveRegion: true),
    );
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantica.dispose();
  });

  testWidgets('un toque la abre y otro la cierra', (tester) async {
    await tester.pumpWidget(_pantalla());
    expect(find.text(_texto), findsNothing);
    await tester.tap(find.byType(AyudaInfo));
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsOneWidget);
    // Tapping the card itself keeps it open.
    await tester.tap(find.text(_texto));
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsOneWidget);
    await tester.tap(find.byType(AyudaInfo));
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsNothing);
  });

  testWidgets('un toque fuera la cierra', (tester) async {
    await tester.pumpWidget(_pantalla());
    await tester.tap(find.byType(AyudaInfo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arriba'));
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsNothing);
  });

  testWidgets('Escape la cierra', (tester) async {
    await tester.pumpWidget(_pantalla());
    await tester.tap(find.byType(AyudaInfo));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsNothing);
  });

  testWidgets('desplazar la pantalla la cierra', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: temaTeTengo(),
        home: Scaffold(
          body: ListView(
            children: const [
              AyudaInfo(texto: _texto, tema: 'privacidad'),
              SizedBox(height: 3000),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(AyudaInfo));
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -40));
    await tester.pumpAndSettle();
    expect(find.text(_texto), findsNothing);
  });

  testWidgets('no se sale de la pantalla, también con el texto al 200 %', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_pantalla());
    await tester.tap(find.byType(AyudaInfo));
    await tester.pumpAndSettle();
    final globo = tester.getRect(find.text(_texto));
    expect(globo.left, greaterThanOrEqualTo(8));
    expect(globo.right, lessThanOrEqualTo(390 - 8));
    expect(tester.takeException(), isNull);
  });
}
