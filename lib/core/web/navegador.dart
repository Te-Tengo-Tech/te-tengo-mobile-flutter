/// Browser APIs the web app needs (service worker, notification permission, pushes tapped,
/// downloads). The Android and iOS builds get inert versions.
library;

export 'navegador_otro.dart' if (dart.library.js_interop) 'navegador_web.dart';
