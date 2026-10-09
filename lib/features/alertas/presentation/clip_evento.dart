import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../sesion/presentation/pantalla_bienvenida.dart' show EtiquetaClip;
import '../data/alertas_repositorio.dart';
import '../domain/alerta.dart';
import 'reproductor.dart';

/// Event clip (US-18): 6 s before and 6 s after the event (CA-18.1). Without a stored video the
/// alert still shows and says the clip is not available (CA-18.2).
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
        url: r.enlace!.url,
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
  const _Reproductor({required this.alerta, required this.url});

  final Alerta alerta;
  final String url;

  @override
  ConsumerState<_Reproductor> createState() => _ReproductorState();
}

class _ReproductorState extends ConsumerState<_Reproductor> {
  late final ControladorClip _clip = ref.read(fabricaClipProvider)(widget.url);
  bool _fallo = false;

  @override
  void initState() {
    super.initState();
    _clip.iniciar().then(
      (_) {
        if (mounted) setState(() {});
      },
      onError: (Object _) {
        if (mounted) setState(() => _fallo = true);
      },
    );
  }

  @override
  void dispose() {
    _clip.dispose();
    super.dispose();
  }

  String _tiempo(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_fallo) {
      return ClipNoDisponible(
        alerta: widget.alerta,
        estado: EstadoClip.noDisponible,
      );
    }
    return ListenableBuilder(
      listenable: _clip,
      builder: (context, _) {
        final duracion = _clip.duracion == Duration.zero
            ? const Duration(seconds: 12)
            : _clip.duracion;
        final avance = (_clip.posicion.inMilliseconds / duracion.inMilliseconds)
            .clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Marco(
              alerta: widget.alerta,
              child: _clip.listo
                  ? FittedBox(fit: BoxFit.cover, child: _clip.vista())
                  : _Poster(alerta: widget.alerta),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
              decoration: BoxDecoration(
                color: Colores.tinta,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: _clip.listo
                          ? () => _clip.reproduciendo
                                ? _clip.pausar()
                                : _clip.reproducir()
                          : null,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icono(
                            _clip.reproduciendo ? Ico.pause : Ico.play,
                            tamano: 20,
                            color: Colores.tinta,
                            etiqueta: _clip.reproduciendo
                                ? 'Pausar clip'
                                : 'Reproducir clip',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _Pista(avance: avance)),
                  const SizedBox(width: 12),
                  Text(
                    '${_tiempo(_clip.posicion)} / ${_tiempo(duracion)}',
                    style: estiloMono(
                      tamano: 14,
                      peso: 400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
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
}

/// Progress track with the event mark in the middle (`.clip-bar .track`).
class _Pista extends StatelessWidget {
  const _Pista({required this.avance});

  final double avance;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 16,
    child: LayoutBuilder(
      builder: (context, l) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .28),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Container(
            height: 6,
            width: l.maxWidth * avance,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Positioned(
            left: l.maxWidth / 2 - 2,
            child: Semantics(
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
        ],
      ),
    ),
  );
}
