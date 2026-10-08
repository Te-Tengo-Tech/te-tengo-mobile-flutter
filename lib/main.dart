import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/notificaciones/firebase_web.dart';
import 'core/sesion/almacen_sesion.dart';
import 'core/web/navegador.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // The PWA's only service worker: offline cache and, with the Firebase defines, web push.
    unawaited(
      registrarTrabajadorServicio(
        ConfiguracionFirebaseWeb.deCompilacion.urlTrabajador,
      ),
    );
  }
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
