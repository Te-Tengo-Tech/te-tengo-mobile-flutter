import 'package:flutter/painting.dart';

/// Design color tokens (docs/references/DESIGN.md).
///
/// Rule: red and amber are reserved for real events, and status never depends on color alone (always
/// with an icon and text).
abstract final class Colores {
  static const fondo = Color(0xFFEEF0F4);
  static const fondo2 = Color(0xFFE4E6EC);
  static const tarjeta = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF221A38);
  static const tinta2 = Color(0xFF4F4766);
  static const tinta3 = Color(0xFF655D7A);
  static const linea = Color(0xFFD9D7E1);
  static const linea2 = Color(0xFFC7C3D3);

  /// Brand and primary action outside alerts.
  static const morado = Color(0xFF4A2A85);

  /// Fall alert (high severity).
  static const caida = Color(0xFFBF2A1B);

  /// Unstable movement (medium severity).
  static const inestable = Color(0xFFF1B42F);

  /// Normal state, camera online, recovery.
  static const calma = Color(0xFF1C7A4C);

  /// Non-urgent notices (permissions, connectivity).
  static const aviso = Color(0xFF8F5400);
  static const avisoSuave = Color(0xFFFBEFD9);

  /// Paused camera.
  static const pausa = Color(0xFF4E5B74);
  static const pausaSuave = Color(0xFFE6E9F0);

  /// Brand only: never used for a state or an alert.
  static const coral = Color(0xFFE8765A);
  static const durazno = Color(0xFFFFB59C);
}
