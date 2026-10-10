import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../web/navegador.dart';
import 'firebase_web.dart';
import 'mensaje_push.dart';

/// Push notifications of the phone (FCM on Android, APNs on iOS through FCM, Web Push through FCM in
/// the browser).
abstract interface class NotificacionesPush {
  /// Asks the system for permission to show notifications (Android 13+ and iOS). Returns whether
  /// they are allowed; false when push is unavailable, without asking.
  Future<bool> pedirPermiso();

  /// Token to register with `POST /api/dispositivos`; null when push is unavailable (no Firebase,
  /// no permission yet, iOS still waiting for APNs). Throws when Firebase fails to issue one.
  Future<String?> token();

  /// Deletes this phone's token, so the next [token] is a new one: the backend said the push service
  /// no longer accepts the current one (contract §7, `activo: false`).
  Future<void> borrarToken();

  /// `ANDROID`, `IOS` or `WEB` (contract §7).
  String get plataforma;

  Stream<String> get tokenRenovado;

  /// Pushes received while the app is in the foreground.
  Stream<MensajePush> get recibidas;

  /// Pushes the user tapped while the app was in the background.
  Stream<MensajePush> get abiertas;

  /// The push that launched the app from a terminated state, if any.
  Future<MensajePush?> inicial();
}

/// Without a Firebase project (docs/BLOCKERS.md) push is unavailable: no token, no messages.
class NotificacionesPushInactivas implements NotificacionesPush {
  const NotificacionesPushInactivas();

  @override
  Future<bool> pedirPermiso() async => false;

  @override
  Future<String?> token() async => null;

  @override
  Future<void> borrarToken() async {}

  @override
  String get plataforma => 'ANDROID';

  @override
  Stream<String> get tokenRenovado => const Stream.empty();

  @override
  Stream<MensajePush> get recibidas => const Stream.empty();

  @override
  Stream<MensajePush> get abiertas => const Stream.empty();

  @override
  Future<MensajePush?> inicial() async => null;
}

/// FCM token of this phone. On iOS, FCM can only issue it once APNs has given the app its own token,
/// which arrives some time after launch (and only after the user allows notifications); until then
/// `getToken` fails with `apns-token-not-set`. So on iOS it first waits for the APNs token, asking up
/// to [intentos] times, [pausa] apart. Returns null when there is no token yet: the caller tries
/// again later (when the app resumes or the permission is granted). Any other failure is thrown, so
/// the caller can tell the family member this phone is not receiving alerts.
Future<String?> obtenerTokenPush({
  required bool esIos,
  required Future<String?> Function() tokenApns,
  required Future<String?> Function() tokenFcm,
  int intentos = 10,
  Duration pausa = const Duration(seconds: 1),
  Future<void> Function(Duration) esperar = Future<void>.delayed,
}) async {
  try {
    if (esIos) {
      String? apns;
      for (var i = 0; apns == null && i < intentos; i++) {
        if (i > 0) await esperar(pausa);
        apns = await tokenApns();
      }
      if (apns == null) {
        debugPrint('Sin token de APNs todavía: el registro se reintentará.');
        return null;
      }
    }
    return await tokenFcm();
  } on Object catch (e) {
    if ('$e'.contains('apns-token-not-set')) {
      debugPrint('Sin token de APNs todavía: el registro se reintentará.');
      return null;
    }
    debugPrint('Sin token de push: $e');
    rethrow;
  }
}

/// `firebase_messaging` implementation. It needs `android/app/google-services.json` and
/// `ios/Runner/GoogleService-Info.plist` (docs/FIREBASE.md), or on the web the `--dart-define`s of
/// [ConfiguracionFirebaseWeb] and a browser with Web Push (docs/WEB_PWA.md); when Firebase cannot
/// start, it behaves as [NotificacionesPushInactivas].
class NotificacionesFirebase implements NotificacionesPush {
  NotificacionesFirebase({
    this.web = ConfiguracionFirebaseWeb.deCompilacion,
    this.esWeb = kIsWeb,
  });

  final ConfiguracionFirebaseWeb web;
  final bool esWeb;
  Future<FirebaseMessaging?>? _mensajeria;

