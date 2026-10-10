import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/formulario.dart';
import '../data/apariencia.dart';

/// «Apariencia» from Ajustes: light, dark or the phone's theme, on this device only. The choice
/// applies at once and closes the sheet. New copy, pending review (docs/BLOCKERS.md).
Future<void> elegirApariencia(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _HojaApariencia(),
    );

class _HojaApariencia extends ConsumerWidget {
  const _HojaApariencia();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = ref.watch(aparienciaProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Apariencia',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            for (final a in Apariencia.values)
              OpcionRadio<Apariencia>(
                valor: a,
                seleccion: actual,
                titulo: a.texto,
                subtitulo: a == Apariencia.automatica
                    ? 'Sigue el tema del celular'
                    : null,
                alElegir: (v) {
                  ref.read(aparienciaProvider.notifier).elegir(v);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
