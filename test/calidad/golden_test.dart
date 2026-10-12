import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pantallas.dart';

/// Loads a font of the app from its file so the screenshots show the real typography.
Future<void> _cargarFuente(String familia, String archivo) async {
  final bytes = File(archivo).readAsBytesSync();
  final cargador = FontLoader(familia)
    ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await cargador.load();
}

String _archivo(String nombre) {
  const sinTilde = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n'};
  final limpio = nombre
      .split('')
      .map((c) => sinTilde[c] ?? c)
      .join()
      .replaceAll(' ', '_');
  return 'goldens/$limpio.png';
}

/// A screenshot of each main screen at phone size (390 × 844), compared against
/// `test/calidad/goldens/`. Regenerate with `flutter test --update-goldens test/calidad`.
void main() {
  setUpAll(() async {
    await _cargarFuente('Poppins', 'assets/fonts/Poppins-Regular.ttf');
    await _cargarFuente('Poppins', 'assets/fonts/Poppins-Medium.ttf');
    await _cargarFuente('Poppins', 'assets/fonts/Poppins-SemiBold.ttf');
    await _cargarFuente('Poppins', 'assets/fonts/Poppins-Bold.ttf');
  });

  // The profiles and settings in dark mode too (the prototype's screen 243 is a member's detail).
  for (final p in pantallasPerfilesOscuras) {
    testWidgets('captura en oscuro: ${p.nombre}', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await abrirPantalla(tester, p);
      await expectLater(
        find.byType(WidgetsApp).first,
        matchesGoldenFile(_archivo('${p.nombre} oscuro')),
      );
    });
  }

  for (final p in pantallasPrincipales) {
    testWidgets('captura: ${p.nombre}', (tester) async {
      await abrirPantalla(tester, p);
      await expectLater(
        find.byType(WidgetsApp).first,
        matchesGoldenFile(_archivo(p.nombre)),
      );
    });
  }
}
