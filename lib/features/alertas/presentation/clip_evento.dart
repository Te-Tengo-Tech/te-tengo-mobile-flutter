import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../core/dispositivo/pantalla_completa.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../camaras/domain/camara.dart';
import '../../sesion/presentation/pantalla_bienvenida.dart' show EtiquetaClip;
import '../data/alertas_repositorio.dart';
import '../domain/alerta.dart';
import 'controles_clip.dart';
import 'reproduccion_clip.dart';
import 'reproductor.dart';

/// Event clip (US-18): 6 s before and 6 s after the event (CA-18.1). Without a stored video the
/// alert still shows and says the clip is not available (CA-18.2). The short-lived URL is renewed by
/// [ReproduccionClip]; the controls are [ControlesClip], also in full screen.
class ClipEvento extends ConsumerWidget {
  const ClipEvento({super.key, required this.alerta, this.aRas = false});

  final Alerta alerta;

  /// Spans its card edge to edge (inside the alert's «Clip del evento»), with square corners.
  final bool aRas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (alerta.clip != EstadoClip.disponible) {
      return ClipNoDisponible(alerta: alerta, estado: alerta.clip, aRas: aRas);
    }
    final clip = ref.watch(clipProvider(alerta.id));
    return switch (clip) {
      AsyncData(value: final r) when r.enlace != null => _Reproductor(
        alerta: alerta,
        enlace: r.enlace!,
        aRas: aRas,
      ),
      AsyncData(value: final r) => ClipNoDisponible(
        alerta: alerta,
        estado: r.estado,
        aRas: aRas,
      ),
      AsyncError(:final error) => MensajeProblema(error),
      _ => _Marco(
        alerta: alerta,
        aRas: aRas,
        child: _Poster(alerta: alerta),
      ),
    };
  }
}

/// «Clip no disponible» or a deleted recording (`.clip.missing`).
class ClipNoDisponible extends StatelessWidget {
  const ClipNoDisponible({
    super.key,
    required this.alerta,
    required this.estado,
    this.aRas = false,
  });

  final Alerta alerta;
  final EstadoClip estado;
  final bool aRas;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final eliminado = estado == EstadoClip.eliminado;
    final (icono, titulo, detalle) = eliminado
        ? (
            Ico.trash,
            'La grabación ya no está disponible',
            'Se borró el '
                '${fechaConAnio(alerta.ocurridaEn.add(const Duration(days: 30)))} '
                '(se guardan 30 días). El registro se conserva.',
          )
        : (
            Ico.video,
            'Clip no disponible',
            'No se pudo guardar el video. La alerta sigue siendo válida.',
          );
    return Container(
      constraints: BoxConstraints(minHeight: aRas ? 0 : 170),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colores.fondo2,
        borderRadius: BorderRadius.circular(aRas ? 0 : 18),
        border: aRas
            ? null
            : Border.all(color: context.colores.linea2, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icono(icono, tamano: 32, color: context.colores.tinta3),
          const SizedBox(height: 8),
          Text(titulo, textAlign: TextAlign.center, style: texto.titleMedium),
          const SizedBox(height: 8),
          Text(detalle, textAlign: TextAlign.center, style: texto.bodyMedium),
        ],
      ),
    );
  }
}

class _Marco extends StatelessWidget {
  const _Marco({
    required this.alerta,
    required this.child,
    this.aRas = false,
    this.alPantallaCompleta,
  });

  final Alerta alerta;
  final Widget child;
  final bool aRas;

  /// The full-screen button over the image (`.clip-fs`), once the clip can play.
  final VoidCallback? alPantallaCompleta;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(aRas ? 0 : 18),
    child: AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: const Color(0xFFDCD8E6), child: child),
          Positioned(
            top: 10,
            left: 10,
            child: EtiquetaClip(
              texto: '${alerta.habitacion} · ${hora(alerta.ocurridaEn)}',
            ),
          ),
          if (alPantallaCompleta case final entrar?)
            Positioned(
              top: 8,
              right: 8,
              child: _BotonPantallaCompleta(alTocar: entrar),
            ),
        ],
      ),
    ),
  );
}

/// `.clip-fs`: 48 px, dark and translucent over the top right corner of the image.
class _BotonPantallaCompleta extends StatelessWidget {
  const _BotonPantallaCompleta({required this.alTocar});

  final VoidCallback alTocar;

