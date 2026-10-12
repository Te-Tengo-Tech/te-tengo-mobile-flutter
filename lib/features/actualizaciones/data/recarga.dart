/// Reloading the web app with its new build (CA-43.4). The Android and iOS builds get an inert
/// version.
library;

export 'recarga_otra.dart' if (dart.library.js_interop) 'recarga_web.dart';