  bool get _esIos => !esWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<FirebaseMessaging?> _iniciar() => _mensajeria ??= () async {
    try {
      if (esWeb) {
        final opciones = web.opciones;
        if (opciones == null) {
          debugPrint(
            'Push no disponible: falta la configuración web de Firebase',
          );
          return null;
        }
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(options: opciones);
        }
        // An iPhone Safari tab (not on the home screen) or a browser without Web Push.
        if (!await FirebaseMessaging.instance.isSupported()) {
          debugPrint('Push no disponible en este navegador');
          return null;
        }
        return FirebaseMessaging.instance;
      }
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final mensajeria = FirebaseMessaging.instance;
      if (_esIos) {
        // A fall that arrives with the app open also shows the system banner with its sound, as
        // well as the alert screen.
        await mensajeria.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      return mensajeria;
    } on Object catch (e) {
      debugPrint('Push no disponible: $e');
      return null;
    }
  }();

  static Stream<MensajePush> _mensajes(Stream<RemoteMessage> origen) => origen
      .map((m) => MensajePush.desdeDatos(m.data))
      .where((m) => m != null)
      .cast<MensajePush>();

  @override
  String get plataforma => esWeb
      ? 'WEB'
      : _esIos
      ? 'IOS'
      : 'ANDROID';

  @override
  Future<bool> pedirPermiso() async {
    // The browser prompt first, before any await: Safari only shows it inside a tap.
    if (esWeb) return await pedirPermisoNotificacionesNavegador() == 'granted';
    final m = await _iniciar();
    if (m == null) return false;
    try {
      final ajustes = await m.requestPermission();
      return switch (ajustes.authorizationStatus) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional => true,
        _ => false,
      };
    } on Object catch (e) {
      debugPrint('Sin permiso de notificaciones: $e');
      return false;
    }
  }

  @override
  Future<String?> token() async {
    // On the web, getToken would itself prompt for permission, which Safari refuses outside a tap:
    // the token waits until «Activar notificaciones» was tapped and allowed.
    if (esWeb && permisoNotificacionesNavegador() != 'granted') return null;
    final m = await _iniciar();
    if (m == null) return null;
    return obtenerTokenPush(
      esIos: _esIos,
      tokenApns: m.getAPNSToken,
      tokenFcm: esWeb
          ? () => m.getToken(
              vapidKey: web.vapidKey,
              // The worker lives under the base href (GitHub Pages sub-path), not at the origin
              // root where the Firebase SDK looks by default.
              serviceWorkerScriptPath: web.urlTrabajador,
            )
          : m.getToken,
    );
  }

  @override
  Future<void> borrarToken() async {
    final m = await _iniciar();
    await m?.deleteToken();
  }

  @override
  Stream<String> get tokenRenovado => Stream.fromFuture(
    _iniciar(),
  ).asyncExpand((m) => m == null ? const Stream.empty() : m.onTokenRefresh);

  @override
  Stream<MensajePush> get recibidas =>
      Stream.fromFuture(_iniciar()).asyncExpand(
        (m) => m == null
            ? const Stream<MensajePush>.empty()
            : _mensajes(FirebaseMessaging.onMessage),
      );

  /// On the web, firebase_messaging has no tapped-notification events: the service worker posts
  /// them to the open window instead (web/firebase-messaging-sw.js).
  @override
  Stream<MensajePush> get abiertas => esWeb
      ? pushAbiertasNavegador()
            .map(MensajePush.desdeDatos)
            .where((m) => m != null)
            .cast<MensajePush>()
      : Stream.fromFuture(_iniciar()).asyncExpand(
          (m) => m == null
              ? const Stream<MensajePush>.empty()
              : _mensajes(FirebaseMessaging.onMessageOpenedApp),
        );

  /// On the web, a tap that had to open a new window passes the push in the address (`?tt_push=`).
  @override
  Future<MensajePush?> inicial() async {
    if (esWeb) {
      final datos = tomarPushInicialNavegador();
      return datos == null ? null : MensajePush.desdeDatos(datos);
    }
    final m = await _iniciar();
    final mensaje = await m?.getInitialMessage();
    return mensaje == null ? null : MensajePush.desdeDatos(mensaje.data);
  }
}

final notificacionesPushProvider = Provider<NotificacionesPush>(
  (ref) => NotificacionesFirebase(),
);
