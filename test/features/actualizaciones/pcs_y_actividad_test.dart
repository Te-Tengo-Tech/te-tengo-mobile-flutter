import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/features/actividad/domain/actividad.dart';
import 'package:te_tengo/features/actividad/presentation/pantalla_actividad.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';
import 'package:te_tengo/core/ui/ayuda.dart';

import 'package:te_tengo/features/hogar/data/hogar_repositorio.dart';

import '../../apoyo/app_de_prueba.dart';
import '../../apoyo/datos.dart';
import '../actividad/actividad_falso.dart';
import '../hogar/hogar_falso.dart';
import '../pcs/pcs_falso.dart';
import 'actualizaciones_falso.dart';
import 'app_actualizaciones.dart';

Pc pcCocina({bool? auto, String version = '0.4.3'}) {
  final base = pcSalaRosa();
  return Pc(
    id: 'pc-cocina',
    nombre: 'Cocina-Rosa',
    sistemaOperativo: 'Windows 10 Pro',
    versionAgente: version,
    actualizacionAutomatica: auto,
    estado: base.estado,
    ultimaSenal: base.ultimaSenal,
    vinculadaEn: base.vinculadaEn,
    vinculadaPor: base.vinculadaPor,
    camaras: const [],
  );
}

void main() {
  test('Pc lee actualizacionAutomatica (contrato §9)', () {
    Pc leer(Object? valor) => Pc.desdeJson({
      'id': 'p',
      'nombre': 'Sala-Rosa',
      'estadoConexion': 'EN_LINEA',
      'actualizacionAutomatica': valor,
    });
    expect(leer(true).actualizacionAutomatica, isTrue);
    expect(leer(false).actualizacionAutomatica, isFalse);
    expect(leer(null).actualizacionAutomatica, isNull);
  });

  group('PC con una versión anterior (CA-43.7)', () {
    final overrides = overridesActualizacion(
      versiones: VersionesFalsas(versionesEn('0.5.0', captura: '0.5.0')),
    );

    testWidgets('Cámaras: «Versión anterior (0.4.3)»', (tester) async {
      await abrirApp(
        tester,
        Rutas.pcs,
        pcs: [pcSalaRosa(), pcCocina()],
        actualizacion: overrides,
      );
      await verHastaTexto(tester, 'Versión anterior (0.4.3)');
      expect(find.text('Versión anterior (0.4.3)'), findsOneWidget);
    });

    testWidgets('se actualizará sola', (tester) async {
      await abrirApp(
        tester,
        Rutas.pc('pc-cocina'),
        pcs: [pcCocina(auto: true)],
        actualizacion: overrides,
      );
      expect(
        find.textContaining(
          'Te Tengo Captura 0.4.3 · versión anterior',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Versión anterior (0.4.3)'), findsOneWidget);
      expect(find.text('Se actualizará sola.'), findsOneWidget);
      expect(find.textContaining('Pide a quien'), findsNothing);
    });

    testWidgets('pide a quien está en la casa que la actualice', (
      tester,
    ) async {
      await abrirApp(
        tester,
        Rutas.pc('pc-cocina'),
        pcs: [pcCocina(auto: false)],
        actualizacion: overrides,
      );
      expect(
        find.textContaining(
          'Pide a quien está en la casa que la actualice.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.byType(AyudaInfo), findsOneWidget);
      expect(find.text('Se actualizará sola.'), findsNothing);
    });

    testWidgets('si la PC nunca lo dijo, solo el título', (tester) async {
      await abrirApp(
        tester,
        Rutas.pc('pc-cocina'),
        pcs: [pcCocina()],
        actualizacion: overrides,
      );
      expect(find.text('Versión anterior (0.4.3)'), findsOneWidget);
      expect(find.text('Se actualizará sola.'), findsNothing);
      expect(
        find.textContaining('Pide a quien', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('al día no dice nada', (tester) async {
      await abrirApp(
        tester,
        Rutas.pc('pc-cocina'),
        pcs: [pcCocina(version: '0.5.0', auto: false)],
        actualizacion: overrides,
      );
      expect(
        find.textContaining('ersión anterior', findRichText: true),
        findsNothing,
      );
    });
  });

  group('Actividad (US-33, US-43)', () {
    final actualizada = actividad(
      'ac4u',
      'PC_ACTUALIZADA',
      DateTime(2026, 9, 22, 3, 10),
      actor: TipoActor.pc,
      pcId: 'pc-sala',
      pc: 'Sala-Rosa',
      objeto: 'Te Tengo Captura',
      antes: '0.4.3',
      despues: '0.5.0',
    );

    test('«Sala-Rosa se actualizó a 0.5.0» con su detalle', () {
      expect(
        actualizada.frase(adultoMayor: 'Rosa'),
        'Sala-Rosa se actualizó a 0.5.0',
      );
      expect(actualizada.quien, 'Te Tengo Captura');
      expect(actualizada.desde, 'PC Sala-Rosa');
      expect(actualizada.antesYDespues, ('0.4.3', '0.5.0'));
    });

    test('actualización automática activada y desactivada', () {
      Actividad de(String tipo) => actividad(
        'x',
        tipo,
        DateTime(2026, 9, 22),
        actor: TipoActor.pc,
        pc: 'Sala-Rosa',
        objeto: 'Actualizar automáticamente',
      );
      expect(
        de('ACTUALIZACION_AUTOMATICA_ACTIVADA').frase(adultoMayor: 'Rosa'),
        'Desde la PC Sala-Rosa: se activó la actualización automática',
      );
      expect(
        de('ACTUALIZACION_AUTOMATICA_DESACTIVADA').frase(adultoMayor: 'Rosa'),
        'Desde la PC Sala-Rosa: se desactivó la actualización automática',
      );
    });

    testWidgets('el detalle dice quién, antes y después', (tester) async {
      usarTelefono(tester);
      await tester.pumpWidget(
        pantallaDePrueba(
          Scaffold(body: HojaActividad(actualizada)),
          sesion: sesionTitular,
          overrides: [
            hogarRepositorioProvider.overrideWithValue(HogarRepositorioFalso()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sala-Rosa se actualizó a 0.5.0'), findsOneWidget);
      expect(find.text('Te Tengo Captura'), findsOneWidget);
      expect(find.text('PC Sala-Rosa'), findsOneWidget);
      expect(find.text('0.4.3'), findsOneWidget);
      expect(find.text('0.5.0'), findsOneWidget);
    });
  });
}

Future<void> verHastaTexto(WidgetTester tester, String t) async {
  final f = find.text(t);
  if (f.evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find.byType(Scrollable).hitTestable().first,
  );
}
