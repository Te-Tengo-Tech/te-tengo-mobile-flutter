import 'package:flutter/material.dart';

import '../../app/tema/colores.dart';
import 'lista.dart';

/// Colors of the top band of a card (`.band`).
enum Banda { calma, caida, inestable, morado, pausa, aviso }

/// White card (`.card`) with an optional 8 px band in the color of the state.
class TarjetaBanda extends StatelessWidget {
  const TarjetaBanda({
    super.key,
    this.banda,
    required this.child,
    this.relleno = const EdgeInsets.all(18),
    this.borde = false,
  });

  final Banda? banda;
  final Widget child;
  final EdgeInsets relleno;
  final bool borde;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colores.tarjeta,
      borderRadius: BorderRadius.circular(22),
      border: borde ? Border.all(color: Colores.linea, width: 1.5) : null,
      boxShadow: borde ? null : sombraTarjeta,
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (banda != null)
          SizedBox(
            height: 8,
            child: CustomPaint(painter: _PintorBanda(banda!)),
          ),
        Padding(padding: relleno, child: child),
      ],
    ),
  );
}

class _PintorBanda extends CustomPainter {
  const _PintorBanda(this.banda);

  final Banda banda;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    switch (banda) {
      case Banda.pausa:
        // Striped, as the paused camera (`repeating-linear-gradient(135deg, ...)`).
        canvas.drawRect(rect, Paint()..color = Colores.pausa);
        final claro = Paint()..color = const Color(0xFF8C97AD);
        canvas.save();
        canvas.clipRect(rect);
        for (var x = -size.height; x < size.width + size.height; x += 12) {
          final trazo = Path()
            ..moveTo(x, 0)
            ..lineTo(x + 6, 0)
            ..lineTo(x + 6 + size.height, size.height)
            ..lineTo(x + size.height, size.height)
            ..close();
          canvas.drawPath(trazo, claro);
        }
        canvas.restore();
      case Banda.aviso:
        // Dashed, as a disconnected camera.
        final p = Paint()..color = Colores.aviso;
        for (var x = 0.0; x < size.width; x += 16) {
          canvas.drawRect(Rect.fromLTWH(x, 0, 10, size.height), p);
        }
      default:
        canvas.drawRect(
          rect,
          Paint()
            ..color = switch (banda) {
              Banda.calma => Colores.calma,
              Banda.caida => Colores.caida,
              Banda.inestable => Colores.inestable,
              _ => Colores.morado,
            },
        );
    }
  }

  @override
  bool shouldRepaint(_PintorBanda old) => old.banda != banda;
}

/// Key-value row of a card (`.kv`).
class FilaDato extends StatelessWidget {
  const FilaDato({
    super.key,
    required this.clave,
    required this.valor,
    this.mono = false,
    this.valorRico,
  });

  final String clave;
  final String valor;
  final bool mono;
  final InlineSpan? valorRico;

  @override
  Widget build(BuildContext context) {
    final estiloValor = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: Colores.tinta,
      fontFamily: mono ? 'AtkinsonHyperlegibleMono' : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              clave,
              style: const TextStyle(fontSize: 16, color: Colores.tinta3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: valorRico != null
                ? Text.rich(
                    valorRico!,
                    style: estiloValor,
                    textAlign: TextAlign.right,
                  )
                : Text(valor, style: estiloValor, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

/// Column of [FilaDato] separated by lines.
class DatosTarjeta extends StatelessWidget {
  const DatosTarjeta(this.filas, {super.key});

  final List<Widget> filas;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < filas.length; i++) ...[
        if (i > 0) const Divider(height: 1, thickness: 1),
        filas[i],
      ],
    ],
  );
}
