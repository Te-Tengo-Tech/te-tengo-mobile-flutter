import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/chips.dart';
import '../data/historial_provider.dart';
import 'lista_alertas.dart';

enum SeccionHistorial { alertas, resumen }

/// Selected segment of the Historial tab («Ver resumen» opens the summary).
class SeccionHistorialController extends Notifier<SeccionHistorial> {
  @override
  SeccionHistorial build() => SeccionHistorial.alertas;

  void elegir(SeccionHistorial s) => state = s;
}

final seccionHistorialProvider =
    NotifierProvider<SeccionHistorialController, SeccionHistorial>(
      SeccionHistorialController.new,
    );

/// Historial tab: alerts and weekly summary.
class PantallaHistorial extends ConsumerWidget {
  const PantallaHistorial({super.key, this.resumen});

  /// Content of the «Resumen semanal» segment.
  final Widget? resumen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seccion = ref.watch(seccionHistorialProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (seccion == SeccionHistorial.alertas &&
            n.metrics.extentAfter < 300) {
          ref.read(historialProvider.notifier).cargarMas();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(historialProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Semantics(
                header: true,
                child: Text(
                  'Historial',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            Segmentado(
              opciones: const [
                (SeccionHistorial.alertas, 'Alertas'),
                (SeccionHistorial.resumen, 'Resumen semanal'),
              ],
              valor: seccion,
              alCambiar: ref.read(seccionHistorialProvider.notifier).elegir,
            ),
            const SizedBox(height: 16),
            if (seccion == SeccionHistorial.alertas)
              const ListaHistorial()
            else
              ?resumen,
          ],
        ),
      ),
    );
  }
}
