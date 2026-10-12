import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/rutas.dart';
import '../../app/tema/colores.dart';
import '../../app/tema/tema.dart';
import '../../core/ui/marca.dart';

const lemaTeTengo = 'Cerca de los tuyos, aunque estés lejos.';

/// Splash (screen 00): on cream the violet body rises, its head drops in, the coral figure enters the
/// embrace, the symbol beats once and «Te Tengo» and the tagline appear; then the screen goes to
/// [siguiente] (about 2 s; a tap skips it). Only transform and opacity animate.
///
/// With `disableAnimations` the final frame is shown still and then fades (DESIGN.md, Brand).
class PantallaArranque extends StatefulWidget {
  const PantallaArranque({super.key, this.siguiente});

  /// Where to go next; the router guards send a signed-out user to the welcome screen.
  final String? siguiente;

  static const duracionAnimacion = Duration(milliseconds: 2000);
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
      backgroundColor: Colores.fondo,
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

  static const _lado = 140.0;

  @override
  Widget build(BuildContext context) {
    // Timings of the prototype (`.splash.play`), in ms.
    final cuerpo = _tramo(t, 50, 650, _suave);
    final cabeza = _tramo(t, 220, 770, _suave);
    final abrazada = _tramo(t, 550, 1250, _suave);
    final latido = _tramo(t, 1200, 1750, Curves.easeInOut);
    final palabra = _tramo(t, 1350, 1850, _suave);
    final lema = _tramo(t, 1500, 2000, _suave);
    final escalaLatido = 1 + .06 * (1 - (2 * latido - 1).abs());
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 0, 36, 72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: _lado,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Soft coral glow behind the embrace.
                  Positioned.fill(
                    child: Opacity(
                      opacity: abrazada,
                      child: Transform.scale(
                        scale: 1.9,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Color(0x47FF8F7E), Color(0x00FF8F7E)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Transform.scale(
                      scale: escalaLatido,
                      child: Stack(
                        children: [
                          _pieza(
                            PiezasSimbolo.cuerpo('#4B2E83'),
                            cuerpo,
                            centro: const Offset(42, 76),
                            desde: const Offset(0, 22),
                            escala: .9,
                          ),
                          _pieza(
                            PiezasSimbolo.cabeza('#4B2E83'),
                            cabeza,
                            centro: const Offset(47.7, 24.4),
                            desde: const Offset(0, -26),
                          ),
                          _pieza(
                            PiezasSimbolo.abrazada('#FF8F7E'),
                            abrazada,
                            centro: const Offset(72, 70),
                            desde: const Offset(30, 4),
                            escala: .9,
                            giro: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Opacity(
              opacity: palabra,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - palabra)),
                child: const PalabraTeTengo(tamano: 44),
              ),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: lema,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - lema)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(
                    lemaTeTengo,
                    textAlign: TextAlign.center,
                    style: estiloTexto(
                      17,
                      500,
                      color: Colores.tinta2,
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

  /// One piece of the symbol arriving: [p] goes 0–1; it starts moved by [desde] (symbol units),
  /// scaled by [escala] and turned [giro] degrees around [centro], and faded out.
  Widget _pieza(
    String contenido,
    double p, {
    required Offset centro,
    required Offset desde,
    double escala = 1,
    double giro = 0,
  }) {
    final u = _lado / 122;
    final resto = 1 - p;
    final matriz = Matrix4.identity()
      ..translateByDouble(desde.dx * u * resto, desde.dy * u * resto, 0, 1)
      ..translateByDouble(centro.dx * u, centro.dy * u, 0, 1)
      ..rotateZ(giro * resto * 3.141592653589793 / 180)
      ..scaleByDouble(
        escala + (1 - escala) * p,
        escala + (1 - escala) * p,
        1,
        1,
      )
      ..translateByDouble(-centro.dx * u, -centro.dy * u, 0, 1);
    return Positioned.fill(
      child: Opacity(
        opacity: p,
        child: Transform(
          transform: matriz,
          child: SvgPicture.string(PiezasSimbolo.svg(contenido)),
        ),
      ),
    );
  }
}
