import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Asks the browser for the app's service worker again (`web/firebase-messaging-sw.js`, which
/// skips waiting and fetches the app network first), then reloads the page: every file is
/// revalidated (`Cache-Control: no-cache`, `deploy/pwa/_headers`), so the new build loads.
Future<void> recargarConVersionNueva() async {
  final navegador = web.window.navigator;
  if (navegador.has('serviceWorker')) {
    try {
      final registro = await navegador.serviceWorker.getRegistration().toDart;
      if (registro != null) await registro.update().toDart;
    } on Object catch (e) {
      debugPrint('El service worker no se actualizó: $e');
    }
  }
  web.window.location.reload();
}
