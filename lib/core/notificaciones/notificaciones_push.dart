import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mensaje_push.dart';

/// Push notifications of the phone (FCM on Android, APNs on iOS through FCM).
abstract interface class NotificacionesPush {
  /// Asks the system for permission to show notifications (Android 13+ and iOS). Returns whether
  /// they are allowed; false when push is unavailable, without asking.
  Future<bool> pedirPermiso();

  /// Token to register with `POST /api/dispositivos`; null when push is unavailable.
  Future<String?> token();

  /// `ANDROID` or `IOS`.
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
/// again later (when the app resumes or the permission is granted).
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
    debugPrint('Sin token de push: $e');
    return null;
  }
}

/// `firebase_messaging` implementation. It needs `android/app/google-services.json` and
/// `ios/Runner/GoogleService-Info.plist` (docs/FIREBASE.md); when Firebase cannot start, it behaves
/// as [NotificacionesPushInactivas].
class NotificacionesFirebase implements NotificacionesPush {
  Future<FirebaseMessaging?>? _mensajeria;

  Future<FirebaseMessaging?> _iniciar() => _mensajeria ??= () async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      return FirebaseMessaging.instance;
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
  String get plataforma => Platform.isIOS ? 'IOS' : 'ANDROID';

  @override
  Future<bool> pedirPermiso() async {
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
    final m = await _iniciar();
    if (m == null) return null;
    return obtenerTokenPush(
      esIos: Platform.isIOS,
      tokenApns: m.getAPNSToken,
      tokenFcm: m.getToken,
    );
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

  @override
  Stream<MensajePush> get abiertas => Stream.fromFuture(_iniciar()).asyncExpand(
    (m) => m == null
        ? const Stream<MensajePush>.empty()
        : _mensajes(FirebaseMessaging.onMessageOpenedApp),
  );

  @override
  Future<MensajePush?> inicial() async {
    final m = await _iniciar();
    final mensaje = await m?.getInitialMessage();
    return mensaje == null ? null : MensajePush.desdeDatos(mensaje.data);
  }
}

final notificacionesPushProvider = Provider<NotificacionesPush>(
  (ref) => NotificacionesFirebase(),
);
