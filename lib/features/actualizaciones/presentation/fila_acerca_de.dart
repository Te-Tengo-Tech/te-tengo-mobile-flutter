import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../data/actualizacion_controller.dart';
import 'rutas_actualizaciones.dart';

/// Ajustes › «Acerca de Te Tengo» (screen 379): «Versión 0.5.0 · hay una nueva».
class FilaAcercaDe extends ConsumerWidget {
  const FilaAcercaDe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(actualizacionProvider);
    final info = estado.info;
    return FilaLista(
      inicio: const IconoFila(Ico.info),
      titulo: 'Acerca de Te Tengo',
      subtituloRico: info == null
          ? null
          : TextSpan(
              children: [
                TextSpan(text: 'Versión ${info.version}'),
                if (estado.nueva != null) ...[
                  const TextSpan(text: ' · '),
                  TextSpan(
                    text: 'hay una nueva',
                    style: estiloTexto(
                      15,
                      700,
                      color: context.colores.moradoTinta,
                    ),
                  ),
                ],
              ],
            ),
      alTocar: () => context.push(RutasActualizaciones.acercaDe),
    );
  }
}

/// The version under Ajustes: «Te Tengo 0.5.0».
class PieVersion extends ConsumerWidget {
  const PieVersion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(actualizacionProvider).info?.version;
    return Text(
      version == null ? 'Te Tengo' : 'Te Tengo $version',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
