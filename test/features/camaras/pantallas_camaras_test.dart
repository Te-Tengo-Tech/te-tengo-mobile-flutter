import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/tema/tema.dart';
import 'package:te_tengo/features/camaras/data/camaras_repositorio.dart';
import 'package:te_tengo/features/camaras/domain/camara.dart';
import 'package:te_tengo/features/camaras/presentation/pantalla_camaras.dart';
import 'package:te_tengo/features/camaras/presentation/pantalla_nombre_habitacion.dart';

import 'repositorio_falso.dart';

Widget _app(Widget pantalla, CamarasRepositorio repositorio) => ProviderScope(
  overrides: [camarasRepositorioProvider.overrideWithValue(repositorio)],
  child: MaterialApp(theme: temaTeTengo(), home: pantalla),
);

void main() {
  testWidgets('muestra cada cámara con su estado en texto, no solo en color', (
    tester,
  ) async {
    final repo = CamarasRepositorioFalso([
      const Camara(
        id: '1',
        nombreHabitacion: 'Sala',
        estado: EstadoConexion.enLinea,
      ),
      const Camara(
        id: '2',
        nombreHabitacion: 'Dormitorio',
        estado: EstadoConexion.desconectada,
      ),
    ]);
    await tester.pumpWidget(_app(const PantallaCamaras(), repo));
    await tester.pumpAndSettle();
    expect(find.text('Sala'), findsOneWidget);
    expect(find.text('En línea'), findsOneWidget);
    expect(find.text('Desconectada'), findsOneWidget);
  });

  testWidgets('CA-06.3: no permite guardar el nombre vacío', (tester) async {
    final repo = CamarasRepositorioFalso([]);
    await tester.pumpWidget(
      _app(
        const PantallaNombreHabitacion(camaraId: '1', nombreActual: 'Sala'),
        repo,
      ),
    );
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    expect(find.text('Escribe el nombre de la habitación.'), findsOneWidget);
    expect(repo.renombradas, isEmpty);
  });

  testWidgets(
    'las sugerencias completan el nombre y muestran la vista previa',
    (tester) async {
      final repo = CamarasRepositorioFalso([]);
      await tester.pumpWidget(
        _app(
          const PantallaNombreHabitacion(camaraId: '1', nombreActual: ''),
          repo,
        ),
      );
      await tester.tap(find.text('Dormitorio'));
      await tester.pump();
      expect(find.text('Caída en Dormitorio'), findsOneWidget);
    },
  );
}
