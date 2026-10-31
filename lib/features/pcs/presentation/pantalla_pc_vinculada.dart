import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../camaras/presentation/fila_camara.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/pcs_repositorio.dart';
import 'navegacion_pc.dart';
import 'piezas_pc.dart';
import 'refresco_pcs.dart';

/// «La PC Sala-Rosa está vinculada» (screens 25, 142 and 143): right after approving it, the next
/// step is choosing its cameras from the phone (US-29); without consent the cameras send nothing
/// (CA-28.1).
class PantallaPcVinculada extends ConsumerWidget {
  const PantallaPcVinculada({super.key, required this.pcId});

  final String pcId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pcs = ref.watch(pcsProvider);
    final hogar = ref.watch(hogarProvider);
    final pc = pcs.value?.where((p) => p.id == pcId).firstOrNull;
    return RefrescoPcs(
      child: Scaffold(
        appBar: AppBar(),
        body: switch ((pcs, hogar)) {
          (AsyncError(:final error), _) ||
          (_, AsyncError(:final error)) => ErrorDePantalla(
            error: error,
            alReintentar: () async => ref
              ..invalidate(pcsProvider)
              ..invalidate(hogarProvider),
          ),
          (AsyncData(), AsyncData(value: final h)) when pc != null => () {
            final texto = Theme.of(context).textTheme;
            final ahora = ref.watch(relojProvider)();
            final elegidas = pc.camaras.isNotEmpty;
            final nombre = h.adultoMayor.nombrePila;
            void seguir() => salirA(context, Rutas.pcs);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                HeroePc(
                  icono: Ico.check,
                  fondo: context.colores.calmaSuave,
                  color: context.colores.calmaTinta,
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    'La PC ${pc.nombre} está vinculada',
                    style: texto.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  elegidas
                      ? 'Sus cámaras ya están elegidas.'
                      : 'Ahora elige sus cámaras desde aquí.',
                  style: texto.bodyLarge,
                ),
                if (!h.conConsentimiento) ...[
                  const SizedBox(height: 16),
                  Aviso(
                    tono: TonoAviso.error,
                    icono: Ico.lock,
                    titulo: 'Falta el consentimiento de $nombre',
                    texto: 'Sin él, las cámaras no envían nada.',
                    accion: ref.watch(esTitularProvider)
                        ? Boton(
                            'Completar el consentimiento',
                            pequeno: true,
                            alPresionar: () =>
                                context.push(Rutas.consentimiento),
                          )
                        : null,
                  ),
                ],
                const SizedBox(height: 20),
                ListaTarjeta(
                  children: [
                    CabeceraPc(pc: pc, ahora: ahora),
                    for (final c in pc.camaras)
                      FilaCamara(
                        camara: c,
                        estado: c.estadoVisible(
                          conConsentimiento: h.conConsentimiento,
                        ),
                        alTocar: () => context.push(Rutas.camara(c.id)),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                if (elegidas)
                  Boton('Listo', alPresionar: seguir)
                else ...[
                  Boton(
                    'Elegir las cámaras',
                    icono: Ico.cam,
                    alPresionar: ref.watch(esTitularProvider)
                        ? () => context.push(Rutas.elegirCamaras(pc.id))
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Boton(
                    'Hacerlo después',
                    estilo: EstiloBoton.fantasma,
                    alPresionar: seguir,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sin cámaras elegidas no detectamos caídas.',
                    textAlign: TextAlign.center,
                    style: texto.bodySmall,
                  ),
                ],
              ],
            );
          }(),
          (AsyncData(), AsyncData()) => const SizedBox.shrink(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
