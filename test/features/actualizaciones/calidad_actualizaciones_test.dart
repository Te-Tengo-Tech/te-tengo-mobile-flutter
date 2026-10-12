import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:te_tengo/app/rutas.dart';
import 'package:te_tengo/features/actualizaciones/presentation/rutas_actualizaciones.dart';
import 'package:te_tengo/features/pcs/domain/pc.dart';

import '../pcs/pcs_falso.dart';
import 'actualizaciones_falso.dart';
import 'app_actualizaciones.dart';

/// The US-43 screens in dark mode and with the text at 200 % (screens 391 to 398): contrast,
/// 44 px targets, labels and no overflow.
void main() {
  final nueva = VersionesFalsas(versionesEn('0.6.0', captura: '0.5.1'));
  final pantallas = <(String, String, List<Override>)>[
    (
      'aviso de versión nueva',
      Rutas.inicio,
      overridesActualizacion(versiones: nueva),
    ),
    (
      'acerca de',
      RutasActualizaciones.acercaDe,
      overridesActualizacion(versiones: nueva),
    ),
    (
      'versión obligatoria',
      Rutas.inicio,
      overridesActualizacion(
        info: infoPlay,
        versiones: VersionesFalsas(versionesEn('0.6.0', minima: '0.6.0')),
      ),
    ),
    (
      'permiso para instalar',
      RutasActualizaciones.permiso,
      overridesActualizacion(versiones: nueva),
    ),
    (
      'detalle de la PC',
      Rutas.pc('pc-sala'),
      overridesActualizacion(versiones: nueva),
    ),
  ];
  List<Pc> pcs() => [pcSalaRosa()];

  for (final (nombre, ruta, overrides) in pantallas) {
    testWidgets('$nombre: modo oscuro, contraste y áreas táctiles', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final semantica = tester.ensureSemantics();
      await abrirApp(tester, ruta, pcs: pcs(), actualizacion: overrides);
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantica.dispose();
    });

    testWidgets('$nombre: texto al 200 % sin desbordes', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await abrirApp(tester, ruta, pcs: pcs(), actualizacion: overrides);
      expect(tester.takeException(), isNull);
    });
  }
}
