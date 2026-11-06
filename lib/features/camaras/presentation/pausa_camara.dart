import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
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
    final l = context.l10n;
    mostrarToast(
      context,
      titulo: l.camaraReactivadaTitulo(
        deHabitacion(camara.nombreHabitacion, l),
      ),
      texto: l.camaraReactivadaTexto,
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
      final l = context.l10n;
      mostrarToast(
        context,
        titulo: l.camaraEnPausaTitulo(deHabitacion(c.nombreHabitacion, l)),
        texto: fin == null
            ? null
            : l.camaraSeReactivaraALas(
                finDePausa(fin, ref.read(relojProvider)(), l),
              ),
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
    final l = context.l10n;
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
                l.camaraPausarTitulo(
                  deHabitacion(widget.camara.nombreHabitacion, l),
                ),
                style: texto.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Text(l.camaraPausarTexto, style: texto.bodyMedium),
            const SizedBox(height: 16),
            for (final d in DuracionPausa.values)
              OpcionRadio(
                valor: d,
                seleccion: _duracion,
                titulo: d.texto(l),
                subtitulo: d.fin(ahora, l),
                alElegir: (v) => setState(() => _duracion = v),
              ),
            if (_problema != null) ...[
              MensajeProblema(_problema!),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            Boton(
              l.camaraPausar,
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
