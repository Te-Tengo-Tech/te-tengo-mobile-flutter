import 'package:flutter/material.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/iconos.dart';
import 'reproduccion_clip.dart';

/// `m:ss` of the clip bar.
String tiempoClip(Duration d) =>
    '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

/// «1×», «0,5×»: the label of a playback speed.
String etiquetaVelocidad(double v) =>
    '${v == v.roundToDouble() ? v.toInt() : v.toString().replaceAll('.', ',')}×';

/// Clip bar (`.clip-bar`): play, pause or watch again, -5 s and +5 s, a progress track that can be
/// dragged or tapped (with the event mark in the middle), the time and the speed (0,5×, 1×, 1,5×
/// and 2×, in a cycle). In full screen it also has the button that leaves it; inline, full screen
/// is the button over the image. Every target is at least 48 dp. The same bar is used inline and in
/// full screen.
class ControlesClip extends StatelessWidget {
  const ControlesClip({
    super.key,
    required this.reproduccion,
    this.alSalir,
    this.aRas = false,
  });

  final ReproduccionClip reproduccion;

  /// Leaves full screen; only the full-screen view sets it.
  final VoidCallback? alSalir;

  /// Square corners: the bar spans the card edge to edge.
  final bool aRas;

  static const tamanoBoton = 48.0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: reproduccion,
    builder: (context, _) {
      final r = reproduccion;
      final buscable = r.duracionConocida;
      final (icono, etiqueta) = r.reproduciendo
          ? (Ico.pause, 'Pausar clip')
          : r.terminado
          ? (Ico.refresh, 'Volver a ver el clip')
          : (Ico.play, 'Reproducir clip');
      final reproducir = _Boton(
        etiqueta: etiqueta,
        claro: true,
        alTocar: r.listo ? r.alternar : null,
        child: Icono(
          icono,
          tamano: 20,
          color: Colores.tinta,
          etiqueta: etiqueta,
        ),
      );
      final retroceder = _Boton(
        etiqueta: 'Retroceder 5 segundos',
        alTocar: buscable ? r.retroceder : null,
        child: Text('−5 s', style: estiloMono(tamano: 14, color: Colors.white)),
      );
      final adelantar = _Boton(
        etiqueta: 'Adelantar 5 segundos',
        alTocar: buscable ? r.adelantar : null,
        child: Text('+5 s', style: estiloMono(tamano: 14, color: Colors.white)),
      );
      final etiquetaVel =
          'Velocidad ${etiquetaVelocidad(r.velocidad)}. Cambiar la velocidad';
      final velocidad = _Boton(
        etiqueta: etiquetaVel,
        alTocar: r.listo ? r.cambiarVelocidad : null,
        child: Text(
          etiquetaVelocidad(r.velocidad),
          maxLines: 1,
          style: estiloTexto(15, 800, color: Colors.white),
        ),
      );
      final salir = alSalir;
      final pantalla = salir == null
          ? null
          : _Boton(
              etiqueta: 'Salir de pantalla completa',
              alTocar: salir,
              child: const Icono(
                Ico.contract,
                tamano: 22,
                color: Colors.white,
                etiqueta: 'Salir de pantalla completa',
              ),
            );
      final tiempo = Text(
        '${tiempoClip(r.posicion)} / ${tiempoClip(r.duracion)}',
        maxLines: 1,
        style: estiloMono(tamano: 14, peso: 400, color: Colors.white),
      );
      final pista = _Pista(reproduccion: r);
      return Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        decoration: BoxDecoration(
          color: Colores.tinta,
          borderRadius: BorderRadius.circular(aRas ? 0 : 14),
        ),
        // No LayoutBuilder: the bar lays out inside folds that measure their content.
        child: Builder(
          builder: (context) => MediaQuery.sizeOf(context).width >= 560
              // Landscape or a wide screen: one row, as the prototype.
              ? Row(
                  children: [
                    reproducir,
                    retroceder,
                    adelantar,
                    const SizedBox(width: 8),
                    Expanded(child: pista),
                    const SizedBox(width: 12),
                    tiempo,
                    const SizedBox(width: 4),
                    velocidad,
                    ?pantalla,
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: pista,
                    ),
                    Row(
                      children: [
                        reproducir,
                        const SizedBox(width: 4),
                        retroceder,
                        adelantar,
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: tiempo,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        velocidad,
                        ?pantalla,
                      ],
                    ),
                  ],
                ),
        ),
      );
    },
  );
}

