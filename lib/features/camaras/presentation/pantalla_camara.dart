import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';
import 'cabecera_camara.dart';

/// Camera detail (screens 30–32): header with the state, what to do, live view and room name.
class PantallaCamara extends ConsumerWidget {
  const PantallaCamara({super.key, required this.camaraId});

  final String camaraId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camaras = ref.watch(camarasProvider);
    final hogar = ref.watch(hogarProvider);
    final camara = camaras.value?.where((c) => c.id == camaraId).firstOrNull;
    Future<void> recargar() async {
      ref
        ..invalidate(camarasProvider)
        ..invalidate(hogarProvider);
      await ref.read(camarasProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          camara == null ? 'Cámara' : 'Cámara · ${camara.nombreHabitacion}',
        ),
      ),
      body: switch ((camaras, hogar)) {
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          ErrorDePantalla(error: error, alReintentar: recargar),
        (AsyncData(), AsyncData(value: final h)) when camara != null =>
          RefreshIndicator(
            onRefresh: recargar,
            child: _Detalle(
              camara: camara,
              estado: camara.estadoVisible(
                conConsentimiento: h.conConsentimiento,
              ),
              nombreAdultoMayor: h.adultoMayor.nombrePila,
            ),
          ),
        (AsyncData(), AsyncData()) => const SizedBox.shrink(),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({
    required this.camara,
    required this.estado,
    required this.nombreAdultoMayor,
  });

  final Camara camara;
  final EstadoVisible estado;
  final String nombreAdultoMayor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titular = ref.watch(esTitularProvider);
    final habitacion = camara.nombreHabitacion;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        CabeceraCamara(
          camara: camara,
          estado: estado,
          ahora: ref.watch(relojProvider)(),
        ),
        const EncabezadoSeccion('Habitación'),
        ListaTarjeta(
          children: [
            if (titular)
              FilaLista(
                inicio: const IconoFila(Ico.pin),
                titulo: habitacion,
                subtitulo: 'Cambiar el nombre que aparece en las alertas',
                alTocar: () => context.push(
                  Uri(
                    path: Rutas.nombreCamara(camara.id),
                    queryParameters: {'actual': habitacion},
                  ).toString(),
                ),
              )
            else
              FilaLista(
                inicio: const IconoFila(Ico.pin),
                titulo: habitacion,
                subtitulo: 'Nombre que aparece en las alertas',
                fin: const EtiquetaSoloVer(),
              ),
          ],
        ),
        if (!titular) ...[
          const SizedBox(height: 12),
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'cambiar el nombre de la habitación',
          ),
        ],
      ],
    );
  }
}
