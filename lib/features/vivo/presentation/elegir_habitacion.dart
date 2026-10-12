import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/ui/ayuda.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../camaras/data/orden_camaras.dart';
import '../../camaras/domain/camara.dart';
import '../../camaras/presentation/favorita.dart';
import '../../camaras/presentation/estado_camara.dart';
import '../../pcs/domain/camaras_en_casa.dart';
import 'pantalla_vivo.dart' show textoPrivacidadVivo;

/// «Ver en vivo» from Inicio: one camera opens directly; with several, «¿Qué habitación quieres
/// ver?» (screens 166, 293, 294).
void verEnVivo(BuildContext context, List<CamaraEnCasa> camaras) {
  if (camaras.length == 1) {
    context.push(_vivo(camaras.single));
    return;
  }
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => HojaElegirHabitacion(camaras: camaras),
  );
}

String _vivo(CamaraEnCasa c) =>
    Uri(path: Rutas.vivo, queryParameters: {'camara': c.camara.id}).toString();

/// Why a room cannot be watched now (`liveWhy`): «En pausa hasta las 11:42», «Sin conexión · la PC
/// Cocina-Rosa no responde», «Desconectada desde las 10:31», «Detenida · sin consentimiento».
InlineSpan porQueNoEnVivo(CamaraEnCasa c) {
  final camara = c.camara;
  return switch (c.estado) {
    EstadoVisible.enPausa => TextSpan(
      text: 'En pausa hasta las ${hora(camara.pausadaHasta!)}',
    ),
    EstadoVisible.sinConexion => TextSpan(
      text: 'Sin conexión · la PC ${c.pc?.nombre ?? ''} no responde',
    ),
    EstadoVisible.desconectada => TextSpan(
      children: [
        const TextSpan(text: 'Desconectada'),
        if (camara.ultimaSenal case final s?) ...[
          const TextSpan(text: ' desde las '),
          TextSpan(text: hora(s), style: estiloMono(tamano: 15, peso: 400)),
        ],
      ],
    ),
    EstadoVisible.detenida => const TextSpan(
      text: 'Detenida · sin consentimiento',
    ),
    _ => TextSpan(text: c.estado.texto),
  };
}

/// «¿Qué habitación quieres ver?»: the rooms that can be watched first; the others disabled but
/// readable, with the reason (a camera whose PC is offline cannot open the live view).
class HojaElegirHabitacion extends ConsumerWidget {
  const HojaElegirHabitacion({super.key, required this.camaras});

  /// In the order of this phone, favourites first (CA-41.4).
  final List<CamaraEnCasa> camaras;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orden = ref.watch(ordenCamarasProvider);
    Widget? estrella(CamaraEnCasa c) =>
        orden.esFavorita(c.camara.id) ? const MarcaFavorita() : null;
    final texto = Theme.of(context).textTheme;
    final ordenadas = [
      ...camaras.where((c) => c.vivoDisponible),
      ...camaras.where((c) => !c.vivoDisponible),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  child: Semantics(
                    header: true,
                    child: Text(
                      '¿Qué habitación quieres ver?',
                      style: texto.titleLarge,
                    ),
                  ),
                ),
                const AyudaInfo(texto: textoPrivacidadVivo, tema: 'privacidad'),
              ],
            ),
            const SizedBox(height: 12),
            ListaTarjeta(
              borde: true,
              children: [
                for (final c in ordenadas)
                  if (c.vivoDisponible)
                    FilaLista(
                      inicio: const IconoEstadoCamara(
                        estado: EstadoVisible.enLinea,
                        icono: Ico.video,
                      ),
                      titulo: c.habitacion,
                      marcaTitulo: estrella(c),
                      subtitulo: 'Disponible ahora',
                      alTocar: () {
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop();
                        router.push(_vivo(c));
                      },
                    )
                  else
                    Semantics(
                      enabled: false,
                      child: FilaLista(
                        inicio: IconoEstadoCamara(estado: c.estado),
                        titulo: c.habitacion,
                        marcaTitulo: estrella(c),
                        subtituloRico: TextSpan(
                          style: estiloTexto(
                            15,
                            400,
                            color: context.colores.tinta3,
                          ),
                          children: [porQueNoEnVivo(c)],
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
