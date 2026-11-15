import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Taps on the notices that Android draws itself from data-only pushes (API contract §7,
/// `avisoEnLaApp`; android/.../AvisosPush.kt). Firebase's `onMessageOpenedApp` and
/// `getInitialMessage` only know its own notification messages, so MainActivity passes these taps
/// through the `org.example.caregiver_app/avisos` channel: `tomarInicial` (the tap that launched the
/// app, once) and `abierto` (a tap while the app runs).
class AvisosNativos {
  AvisosNativos({MethodChannel? canal})
    : _canal = canal ?? const MethodChannel(nombreCanal) {
    _canal.setMethodCallHandler((llamada) async {
      if (llamada.method == 'abierto') {
        final datos = _comoMapa(llamada.arguments);
        if (datos != null) _abiertas.add(datos);
      }
    });
  }

  static const nombreCanal = 'org.example.caregiver_app/avisos';

  final MethodChannel _canal;
  final _abiertas = StreamController<Map<String, dynamic>>.broadcast();

  /// The push data of each tap while the app runs.
  Stream<Map<String, dynamic>> get abiertas => _abiertas.stream;

  /// The push data of the tap that launched the app, or null (also without the native side).
  Future<Map<String, dynamic>?> tomarInicial() async {
    try {
      return _comoMapa(await _canal.invokeMethod<Object?>('tomarInicial'));
    } on Object catch (e) {
      debugPrint('Sin aviso inicial nativo: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _comoMapa(Object? valor) =>
      valor is Map ? valor.map((k, v) => MapEntry('$k', v)) : null;
}
