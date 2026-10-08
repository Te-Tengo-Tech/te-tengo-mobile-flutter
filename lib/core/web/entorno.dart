import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navegador.dart';

/// What the browser offers the web app (docs/WEB_PWA.md). In the Android and iOS apps every flag is
/// false.
class EntornoNavegador {
  const EntornoNavegador({
    this.esWeb = false,
    this.esIos = false,
    this.instalada = false,
    this.pushDisponible = false,
  });

  /// Running in a browser (the PWA), not as an Android or iOS app.
  final bool esWeb;

  /// iPhone or iPad (iPadOS reports itself as a Mac with a touch screen).
  final bool esIos;

  /// Opened from the home screen (`display-mode: standalone`), not from a browser tab.
  final bool instalada;

  /// The browser has the Notification, Push and Service Worker APIs. iOS only offers them to a web
  /// app added to the home screen (iOS 16.4+).
  final bool pushDisponible;

  /// An iPhone or iPad browser tab: alerts only arrive once the app is on the home screen, so the
  /// app shows how to add it.
  bool get debeInstalar => esWeb && esIos && !instalada;
}

final entornoNavegadorProvider = Provider<EntornoNavegador>(
  (ref) => leerEntornoNavegador(),
);
