import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/iconos.dart';
import '../domain/alerta.dart';

/// Severity tag (`.sev`): «Caída» red with the fall icon, «Inestable» amber with the diamond. They
/// never share color, icon or label (CA-17.2).
class EtiquetaTipo extends StatelessWidget {
  const EtiquetaTipo(this.tipo, {super.key});

  final TipoAlerta tipo;

  @override
  Widget build(BuildContext context) {
    final caida = tipo == TipoAlerta.caida;
    final color = caida ? Colors.white : Colores.tinta;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: caida ? Colores.caida : Colores.inestable,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icono(caida ? Ico.fall : Ico.unsteady, tamano: 16, color: color),
          const SizedBox(width: 6),
          Text(
            caida ? 'Caída' : 'Inestable',
            style: estiloTexto(14, 800, color: color),
          ),
        ],
      ),
    );
  }
}

/// State stamp (`.stamp`): «Atendida», «Falsa alarma» (struck through) or «Activa».
class SelloEstado extends StatelessWidget {
  const SelloEstado(this.alerta, {super.key});

  final Alerta alerta;

  @override
  Widget build(BuildContext context) {
    final (texto, color, fondo, icono) = switch (alerta.estado) {
      EstadoAlerta.atendida => (
        'Atendida',
        Colores.calmaTinta,
        null,
        Ico.check,
      ),
      EstadoAlerta.falsaAlarma => ('Falsa alarma', Colores.tinta2, null, null),
      EstadoAlerta.activa when alerta.esCaida => (
        'Activa',
        Colores.caidaTinta,
        Colores.caidaSuave,
        null,
      ),
      EstadoAlerta.activa => (
        'Activa',
        Colores.inestableTinta,
        Colores.inestableSuave,
        null,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icono(icono, tamano: 14, color: color),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              texto.toUpperCase(),
              semanticsLabel: texto,
              style: estiloTexto(13, 800, color: color).copyWith(
                letterSpacing: .8,
                decoration: alerta.estado == EstadoAlerta.falsaAlarma
                    ? TextDecoration.lineThrough
                    : null,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small mark of lists and the weekly summary (`markSVG`): red square, amber diamond, struck box.
class MarcaAlerta extends StatelessWidget {
  const MarcaAlerta({super.key, required this.tipo, this.falsa = false});

  final TipoAlerta tipo;
  final bool falsa;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _Marca(tipo, falsa)),
    ),
  );
}

class _Marca extends CustomPainter {
  const _Marca(this.tipo, this.falsa);

  final TipoAlerta tipo;
  final bool falsa;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 18;
    canvas.scale(s);
    if (falsa) {
      final p = Paint()
        ..color = Colores.tinta3
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 2, 14, 14),
          const Radius.circular(4),
        ),
        p,
      );
      canvas.drawLine(const Offset(4, 14), const Offset(14, 4), p);
    } else if (tipo == TipoAlerta.caida) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(1, 1, 16, 16),
          const Radius.circular(4),
        ),
        Paint()..color = Colores.caida,
      );
    } else {
      final rombo = Path()
        ..moveTo(9, 1)
        ..lineTo(17, 9)
        ..lineTo(9, 17)
        ..lineTo(1, 9)
        ..close();
      canvas.drawPath(rombo, Paint()..color = Colores.inestable);
      canvas.drawPath(
        rombo,
        Paint()
          ..color = const Color(0xFFB07A00)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_Marca old) => old.tipo != tipo || old.falsa != falsa;
}
