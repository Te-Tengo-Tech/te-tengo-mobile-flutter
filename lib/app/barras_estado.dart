import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../core/dispositivo/conectividad.dart';
import '../features/alertas/data/alertas_repositorio.dart';
import '../features/camaras/domain/camara.dart';
import 'rutas.dart';
import '../core/ui/iconos.dart';
import 'tema/colores.dart';
import 'tema/paleta.dart';
import 'tema/tema.dart';
import '../l10n/l10n.dart';

/// «Tu celular no tiene internet» (screen 27), above every tab.
class BarraSinInternet extends ConsumerWidget {
  const BarraSinInternet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(sinInternetProvider).value != true) {
      return const SizedBox.shrink();
    }
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.colores.inversa,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icono(
              Ico.wifiOff,
              tamano: 22,
              color: context.colores.oscura
                  ? Colores.aviso
                  : const Color(0xFFFFC76B),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.nucleoSinInternetTitulo,
                    style: estiloTexto(
                      16,
                      700,
                      color: context.colores.sobreInversa,
                    ),
                  ),
                  Text(
                    context.l10n.nucleoSinInternetTexto,
                    style: estiloTexto(
                      15,
                      400,
                      color: context.colores.sobreInversa,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Active alert strip above the tabs (`strip`): opens the alert.
class FranjaAlertaActiva extends ConsumerWidget {
  const FranjaAlertaActiva({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerta = ref.watch(alertaActivaProvider).value;
    if (alerta == null) return const SizedBox.shrink();
    final caida = alerta.esCaida;
    final color = caida ? Colors.white : Colores.tinta;
    final l = context.l10n;
    final titulo = l.nucleoAlertaTitulo(
      !caida
          ? 'inestable'
          : alerta.sigueEnElSuelo
          ? 'confirmada'
          : 'posible',
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Material(
        color: caida ? Colores.caida : Colores.inestable,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(Rutas.alerta(alerta.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
            child: Row(
              children: [
                Icono(
                  caida ? Ico.fall : Ico.unsteady,
                  tamano: 22,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$titulo ${l.nucleoEnHabitacion(conArticulo(alerta.habitacion), alerta.habitacion)}',
                        style: estiloTexto(16, 700, color: color),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: l.nucleoAlertaActivaDesde),
                            TextSpan(
                              text: l.formato.hora(alerta.ocurridaEn),
                              style: estiloMono(tamano: 15, color: color),
                            ),
                          ],
                        ),
                        style: estiloTexto(15, 400, color: color),
                      ),
                    ],
                  ),
                ),
                Icono(Ico.chevR, tamano: 22, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
