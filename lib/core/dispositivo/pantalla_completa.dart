import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../web/navegador.dart';

/// Full screen for the event clip, replaceable in tests.
abstract interface class ModoPantallaCompleta {
  /// False on the web when the browser has no Fullscreen API (Safari on iPhone); the clip then uses
  /// the video element's own full screen.
  bool get disponible;

  /// Must be called inside the tap: browsers need a user gesture.
  void entrar();

  /// Restores the orientation and the system bars (or leaves the browser's full screen).
  void salir();

  /// The browser left full screen on its own (Esc, a swipe): false. Never emits on Android or iOS.
  Stream<bool> get cambios;
}

/// Android and iOS: the phone turns to landscape, with immersive system bars, while the clip is in
/// full screen (as any video player does).
class PantallaCompletaSistema implements ModoPantallaCompleta {
  const PantallaCompletaSistema();

  /// Both landscapes, so the phone can be held either way.
  static const orientaciones = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  @override
  bool get disponible => true;

  @override
  void entrar() {
    SystemChrome.setPreferredOrientations(orientaciones);
    // The bars come back with a swipe from the edge and hide again by themselves.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// The app sets no orientation of its own: an empty list gives back the orientations of
  /// `Info.plist` and the Android manifest. Edge-to-edge is Flutter's default on Android 15+ and shows
  /// the status bar on iOS.
  @override
  void salir() {
    SystemChrome.setPreferredOrientations(const []);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Stream<bool> get cambios => const Stream.empty();
}

/// The PWA: the browser's Fullscreen API on the whole page, so the same controls stay on screen.
class PantallaCompletaNavegador implements ModoPantallaCompleta {
  const PantallaCompletaNavegador();

  @override
  bool get disponible => pantallaCompletaDisponibleNavegador();

  @override
  void entrar() => entrarPantallaCompletaNavegador();

  @override
  void salir() => salirPantallaCompletaNavegador();

  @override
  Stream<bool> get cambios => cambiosPantallaCompletaNavegador();
}

final pantallaCompletaProvider = Provider<ModoPantallaCompleta>(
  (ref) => kIsWeb
      ? const PantallaCompletaNavegador()
      : const PantallaCompletaSistema(),
);
