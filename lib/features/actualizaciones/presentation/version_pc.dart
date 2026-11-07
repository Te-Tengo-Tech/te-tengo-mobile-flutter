import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../l10n/l10n.dart';
import '../../pcs/domain/pc.dart';
import '../data/actualizacion_controller.dart';
import '../domain/versiones.dart';
import '../../../core/ui/ayuda.dart';

/// The PC runs an older Te Tengo Captura than the published one for its system (CA-43.7).
bool pcConVersionAnterior(Pc pc, Versiones? versiones) =>
    estadoVersionPc(
      versiones,
      versionAgente: pc.versionAgente,
      sistemaOperativo: pc.sistemaOperativo,
    ) ==
    EstadoVersionPc.anterior;

/// «Versión anterior (0.4.3)» under a PC of «PCs de la casa» (screen 386); nothing when it is up
/// to date or unknown.
class EtiquetaVersionPc extends ConsumerWidget {
  const EtiquetaVersionPc({super.key, required this.pc});

  final Pc pc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!pcConVersionAnterior(pc, ref.watch(versionesPublicadasProvider))) {
      return const SizedBox.shrink();
    }
    return Text(
      context.l10n.actualizacionVersionAnteriorPc('${pc.versionAgente}'),
      style: estiloTexto(15, 700, color: context.colores.avisoTinta),
    );
  }
}

/// The notice of the PC's detail (screens 387 and 388): «Se actualizará sola.» when the PC updates
/// itself, or «Pide a quien está en la casa que la actualice.» when the family turned that off
/// (`actualizacionAutomatica: false`, CA-43.7). A PC that never said (`null`, an older Te Tengo
/// Captura) shows the title only **[implementation choice]**.
class AvisoVersionPc extends ConsumerWidget {
  const AvisoVersionPc({super.key, required this.pc});

  final Pc pc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!pcConVersionAnterior(pc, ref.watch(versionesPublicadasProvider))) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    final titulo = l.actualizacionVersionAnteriorPc('${pc.versionAgente}');
    final Widget aviso = switch (pc.actualizacionAutomatica) {
      true => Aviso(
        tono: TonoAviso.neutral,
        icono: Ico.refresh,
        titulo: titulo,
        texto: l.actualizacionSeActualizaraSola,
      ),
      false => Aviso(
        tono: TonoAviso.advertencia,
        icono: Ico.refresh,
        titulo: titulo,
        contenido: TextSpan(
          children: [
            TextSpan(text: l.actualizacionPideActualizar),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: AyudaInfo(
                texto: l.actualizacionPcAyuda,
                tema: l.actualizacionPcTema,
              ),
            ),
          ],
        ),
      ),
      null => Aviso(
        tono: TonoAviso.neutral,
        icono: Ico.refresh,
        titulo: titulo,
      ),
    };
    return Padding(padding: const EdgeInsets.only(top: 12), child: aviso);
  }
}

/// «Te Tengo Captura 0.4.3 · versión anterior» in the PC's header (screen 387).
InlineSpan? programaConVersion(
  BuildContext context,
  Pc pc,
  Versiones? versiones,
) {
  final programa = pc.programa;
  if (programa == null) return null;
  if (!pcConVersionAnterior(pc, versiones)) return TextSpan(text: programa);
  return TextSpan(
    children: [
      TextSpan(text: '$programa · '),
      TextSpan(
        text: context.l10n.actualizacionVersionAnterior,
        style: estiloTexto(15, 700, color: context.colores.avisoTinta),
      ),
    ],
  );
}
