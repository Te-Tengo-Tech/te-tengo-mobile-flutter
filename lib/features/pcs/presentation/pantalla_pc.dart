import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/dialogo.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/presentation/fila_camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/pcs_repositorio.dart';
import '../domain/camaras_en_casa.dart';
import '../../actualizaciones/presentation/version_pc.dart';
import '../domain/pc.dart';
import 'navegacion_pc.dart';
import 'piezas_pc.dart';
import 'refresco_pcs.dart';

/// A PC's detail (screens 153 to 157 and 264, 276): its state, system, program, who linked it and
/// its last signal, what to check when it does not answer, its cameras, «Elegir las cámaras» and
/// «Quitar esta PC» (CA-30.2, CA-30.3, CA-31.1, CA-31.2, CA-31.4). The invited member sees it
/// without the options (CA-31.5).
class PantallaPc extends ConsumerWidget {
  const PantallaPc({super.key, required this.pcId});

  final String pcId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pcs = ref.watch(pcsProvider);
    final hogar = ref.watch(hogarProvider);
    final pc = pcs.value?.where((p) => p.id == pcId).firstOrNull;
    return RefrescoPcs(
      child: Scaffold(
        appBar: AppBar(title: Text(pc?.nombre ?? 'PC')),
        body: switch ((pcs, hogar)) {
          (AsyncError(:final error), _) ||
          (_, AsyncError(:final error)) => ErrorDePantalla(
            error: error,
            alReintentar: () async => ref
              ..invalidate(pcsProvider)
              ..invalidate(hogarProvider),
          ),
          (AsyncData(), AsyncData(value: final h)) when pc != null => _Detalle(
            pc: pc,
            conConsentimiento: h.conConsentimiento,
          ),
          (AsyncData(), AsyncData()) => const SizedBox.shrink(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.pc, required this.conConsentimiento});

  final Pc pc;
  final bool conConsentimiento;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texto = Theme.of(context).textTheme;
    final titular = ref.watch(esTitularProvider);
    final ahora = ref.watch(relojProvider)();
    final camaras = camarasEnCasa(pc.camaras, [
      pc,
    ], conConsentimiento: conConsentimiento);
    final senal = pc.ultimaSenal;
    final por = pc.vinculadaPor;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        TarjetaBanda(
          relleno: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CabeceraPc(pc: pc, ahora: ahora),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                child: DatosTarjeta([
                  if (pc.sistemaOperativo case final so?)
                    FilaDato(clave: 'Sistema', valor: so),
                  if (pc.programa case final programa?)
                    FilaDato(clave: 'Programa', valor: programa),
                  if (pc.vinculadaEn case final en?)
                    FilaDato(
                      clave: 'Vinculada',
                      valor:
                          '${fechaNumerica(en)}'
                          '${por == null ? '' : ' por ${por.nombre.split(' ').first}'}',
                    ),
                  if (senal != null)
                    FilaDato(
                      clave: 'Última señal',
                      valor: hora(senal),
                      mono: true,
                    ),
                ]),
              ),
            ],
          ),
        ),
        AvisoVersionPc(pc: pc),
        if (pc.sinConexion) ...[
          const EncabezadoSeccion('Qué revisar'),
          const QueRevisarPc(),
        ],
        const EncabezadoSeccion('Cámaras de esta PC'),
        if (camaras.isEmpty)
          Aviso(
            tono: TonoAviso.info,
            icono: Ico.cam,
            titulo: 'Falta elegir las cámaras',
            accion: titular && !pc.sinConexion
                ? Boton(
                    'Elegir las cámaras',
                    pequeno: true,
                    alPresionar: () => context.push(Rutas.elegirCamaras(pc.id)),
                  )
                : null,
          )
        else
          ListaTarjeta(
            children: [
              for (final c in camaras)
                FilaCamara(
                  camara: c.camara,
                  estado: c.estado,
                  alTocar: () => context.push(Rutas.camara(c.camara.id)),
                ),
              if (titular && !pc.sinConexion)
                FilaLista(
                  inicio: const IconoFila(Ico.cam),
                  titulo: 'Elegir las cámaras',
                  subtitulo: pc.camarasSinUsar > 0
                      ? contar(
                          pc.camarasSinUsar,
                          'cámara sin usar',
                          'cámaras sin usar',
                        )
                      : 'Usa otra cámara o deja de usar una',
                  alTocar: () => context.push(Rutas.elegirCamaras(pc.id)),
                ),
            ],
          ),
        if (titular) ...[
          const EncabezadoSeccion('Quitar'),
          Text('Deja de detectar caídas con esta PC.', style: texto.bodyMedium),
          const SizedBox(height: 12),
          Boton(
            'Quitar esta PC',
            icono: Ico.trash,
            estilo: EstiloBoton.peligroContorno,
            alPresionar: () => quitarPc(context, ref, pc),
          ),
        ] else ...[
          const SizedBox(height: 20),
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'elegir las cámaras o quitar esta PC',
          ),
        ],
      ],
    );
  }
}

/// «Quitar esta PC» (screens 157 to 159): asks first, naming the rooms that stop being watched
/// (CA-31.4); then the app stops showing it and its cameras at once (CA-31.1, CA-31.2).
Future<void> quitarPc(BuildContext context, WidgetRef ref, Pc pc) async {
  final habitaciones = [for (final c in pc.camaras) c.nombreHabitacion];
  final si = await confirmar(
    context,
    icono: Ico.pc,
    titulo: '¿Quitar la PC ${pc.nombre}?',
    texto:
        '${habitaciones.isEmpty ? '' : 'Dejaremos de detectar caídas en ${enumerar(habitaciones)}. '}'
        'La PC volverá a mostrar su QR.',
    aceptar: 'Quitar la PC',
    cancelar: 'Cancelar',
    peligro: true,
  );
  if (!si || !context.mounted) return;
  try {
    await ref.read(pcsRepositorioProvider).quitar(pc.id);
  } on ProblemaApi catch (e) {
    if (e.codigo != 'PC_NO_ENCONTRADA') {
      if (context.mounted) {
        mostrarToast(
          context,
          titulo: e.codigo == ProblemaApi.sinConexion
              ? 'Sin internet'
              : e.detalle,
          texto: e.codigo == ProblemaApi.sinConexion
              ? 'Revisa tu conexión y vuelve a intentarlo.'
              : null,
          icono: Ico.warn,
          tono: TonoAviso.advertencia,
        );
      }
      return;
    }
    // Already gone (removed from the PC itself): the list just catches up.
  }
  ref
    ..invalidate(pcsProvider)
    ..invalidate(camarasProvider)
    ..invalidate(ambientesProvider);
  if (!context.mounted) return;
  mostrarToast(
    context,
    titulo: 'Quitamos la PC ${pc.nombre}',
    texto: pc.sinConexion ? 'Dejará de capturar en cuanto se conecte.' : null,
    icono: Ico.pc,
  );
  salirA(context, Rutas.pcs);
}
