import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mensaje_push.dart';

/// Push notifications of the phone (FCM on Android, APNs on iOS through FCM).
abstract interface class NotificacionesPush {
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

/// `firebase_messaging` implementation. It needs `google-services.json` and
/// `GoogleService-Info.plist`; when Firebase cannot start, it behaves as [NotificacionesPushInactivas].
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
  Future<String?> token() async {
    final m = await _iniciar();
    if (m == null) return null;
    try {
      return await m.getToken();
    } on Object catch (e) {
      debugPrint('Sin token de push: $e');
      return null;
    }
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
