import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../pcs/domain/pc.dart';
import '../data/actualizacion_controller.dart';
import '../domain/versiones.dart';
import 'ayuda.dart';

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
      'Versión anterior (${pc.versionAgente})',
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
    final titulo = 'Versión anterior (${pc.versionAgente})';
    final Widget aviso = switch (pc.actualizacionAutomatica) {
      true => Aviso(
        tono: TonoAviso.neutral,
        icono: Ico.refresh,
        titulo: titulo,
        texto: 'Se actualizará sola.',
      ),
      false => Aviso(
        tono: TonoAviso.advertencia,
        icono: Ico.refresh,
        titulo: titulo,
        contenido: const TextSpan(
          children: [
            TextSpan(text: 'Pide a quien está en la casa que la actualice. '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: AyudaActualizacion(
                texto:
                    'En la PC aparece «Hay una versión nueva»: que elijan '
                    '«Descargar». Se instala sola y la detección sigue.',
                sobre: 'cómo actualizar la PC',
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
        text: 'versión anterior',
        style: estiloTexto(15, 700, color: context.colores.avisoTinta),
      ),
    ],
  );
}
