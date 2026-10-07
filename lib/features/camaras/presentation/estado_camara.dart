import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../domain/camara.dart';

/// Estado de la cámara con icono, texto y color: el estado nunca depende solo del color.
class EstadoCamara extends StatelessWidget {
  const EstadoCamara({super.key, required this.estado});

  final EstadoConexion estado;

  @override
  Widget build(BuildContext context) {
    final (icono, texto, color) = switch (estado) {
      EstadoConexion.enLinea => (
        Icons.videocam_rounded,
        'En línea',
        Colores.calma,
      ),
      EstadoConexion.desconectada => (
        Icons.wifi_off_rounded,
        'Desconectada',
        Colores.aviso,
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
