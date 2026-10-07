/// URL del backend. Se define al compilar: `flutter run --dart-define=TT_API_URL=https://...`.
/// Por defecto apunta al backend local visto desde el emulador de Android.
const urlApi = String.fromEnvironment(
  'TT_API_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

/// Versión de la API (versionado por cabecera del backend).
const versionApi = '1';
