import 'package:flutter/painting.dart';

/// Design color tokens (docs/references/DESIGN.md and the `:root` of the prototype).
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
  static const moradoPresionado = Color(0xFF3A1F6C);
  static const moradoSuave = Color(0xFFECE7F6);
  static const moradoTinta = Color(0xFF3B2270);

  /// Fall alert (high severity).
  static const caida = Color(0xFFBF2A1B);
  static const caidaProfundo = Color(0xFF951D11);
  static const caidaSuave = Color(0xFFFBE8E5);
  static const caidaTinta = Color(0xFF9C2012);

  /// Unstable movement (medium severity).
  static const inestable = Color(0xFFF1B42F);
  static const inestableProfundo = Color(0xFFD99A12);
  static const inestableSuave = Color(0xFFFDF3DB);
  static const inestableTinta = Color(0xFF6E4B00);

  /// Normal state, camera online, recovery.
  static const calma = Color(0xFF1C7A4C);
  static const calmaSuave = Color(0xFFE2F2E9);
  static const calmaTinta = Color(0xFF145C39);

  /// Non-urgent notices (permissions, connectivity).
  static const aviso = Color(0xFF8F5400);
  static const avisoSuave = Color(0xFFFBEFD9);
  static const avisoTinta = Color(0xFF5E3700);

  /// Paused camera.
  static const pausa = Color(0xFF4E5B74);
  static const pausaSuave = Color(0xFFE6E9F0);

  /// Brand only: never used for a state or an alert.
  static const coral = Color(0xFFE8765A);
  static const durazno = Color(0xFFFFB59C);

  /// Dark background of the live view.
  static const noche = Color(0xFF17121F);
  static const nocheTexto = Color(0xFFD9D3E6);
  static const nocheRaya = Color(0xFF231C30);
  static const nocheRaya2 = Color(0xFF2A2238);
  static const nocheEtiqueta = Color(0xC717121F);

  /// Icons of the unavailable live view: disconnected (amber) and paused (gray-blue).
  static const nocheAviso = Color(0xFFFFC76B);
  static const nochePausa = Color(0xFFC9D2E3);

  /// Recording dot of «EN VIVO».
  static const grabando = Color(0xFFFF5A47);

  /// Avatar tints of the prototype (`.avatar.b`, `.avatar.c`, `.avatar.rosa`).
  static const avatarAzulFondo = Color(0xFFE0EEF0);
  static const avatarAzulTinta = Color(0xFF1D5560);
  static const avatarArenaFondo = Color(0xFFF6E6DA);
  static const avatarArenaTinta = Color(0xFF7A3A12);
  static const avatarRosaFondo = Color(0xFFF4E4EE);
  static const avatarRosaTinta = Color(0xFF7A2456);
}
