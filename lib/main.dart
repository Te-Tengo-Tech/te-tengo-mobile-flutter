import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/sesion/almacen_sesion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The session is read before the first frame, so the router guards never see a loading state.
  final almacen = AlmacenSesionSeguro();
  await almacen.cargar();
  runApp(
    ProviderScope(
      // Backend errors are shown with their message; the user retries explicitly.
      retry: (_, _) => null,
      overrides: [almacenSesionProvider.overrideWithValue(almacen)],
      child: const TeTengoApp(),
    ),
  );
}
