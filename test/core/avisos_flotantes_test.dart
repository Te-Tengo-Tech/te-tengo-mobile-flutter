import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/core/ui/avisos_flotantes.dart';

import '../apoyo/app_de_prueba.dart';

const _toast = AvisoFlotante(titulo: 'Cambios guardados');

void main() {
  late ProviderContainer c;

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(pantallaDePrueba(const Scaffold()));
    c = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
  }

  Future<void> mostrar(WidgetTester tester, AvisoFlotante aviso) async {
    c.read(avisoFlotanteProvider.notifier).mostrar(aviso);
    await tester.pumpAndSettle();
    expect(find.text(aviso.titulo), findsOneWidget);
  }

  /// The semantics node of the notice titled [titulo].
  SemanticsNode nodo(WidgetTester tester, String titulo) =>
      tester.getSemantics(find.text(titulo));

  void accion(SemanticsNode nodo, SemanticsAction accion, [Object? datos]) =>
      RendererBinding.instance.renderViews.first.owner!.semanticsOwner!
          .performAction(nodo.id, accion, datos);

  group('deslizar para cerrar', () {
    for (final (nombre, desplazamiento) in [
      ('a la derecha', const Offset(400, 0)),
      ('a la izquierda', const Offset(-400, 0)),
      ('hacia arriba', const Offset(0, -200)),
    ]) {
      testWidgets('el aviso se cierra al deslizarlo $nombre', (tester) async {
        await abrir(tester);
        await mostrar(tester, _toast);
        await tester.drag(find.text(_toast.titulo), desplazamiento);
        await tester.pumpAndSettle();
        expect(find.text(_toast.titulo), findsNothing);
        expect(c.read(avisoFlotanteProvider), isNull);
        // The cancelled timeout does nothing later, and nothing is rebuilt after the swipe.
        await tester.pump(_toast.duracion);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('el aviso de la app también se cierra deslizándolo', (
      tester,
    ) async {
      var tocado = false;
      await abrir(tester);
      await mostrar(
        tester,
        AvisoFlotante(
          tipo: TipoFlotante.enApp,
          titulo: 'Rosa se levantó',
          alTocar: () => tocado = true,
        ),
      );
      await tester.drag(find.text('Rosa se levantó'), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Rosa se levantó'), findsNothing);
      // Swiping is not a tap: the notice's action does not run.
      expect(tocado, isFalse);
    });

    testWidgets('un deslizamiento corto no lo cierra', (tester) async {
      await abrir(tester);
      await mostrar(tester, _toast);
      await tester.drag(find.text(_toast.titulo), const Offset(30, 0));
      await tester.pumpAndSettle();
      expect(find.text(_toast.titulo), findsOneWidget);
    });

    testWidgets('cerrar un aviso que ya fue reemplazado no cierra el nuevo', (
      tester,
    ) async {
      await abrir(tester);
      const primero = AvisoFlotante(titulo: 'Primero');
      const segundo = AvisoFlotante(titulo: 'Segundo');
      await mostrar(tester, primero);
      await mostrar(tester, segundo);
      c.read(avisoFlotanteProvider.notifier).cerrarSi(primero);
      await tester.pumpAndSettle();
      expect(find.text('Segundo'), findsOneWidget);
    });

    testWidgets('sin animaciones también se cierra al deslizarlo', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: pantallaDePrueba(const Scaffold()),
        ),
      );
      c = ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
      await mostrar(tester, _toast);
      await tester.drag(find.text(_toast.titulo), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(find.text(_toast.titulo), findsNothing);
    });
  });

  testWidgets('sin tocarlo, el aviso se cierra solo', (tester) async {
    await abrir(tester);
    await mostrar(tester, _toast);
    await tester.pump(const Duration(milliseconds: 3000));
    expect(find.text(_toast.titulo), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text(_toast.titulo), findsNothing);
  });

  testWidgets('tocar el aviso de la app hace su acción y lo cierra', (
    tester,
  ) async {
    var tocado = 0;
    await abrir(tester);
    await mostrar(
      tester,
      AvisoFlotante(
        tipo: TipoFlotante.enApp,
        titulo: 'La cámara de la Sala se desconectó',
        alTocar: () => tocado++,
      ),
    );
    await tester.tap(find.text('La cámara de la Sala se desconectó'));
    await tester.pumpAndSettle();
    expect(tocado, 1);
    expect(find.text('La cámara de la Sala se desconectó'), findsNothing);
  });

  group('lector de pantalla', () {
    for (final tipo in TipoFlotante.values) {
      testWidgets('el aviso (${tipo.name}) ofrece cerrarlo', (tester) async {
        final semantica = tester.ensureSemantics();
        await abrir(tester);
        await mostrar(tester, AvisoFlotante(tipo: tipo, titulo: 'Aviso'));
        expect(
          nodo(tester, 'Aviso'),
          isSemantics(
            hasDismissAction: true,
            customActions: [accionCerrarAviso],
          ),
        );
        accion(nodo(tester, 'Aviso'), SemanticsAction.dismiss);
        await tester.pumpAndSettle();
        expect(find.text('Aviso'), findsNothing);
        semantica.dispose();
      });
    }

    testWidgets('«Cerrar aviso» lo cierra', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester);
      await mostrar(tester, _toast);
      accion(
        nodo(tester, _toast.titulo),
        SemanticsAction.customAction,
        CustomSemanticsAction.getIdentifier(accionCerrarAviso),
      );
      await tester.pumpAndSettle();
      expect(find.text(_toast.titulo), findsNothing);
      semantica.dispose();
    });
  });
}
