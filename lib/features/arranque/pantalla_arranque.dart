import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/rutas.dart';
import '../../app/tema/colores.dart';
import '../../app/tema/tema.dart';
import '../../core/ui/marca.dart';

const lemaTeTengo = 'Cerca de los tuyos, aunque estés lejos.';

/// Splash (screen 00): on brand purple the arms open from the center, the dot falls and the arms
/// catch it with a slight sway, the stem is drawn, «Te Tengo» and the tagline appear, and the screen
/// fades to [siguiente] (about 2.2 s; a tap skips it).
///
/// With `disableAnimations` the final frame is shown still and then fades (DESIGN.md, Brand).
class PantallaArranque extends StatefulWidget {
  const PantallaArranque({super.key, this.siguiente});

  /// Where to go next; the router guards send a signed-out user to the welcome screen.
  final String? siguiente;

  static const duracionAnimacion = Duration(milliseconds: 1850);
  static const duracionQuieta = Duration(milliseconds: 1400);

  @override
  State<PantallaArranque> createState() => _PantallaArranqueState();
}

class _PantallaArranqueState extends State<PantallaArranque>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control = AnimationController(
    vsync: this,
    duration: PantallaArranque.duracionAnimacion,
  );
  bool _iniciada = false;
  bool _terminada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciada) return;
    _iniciada = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _control.value = 1;
      Future<void>.delayed(PantallaArranque.duracionQuieta, _terminar);
    } else {
      _control.forward().whenCompleteOrCancel(_terminar);
    }
  }

  void _terminar() {
    if (_terminada || !mounted) return;
    _terminada = true;
    context.go(widget.siguiente ?? Rutas.inicio);
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.morado,
      body: Semantics(
        label: 'Te Tengo. $lemaTeTengo',
        button: true,
        onTap: _terminar,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _terminar,
          child: AnimatedBuilder(
            animation: _control,
            builder: (context, _) => _Escena(t: _control.value),
          ),
        ),
      ),
    );
  }
}

/// Progress of [t] (0–1 over the whole animation) within the interval [inicio, fin] in ms.
double _tramo(double t, int inicio, int fin, [Curve curva = Curves.linear]) {
  final ms = t * PantallaArranque.duracionAnimacion.inMilliseconds;
  return curva.transform(((ms - inicio) / (fin - inicio)).clamp(0.0, 1.0));
}

const _suave = Cubic(.16, 1, .3, 1);

class _Escena extends StatelessWidget {
  const _Escena({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final palabra = _tramo(t, 1040, 1540, _suave);
    final lema = _tramo(t, 1200, 1700, _suave);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 0, 36, 72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 136,
              height: 136,
              child: CustomPaint(painter: _PintorSimbolo(t)),
            ),
            const SizedBox(height: 30),
            Opacity(
              opacity: palabra,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - palabra)),
                child: const PalabraTeTengo(tamano: 48, oscuro: true),
              ),
            ),
            const SizedBox(height: 14),
            Opacity(
              opacity: lema,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - lema)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 230),
                  child: Text(
                    lemaTeTengo,
                    textAlign: TextAlign.center,
                    style: estiloTexto(
                      18,
                      600,
                      color: const Color(0xFFE4DAF4),
                    ).copyWith(height: 1.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The symbol drawn in parts: arms (0.06–0.48 s), falling dot (0.32–0.74 s), catch sway
/// (0.74–1.16 s), stem (0.92–1.24 s) and a peach glow behind.
class _PintorSimbolo extends CustomPainter {
  const _PintorSimbolo(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / 120;
    canvas.scale(escala);

    final brillo = _tramo(t, 720, 1720);
    if (brillo > 0) {
      final alfa = brillo < .5 ? brillo * 2 : 1.0;
      canvas.drawCircle(
        const Offset(60, 52),
        130,
        Paint()
          ..shader = ui.Gradient.radial(
            const Offset(60, 52),
            130,
            [
              Colores.durazno.withValues(alpha: .20 * alfa * .8),
              Colores.durazno.withValues(alpha: .07 * alfa * .8),
              Colores.durazno.withValues(alpha: 0),
            ],
            const [0, .55, 1],
          ),
      );
    }

    final trazo = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;

    final fuste = _tramo(t, 920, 1240, const Cubic(.3, .7, .3, 1));
    if (fuste > 0) {
      canvas.drawLine(const Offset(60, 60), Offset(60, 60 + 36 * fuste), trazo);
    }

    // Catch: the arms and the dot sway together.
    final atrapa = _tramo(t, 740, 1160);
    final vaiven = math.sin(atrapa * math.pi * 2) * (1 - atrapa) * 3;
    canvas.save();
    canvas.translate(60, 59);
    canvas.rotate(vaiven * math.pi / 180);
    canvas.translate(-60, -59);

    final brazos = _tramo(t, 60, 480, const Cubic(.3, .7, .3, 1));
    if (brazos > 0) {
      for (final fin in const [Offset(22, 38), Offset(98, 38)]) {
        final control = Offset((60 + fin.dx) / 2, 59);
        final ruta = Path()
          ..moveTo(60, 59)
          ..quadraticBezierTo(control.dx, control.dy, fin.dx, fin.dy);
        for (final m in ruta.computeMetrics()) {
          canvas.drawPath(m.extractPath(0, m.length * brazos), trazo);
        }
      }
    }

    final caida = _tramo(t, 320, 740, const Cubic(.55, 0, .85, .35));
    if (caida > 0) {
      canvas.drawCircle(
        Offset(60, 38 - 46 * (1 - caida)),
        11,
        Paint()
          ..color = Colores.durazno.withValues(alpha: math.min(1, caida * 3)),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorSimbolo old) => old.t != t;
}
