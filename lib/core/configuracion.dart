/// Backend URL, set at build time: `flutter run --dart-define=TT_API_URL=https://...`.
/// Defaults to the local backend as seen from the Android emulator.
const urlApi = String.fromEnvironment(
  'TT_API_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

/// API version (the backend uses header versioning).
const versionApi = '1';
