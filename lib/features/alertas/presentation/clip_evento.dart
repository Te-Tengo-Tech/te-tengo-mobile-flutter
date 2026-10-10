import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../core/dispositivo/pantalla_completa.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/ilustraciones.dart';
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
  const ClipEvento({super.key, required this.alerta});

  final Alerta alerta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (alerta.clip != EstadoClip.disponible) {
      return ClipNoDisponible(alerta: alerta, estado: alerta.clip);
    }
    final clip = ref.watch(clipProvider(alerta.id));
    return switch (clip) {
      AsyncData(value: final r) when r.enlace != null => _Reproductor(
        alerta: alerta,
        enlace: r.enlace!,
      ),
      AsyncData(value: final r) => ClipNoDisponible(
        alerta: alerta,
        estado: r.estado,
      ),
      AsyncError(:final error) => MensajeProblema(error),
      _ => _Marco(
        alerta: alerta,
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
  });

  final Alerta alerta;
  final EstadoClip estado;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final eliminado = estado == EstadoClip.eliminado;
    final (icono, titulo, detalle) = eliminado
        ? (
            Ico.trash,
            'La grabación ya no está disponible',
            'Se eliminó el '
                '${fechaConAnio(alerta.ocurridaEn.add(const Duration(days: 30)))} '
                'por la política de retención de 30 días. El registro de la '
                'alerta se conserva.',
          )
        : (
            Ico.video,
            'Clip no disponible',
            'Hubo un problema al guardar el video de este evento. La alerta es '
                'válida: el aviso y el registro no dependen del clip.',
          );
    return Container(
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colores.fondo2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colores.linea2, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icono(icono, tamano: 32, color: Colores.tinta3),
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
  const _Marco({required this.alerta, required this.child});

  final Alerta alerta;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
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
        ],
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
  const _Reproductor({required this.alerta, required this.enlace});

  final Alerta alerta;
  final EnlaceClip enlace;

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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Marco(
            alerta: widget.alerta,
            child: _clip.listo && !_clip.enPantallaCompleta
                ? FittedBox(fit: BoxFit.cover, child: _clip.vista())
                : _Poster(alerta: widget.alerta),
          ),
          const SizedBox(height: 8),
          ControlesClip(
            reproduccion: _clip,
            alPantallaCompleta: _pantallaCompleta,
          ),
          const SizedBox(height: 8),
          Text(
            'Ilustración de la habitación con la postura detectada. 6 s antes '
            'y 6 s después del evento.',
            style: Theme.of(context).textTheme.bodySmall,
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
    return Scaffold(
      backgroundColor: Colores.noche,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ListenableBuilder(
                      listenable: r,
                      builder: (context, _) => r.listo
                          ? FittedBox(child: r.vista())
                          : Center(
                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: ColoredBox(
                                  color: const Color(0xFFDCD8E6),
                                  child: _Poster(alerta: alerta),
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: EtiquetaClip(
                        texto:
                            '${alerta.habitacion} · ${hora(alerta.ocurridaEn)}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ControlesClip(
                reproduccion: r,
                enPantallaCompleta: true,
                alPantallaCompleta: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
