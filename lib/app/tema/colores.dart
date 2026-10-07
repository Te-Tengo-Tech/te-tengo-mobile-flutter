import 'package:flutter/painting.dart';

/// Tokens de color del diseño (app-movil/DESIGN.md del repositorio de documentación).
///
/// Regla: el rojo y el ámbar se reservan para eventos reales, y el estado nunca depende solo del
/// color (siempre va con icono y texto).
abstract final class Colores {
  static const fondo = Color(0xFFEEF0F4);
  static const fondo2 = Color(0xFFE4E6EC);
  static const tarjeta = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF221A38);
  static const tinta2 = Color(0xFF4F4766);
  static const tinta3 = Color(0xFF655D7A);
  static const linea = Color(0xFFD9D7E1);
  static const linea2 = Color(0xFFC7C3D3);

  /// Marca y acción principal fuera de las alertas.
  static const morado = Color(0xFF4A2A85);

  /// Alerta de caída (severidad alta).
  static const caida = Color(0xFFBF2A1B);

  /// Movimiento inestable (severidad media).
  static const inestable = Color(0xFFF1B42F);

  /// Estado normal, cámara en línea, recuperación.
  static const calma = Color(0xFF1C7A4C);

  /// Avisos no urgentes (permisos, conexión).
  static const aviso = Color(0xFF8F5400);
  static const avisoSuave = Color(0xFFFBEFD9);

  /// Cámara en pausa.
  static const pausa = Color(0xFF4E5B74);
  static const pausaSuave = Color(0xFFE6E9F0);

  /// Solo de marca: nunca marcan un estado ni una alerta.
  static const coral = Color(0xFFE8765A);
  static const durazno = Color(0xFFFFB59C);
}
