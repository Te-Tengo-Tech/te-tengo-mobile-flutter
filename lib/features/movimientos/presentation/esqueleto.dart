import 'package:flutter/material.dart';

import '../domain/fotogramas.dart';

/// The skeleton of a frame (`rpFigure`): bones and joints in [color], the head a circle.
class PintorEsqueleto extends CustomPainter {
  const PintorEsqueleto(this.fotograma, {required this.color});

  final Fotograma? fotograma;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final f = fotograma;
    if (f == null) return;
    Offset? p(int i) {
      final o = i < f.puntos.length ? f.puntos[i] : null;
      return o == null ? null : Offset(o.dx * size.width, o.dy * size.height);
    }

    final hueso = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in huesos) {
      final pa = p(a), pb = p(b);
      if (pa != null && pb != null) canvas.drawLine(pa, pb, hueso);
    }
    final relleno = Paint()..color = Colors.white;
    final borde = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (var i = 5; i < f.puntos.length && i < 17; i++) {
      final q = p(i);
      if (q == null) continue;
      canvas.drawCircle(q, 5, relleno);
      canvas.drawCircle(q, 5, borde);
    }
    if (p(0) case final cabeza?) {
      canvas.drawCircle(cabeza, 11, relleno);
      canvas.drawCircle(cabeza, 11, borde..strokeWidth = 3.5);
    }
  }

  @override
  bool shouldRepaint(PintorEsqueleto old) =>
      old.fotograma != fotograma || old.color != color;
}
