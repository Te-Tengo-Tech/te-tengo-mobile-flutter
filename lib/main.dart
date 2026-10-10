import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/cache/cache_dispositivo.dart';
import 'core/cache/cache_local.dart';
import 'core/notificaciones/firebase_web.dart';
import 'core/sesion/almacen_sesion.dart';
import 'core/web/navegador.dart';
import 'features/ajustes/data/apariencia.dart';

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
  // The session and this phone's appearance are read before the first frame: the router guards
  // never see a loading state and the app never paints the other theme first (the native splash
  // and the PWA's loading page are brand purple in both themes). The local database opened here
  // is the app's for its whole life.
  final almacen = AlmacenSesionSeguro();
  final cache = crearCacheDispositivo();
  final (_, apariencia) = await (
    almacen.cargar(),
    cargarApariencia(cache),
  ).wait;
  runApp(
    ProviderScope(
      // Backend errors are shown with their message; the user retries explicitly.
      retry: (_, _) => null,
      overrides: [
        almacenSesionProvider.overrideWithValue(almacen),
        cacheLocalProvider.overrideWithValue(cache),
        aparienciaInicialProvider.overrideWithValue(apariencia),
      ],
      child: const TeTengoApp(),
    ),
  );
}
