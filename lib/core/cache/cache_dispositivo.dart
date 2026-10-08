/// The cache of this device: drift's SQLite file on Android and iOS, `localStorage` in the browser.
library;

export 'cache_dispositivo_io.dart'
    if (dart.library.js_interop) 'cache_dispositivo_web.dart';
