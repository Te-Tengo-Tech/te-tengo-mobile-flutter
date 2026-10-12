import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../data/actualizacion_controller.dart';
import '../domain/versiones.dart';
import 'ayuda.dart';
import 'situacion.dart';

/// The update bar (`upd-bar`, screens 355, 359, 361, 362, 368 to 373 and 376): one slim bar above
/// the content of the four tabs that says «Hay una versión nueva», the download, its check or the
/// error, with a single action. Never on an alert or a live view (they have no tabs), and hidden
/// while an alert is active or the minimum-version screen is up (CA-43.9, CA-43.8).
class BarraActualizacion extends ConsumerWidget {
  const BarraActualizacion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(actualizacionProvider);
    if (estado.obligatoria) return const SizedBox.shrink();
    final situacion = situacionDe(estado);
    if (situacion == null) return const SizedBox.shrink();
    if (ref.watch(alertaActivaProvider).value != null) {
      return const SizedBox.shrink();
    }
    final info = estado.info!;
    final c = context.colores;
    final (fondo, colorIcono) = switch (situacion.tono) {
      TonoAviso.advertencia => (c.avisoSuave, c.aviso),
      _ => (c.moradoSuave, c.moradoTinta),
    };
    final grande = MediaQuery.textScalerOf(context).scale(16) > 24;
    final nueva = estado.nueva ?? estado.publicada;
    final conNotas =
        situacion.nueva &&
        info.canal != Canal.ios &&
        info.canal != Canal.pwa &&
        (nueva?.notas.isNotEmpty ?? false);
    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(situacion.titulo, style: estiloTexto(16, 700, color: c.tinta)),
        if (situacion.texto case final t?)
          Text(
            t,
            style: situacion.textoMono
                ? estiloMono(tamano: 15, peso: 400, color: c.tinta2)
                : estiloTexto(15, 400, color: c.tinta2),
          ),
        if (conNotas)
          _EnlaceQueCambio(alTocar: () => mostrarQueCambio(context, ref)),
        if (situacion.conPista) ...[
          const SizedBox(height: 6),
          PistaDescarga(
            progreso: situacion.indeterminado ? null : situacion.progreso,
          ),
        ],
      ],
    );
    final accion = _accion(ref, situacion);
    final ayuda = situacion.ayuda == null
        ? null
        : AyudaActualizacion(texto: situacion.ayuda!, sobre: 'la descarga');
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.linea2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c.tarjeta,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icono(situacion.icono, tamano: 18, color: colorIcono),
                ),
                const SizedBox(width: 10),
                Expanded(child: textos),
                ?ayuda,
                if (accion != null && !grande) ...[
                  const SizedBox(width: 8),
                  accion,
                ],
              ],
            ),
            // With large text the action goes below, as in screen 395.
            if (accion != null && grande) ...[
              const SizedBox(height: 8),
              accion,
            ],
          ],
        ),
      ),
    );
  }

  Widget? _accion(WidgetRef ref, Situacion s) {
    final accion = s.accion;
    if (accion == null) return null;
    final controller = ref.read(actualizacionProvider.notifier);
    return Boton(
      s.textoAccion ?? '',
      pequeno: true,
      estilo: s.accionPrincipal ? EstiloBoton.primario : EstiloBoton.secundario,
      alPresionar: switch (accion) {
        AccionActualizacion.actualizar => controller.actualizar,
        AccionActualizacion.cancelar => controller.cancelarDescarga,
      },
    );
  }
}

class _EnlaceQueCambio extends StatelessWidget {
  const _EnlaceQueCambio({required this.alTocar});

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: alTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Text(
            'Qué cambió',
            style: estiloTexto(15, 700, color: context.colores.moradoTinta)
                .copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: context.colores.moradoTinta,
                ),
          ),
        ),
      ),
    ),
  );
}

/// The download track (`upd-track`): its progress, or a moving bar when unknown. Without
/// animations it stays still.
class PistaDescarga extends StatelessWidget {
  const PistaDescarga({super.key, this.progreso});

  final double? progreso;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final quieta = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final valor = progreso ?? (quieta ? 1.0 : null);
    return Semantics(
      label: 'Descarga',
      value: progreso == null ? null : '${(progreso! * 100).floor()} %',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: valor,
          minHeight: 6,
          backgroundColor: c.linea,
          color: progreso == null && quieta
              ? c.moradoTinta.withValues(alpha: .5)
              : c.moradoTinta,
        ),
      ),
    );
  }
}

/// «Qué cambió en la 0.6.0» (screen 360): the size, the notes, «Actualizar» and «Ahora no».
Future<void> mostrarQueCambio(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (contexto) => Consumer(
      builder: (contexto, ref, _) {
        final estado = ref.watch(actualizacionProvider);
        final nueva = estado.nueva;
        final info = estado.info;
        if (nueva == null || info == null) return const SizedBox.shrink();
        final c = contexto.colores;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Qué cambió en la ${nueva.version}',
                  style: Theme.of(contexto).textTheme.titleLarge,
                ),
              ),
              if (nueva.tamanoBytes case final b?) ...[
                const SizedBox(height: 6),
                Text(
                  tamanoLegible(b),
                  style: estiloTexto(15, 400, color: c.tinta3),
                ),
              ],
              const SizedBox(height: 14),
              NotasVersion(nueva.notas),
              const SizedBox(height: 20),
              Boton(
                textoActualizar(info),
                icono: Ico.refresh,
                alPresionar: () {
                  Navigator.of(contexto).pop();
                  ref.read(actualizacionProvider.notifier).actualizar();
                },
              ),
              const SizedBox(height: 8),
              Boton(
                'Ahora no',
                estilo: EstiloBoton.fantasma,
                alPresionar: () => Navigator.of(contexto).pop(),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// The «Qué cambió» lines (`upd-notes`), each with a check.
class NotasVersion extends StatelessWidget {
  const NotasVersion(this.notas, {super.key});

  final List<String> notas;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final n in notas)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icono(Ico.check, tamano: 18, color: c.calmaTinta),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(n, style: estiloTexto(16, 400, color: c.tinta2)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