  static const _etiqueta = 'Ver el clip en pantalla completa';

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: _etiqueta,
    excludeSemantics: true,
    child: Material(
      color: const Color(0xB817121F),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: alTocar,
        child: const SizedBox.square(
          dimension: 48,
          child: Center(
            child: Icono(Ico.expand, tamano: 22, color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

/// Room and pose while the clip loads.
class _Poster extends StatelessWidget {
  const _Poster({required this.alerta});

  final Alerta alerta;

  @override
  Widget build(BuildContext context) => Habitacion(
    nombre: alerta.habitacion,
    postura: alerta.esCaida ? Postura.caida : Postura.inestable,
    aro: alerta.esCaida ? '#BF2A1B' : '#B07A00',
  );
}

class _Reproductor extends ConsumerStatefulWidget {
  const _Reproductor({
    required this.alerta,
    required this.enlace,
    required this.aRas,
  });

  final Alerta alerta;
  final EnlaceClip enlace;
  final bool aRas;

  @override
  ConsumerState<_Reproductor> createState() => _ReproductorState();
}

class _ReproductorState extends ConsumerState<_Reproductor> {
  late final ReproduccionClip _clip = ReproduccionClip(
    alertaId: widget.alerta.id,
    enlace: widget.enlace,
    repositorio: ref.read(alertasRepositorioProvider),
    fabrica: ref.read(fabricaClipProvider),
    reloj: ref.read(relojProvider),
  );

  @override
  void initState() {
    super.initState();
    _clip.iniciar();
  }

  @override
  void dispose() {
    _clip.dispose();
    super.dispose();
  }

  /// Android and iOS: a full-screen route with landscape and immersive bars. The PWA: the browser's
  /// Fullscreen API, or, without it (Safari on iPhone), the video element's own full screen. Runs
  /// inside the tap, as browsers require.
  void _pantallaCompleta() {
    final modo = ref.read(pantallaCompletaProvider);
    if (!modo.disponible && _clip.pantallaCompletaNativa()) return;
    if (modo.disponible) modo.entrar();
    _clip.enPantallaCompleta = true;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => PantallaClipCompleta(
              alerta: widget.alerta,
              reproduccion: _clip,
            ),
          ),
        )
        .whenComplete(() => _clip.enPantallaCompleta = false);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _clip,
    builder: (context, _) {
      if (_clip.perdido case final estado?) {
        return ClipNoDisponible(alerta: widget.alerta, estado: estado);
      }
      final aRas = widget.aRas;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Marco(
            alerta: widget.alerta,
            aRas: aRas,
            alPantallaCompleta: _pantallaCompleta,
            child: _clip.listo && !_clip.enPantallaCompleta
                ? FittedBox(fit: BoxFit.cover, child: _clip.vista())
                : _Poster(alerta: widget.alerta),
          ),
          if (!aRas) const SizedBox(height: 8),
          ControlesClip(reproduccion: _clip, aRas: aRas),
          Padding(
            padding: aRas
                ? const EdgeInsets.fromLTRB(16, 10, 16, 14)
                : const EdgeInsets.only(top: 8),
            child: Text(
              'Con la postura detectada · 6 s antes y 6 s después.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    },
  );
}

/// The clip in full screen, with the same controls. Leaving it (the button, back, or the browser's
/// own exit) restores the orientation and the system bars.
class PantallaClipCompleta extends ConsumerStatefulWidget {
  const PantallaClipCompleta({
    super.key,
    required this.alerta,
    required this.reproduccion,
  });

  final Alerta alerta;
  final ReproduccionClip reproduccion;

  @override
  ConsumerState<PantallaClipCompleta> createState() =>
      _PantallaClipCompletaState();
}

class _PantallaClipCompletaState extends ConsumerState<PantallaClipCompleta> {
  late final ModoPantallaCompleta _modo = ref.read(pantallaCompletaProvider);
  StreamSubscription<bool>? _cambios;

  @override
  void initState() {
    super.initState();
    _cambios = _modo.cambios.listen((dentro) {
      if (!dentro) _salir();
    });
    widget.reproduccion.addListener(_alCambiar);
  }

  void _alCambiar() {
    // A clip that is gone is explained inline.
    if (widget.reproduccion.perdido != null) _salir();
  }

  void _salir() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    widget.reproduccion.removeListener(_alCambiar);
    _cambios?.cancel();
    _modo.salir();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reproduccion;
    final alerta = widget.alerta;
    void salir() => Navigator.of(context).maybePop();
    // Landscape and black, as any video: the clip keeps its proportions with black bars.
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: ListenableBuilder(
              listenable: r,
              builder: (context, _) => r.listo
                  ? FittedBox(child: r.vista())
                  : AspectRatio(
                      aspectRatio: 16 / 10,
                      child: _Poster(alerta: alerta),
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xB3000000), Color(0x00000000)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Salir de pantalla completa',
                        onPressed: salir,
                        icon: const Icono(Ico.x, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${alerta.tipo.nombre} '
                                      '${enHabitacion(alerta.habitacion)} · ',
                                ),
                                TextSpan(
                                  text: hora(alerta.ocurridaEn),
                                  style: estiloMono(
                                    tamano: 17,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            style: estiloTexto(17, 700, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(48, 0, 48, 12),
              child: ControlesClip(reproduccion: r, alSalir: salir),
            ),
          ),
        ],
      ),
    );
  }
}