class _Boton extends StatelessWidget {
  const _Boton({
    required this.etiqueta,
    required this.alTocar,
    required this.child,
    this.claro = false,
  });

  final String etiqueta;
  final VoidCallback? alTocar;
  final Widget child;

  /// The white play button of the prototype.
  final bool claro;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(11);
    return Semantics(
      label: etiqueta,
      button: true,
      enabled: alTocar != null,
      excludeSemantics: true,
      child: Opacity(
        opacity: alTocar == null ? .45 : 1,
        child: Material(
          color: claro ? Colors.white : Colors.white.withValues(alpha: .1),
          borderRadius: radio,
          child: InkWell(
            borderRadius: radio,
            onTap: alTocar,
            child: SizedBox.square(
              dimension: ControlesClip.tamanoBoton,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Progress track (`.clip-bar .track`) with the event mark in the middle. Tap or drag to seek;
/// screen readers move it 5 s at a time. Disabled while the duration is not known.
class _Pista extends StatefulWidget {
  const _Pista({required this.reproduccion});

  final ReproduccionClip reproduccion;

  @override
  State<_Pista> createState() => _PistaState();
}

class _PistaState extends State<_Pista> {
  bool _reanudar = false;

  ReproduccionClip get _r => widget.reproduccion;

  void _ir(double x) {
    final ancho = context.size?.width ?? 0;
    if (ancho <= 0) return;
    final fraccion = (x / ancho).clamp(0.0, 1.0);
    _r.buscar(_r.duracion * fraccion);
  }

  @override
  Widget build(BuildContext context) {
    final r = _r;
    final activo = r.duracionConocida;
    final total = r.duracion.inMilliseconds;
    final avance = total == 0
        ? 0.0
        : (r.posicion.inMilliseconds / total).clamp(0.0, 1.0);
    return Semantics(
      container: true,
      // «Momento del evento» stays its own node instead of joining the slider's label.
      explicitChildNodes: true,
      slider: true,
      enabled: activo,
      label: 'Avance del clip',
      value: tiempoClip(r.posicion),
      increasedValue: activo
          ? tiempoClip(r.posicion + ReproduccionClip.salto)
          : null,
      decreasedValue: activo
          ? tiempoClip(r.posicion - ReproduccionClip.salto)
          : null,
      onIncrease: activo ? r.adelantar : null,
      onDecrease: activo ? r.retroceder : null,
      child: GestureDetector(
        // Screen readers use the slider's increase and decrease instead.
        excludeFromSemantics: true,
        behavior: HitTestBehavior.opaque,
        onTapUp: activo ? (d) => _ir(d.localPosition.dx) : null,
        onHorizontalDragStart: activo
            ? (d) {
                _reanudar = r.reproduciendo;
                if (_reanudar) r.pausar();
                _ir(d.localPosition.dx);
              }
            : null,
        onHorizontalDragUpdate: activo ? (d) => _ir(d.localPosition.dx) : null,
        onHorizontalDragEnd: activo
            ? (_) {
                if (_reanudar) r.reproducir();
                _reanudar = false;
              }
            : null,
        child: SizedBox(
          height: ControlesClip.tamanoBoton,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .28),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: avance,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Align(
                child: Semantics(
                  container: true,
                  label: 'Momento del evento',
                  child: Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A7A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              if (activo)
                Align(
                  alignment: Alignment(avance * 2 - 1, 0),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
