import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';

/// Screen 33: bottom sheet to pause a camera for a while (US-22). Any member can pause it.
Future<void> pausarCamara(BuildContext context, Camara camara) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _HojaPausa(camara: camara),
    );

/// «Reanudar ahora»: ends the pause before its time.
Future<void> reanudarCamara(
  BuildContext context,
  WidgetRef ref,
  Camara camara,
) async {
  try {
    await ref.read(camarasRepositorioProvider).reanudar(camara.id);
    ref.invalidate(camarasProvider);
    if (!context.mounted) return;
    mostrarToast(
      context,
      titulo: 'Cámara ${deHabitacion(camara.nombreHabitacion)} reactivada',
      texto: 'La detección y la vista en vivo vuelven a estar disponibles.',
      icono: Ico.cam,
    );
  } on ProblemaApi catch (e) {
    if (!context.mounted) return;
    mostrarToast(
      context,
      titulo: e.detalle,
      icono: Ico.warn,
      tono: TonoAviso.advertencia,
    );
  }
}

class _HojaPausa extends ConsumerStatefulWidget {
  const _HojaPausa({required this.camara});

  final Camara camara;

  @override
  ConsumerState<_HojaPausa> createState() => _HojaPausaState();
}

class _HojaPausaState extends ConsumerState<_HojaPausa> {
  var _duracion = DuracionPausa.hora1;
  bool _guardando = false;
  ProblemaApi? _problema;

  Future<void> _pausar() async {
    setState(() {
      _guardando = true;
      _problema = null;
    });
    final c = widget.camara;
    try {
      final pausada = await ref
          .read(camarasRepositorioProvider)
          .pausar(c.id, _duracion);
      ref.invalidate(camarasProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      final fin = pausada.pausadaHasta;
      mostrarToast(
        context,
        titulo: 'Cámara ${deHabitacion(c.nombreHabitacion)} en pausa',
        texto: fin == null
            ? null
            : 'Se reactivará sola a las '
                  '${finDePausa(fin, ref.read(relojProvider)())}.',
        icono: Ico.pause,
      );
    } on ProblemaApi catch (e) {
      if (mounted) setState(() => _problema = e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final ahora = ref.watch(relojProvider)();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Pausar la cámara '
                '${deHabitacion(widget.camara.nombreHabitacion)}',
                style: texto.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin detección ni vista en vivo. Se reactiva sola.',
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 16),
            for (final d in DuracionPausa.values)
              OpcionRadio(
                valor: d,
                seleccion: _duracion,
                titulo: d.texto,
                subtitulo: d.fin(ahora),
                alElegir: (v) => setState(() => _duracion = v),
              ),
            if (_problema != null) ...[
              MensajeProblema(_problema!),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            Boton(
              'Pausar',
              icono: Ico.pause,
              cargando: _guardando,
              alPresionar: _pausar,
            ),
          ],
        ),
      ),
    );
  }
}
