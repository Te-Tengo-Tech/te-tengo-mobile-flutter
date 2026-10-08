import 'package:firebase_core/firebase_core.dart';

/// Firebase web app config and the Web Push (VAPID) key, given at build time (docs/WEB_PWA.md):
///
/// ```
/// flutter build web --dart-define-from-file=$HOME/.config/te-tengo/firebase-web.env
/// ```
///
/// The define names are the keys of that `.env` file (Firebase console › Project settings › Your
/// apps › «Te Tengo Web»). None of them is a secret, but none is committed either: without them push
/// is unavailable on the web and everything else works.
class ConfiguracionFirebaseWeb {
  const ConfiguracionFirebaseWeb({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.vapidKey,
    this.authDomain = '',
    this.storageBucket = '',
    this.measurementId = '',
  });

  /// The `--dart-define`s of this build.
  static const deCompilacion = ConfiguracionFirebaseWeb(
    apiKey: String.fromEnvironment('TT_FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('TT_FIREBASE_WEB_APP_ID'),
    messagingSenderId: String.fromEnvironment(
      'TT_FIREBASE_WEB_MESSAGING_SENDER_ID',
    ),
    projectId: String.fromEnvironment('TT_FIREBASE_WEB_PROJECT_ID'),
    authDomain: String.fromEnvironment('TT_FIREBASE_WEB_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('TT_FIREBASE_WEB_STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('TT_FIREBASE_WEB_MEASUREMENT_ID'),
    vapidKey: String.fromEnvironment('TT_FCM_VAPID_KEY'),
  );

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String authDomain;
  final String storageBucket;

  /// Google Analytics id of the web app; the app does not use Analytics, it is passed as is.
  final String measurementId;

  /// Firebase console › Project settings › Cloud Messaging › Web Push certificates › Key pair.
  final String vapidKey;

  /// FCM web push needs these five; the others are optional.
  bool get completa => [
    apiKey,
    appId,
    messagingSenderId,
    projectId,
    vapidKey,
  ].every((v) => v.isNotEmpty);

  FirebaseOptions? get opciones => completa
      ? FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          authDomain: authDomain.isEmpty ? null : authDomain,
          storageBucket: storageBucket.isEmpty ? null : storageBucket,
          measurementId: measurementId.isEmpty ? null : measurementId,
        )
      : null;

  /// The service worker, relative to the base href so it works under a sub-path. The worker is a
  /// static file, so it reads the Firebase config from its own URL; without the config it only
  /// caches the app.
  String get urlTrabajador => Uri(
    path: 'firebase-messaging-sw.js',
    queryParameters: completa
        ? {
            'apiKey': apiKey,
            'appId': appId,
            'messagingSenderId': messagingSenderId,
            'projectId': projectId,
            if (authDomain.isNotEmpty) 'authDomain': authDomain,
            if (storageBucket.isNotEmpty) 'storageBucket': storageBucket,
          }
        : null,
  ).toString();
}
