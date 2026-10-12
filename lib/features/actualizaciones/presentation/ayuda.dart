import 'package:flutter/material.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';

/// A «?» that shows a short help text when tapped (the prototype's `infoTip`): 24 px icon, 44 px
/// target. Kept inside this feature until the shared «?» help component reaches `develop`
/// (docs/BLOCKERS.md).
class AyudaActualizacion extends StatelessWidget {
  const AyudaActualizacion({
    super.key,
    required this.texto,
    required this.sobre,
  });

  /// The help text.
  final String texto;

  /// What it explains, for screen readers: «Más información: la descarga».
  final String sobre;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Tooltip(
      message: texto,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      preferBelow: true,
      textStyle: estiloTexto(15, 400, color: c.tinta),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: c.tarjeta,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.linea2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: 'Más información: $sobre',
        hint: texto,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Icon(Icons.help_outline_rounded, size: 24, color: c.tinta2),
          ),
        ),
      ),
    );
  }
}
