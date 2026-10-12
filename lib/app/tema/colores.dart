import 'package:flutter/painting.dart';

/// Design color tokens of the Te Tengo brand kit (docs/references/DESIGN.md and the `:root` of the
/// prototype): cream background, violet for action and brand, coral for the accent.
///
/// Rule: red and amber are reserved for real events, and status never depends on color alone (always
/// with an icon and text).
abstract final class Colores {
  static const fondo = Color(0xFFFFF7F1);
  static const fondo2 = Color(0xFFF7F2F5);
  static const tarjeta = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF2B1D4E);
  static const tinta2 = Color(0xFF5A4F70);
  static const tinta3 = Color(0xFF6E6585);
  static const linea = Color(0xFFEFE7EE);
  static const linea2 = Color(0xFFDED4E2);

  /// Brand and primary action outside alerts.
  static const morado = Color(0xFF4B2E83);
  static const moradoPresionado = Color(0xFF3B2268);
  static const moradoSuave = Color(0xFFF1EBF8);
  static const moradoTinta = Color(0xFF4B2E83);

  /// Fall alert (high severity).
  static const caida = Color(0xFFD63B2F);
  static const caidaProfundo = Color(0xFFB8301F);
  static const caidaSuave = Color(0xFFFDEBE8);
  static const caidaTinta = Color(0xFFA12A1F);

  /// Unstable movement (medium severity).
  static const inestable = Color(0xFFF1B42F);
  static const inestableProfundo = Color(0xFFD99A12);
  static const inestableSuave = Color(0xFFFDF3DB);
  static const inestableTinta = Color(0xFF6E4B00);

  /// Normal state, camera online, recovery.
  static const calma = Color(0xFF1C7A4C);
  static const calmaSuave = Color(0xFFE6F5EC);
  static const calmaTinta = Color(0xFF145C39);

  /// Non-urgent notices (permissions, connectivity).
  static const aviso = Color(0xFF8F5400);
  static const avisoSuave = Color(0xFFFBEFD9);
  static const avisoTinta = Color(0xFF5E3700);

  /// Paused camera.
  static const pausa = Color(0xFF4E5B74);
  static const pausaSuave = Color(0xFFECEEF3);

  /// Brand accent (icons, fills, the selected tab): never used for a state or an alert. Text on
  /// coral is ink (6.8:1), never white (2.2:1); coral text uses [coralTinta].
  static const coral = Color(0xFFFF8F7E);
  static const coralSuave = Color(0xFFFFEDE8);
  static const coralTinta = Color(0xFFA8402F);
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
