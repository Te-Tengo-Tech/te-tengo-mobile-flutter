/// Browser APIs the web app needs (service worker, notification permission, pushes tapped,
/// downloads, full screen of the event clip). The Android and iOS builds get inert versions.
library;

export 'navegador_otro.dart' if (dart.library.js_interop) 'navegador_web.dart';
