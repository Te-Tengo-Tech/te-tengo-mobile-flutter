import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../data/apariencia.dart';
import '../data/contraste.dart';

/// The «Preferencias» row's subtitle (`prefLbl`): «Tema automático», «Tema oscuro · más
/// contraste». The prototype also names the text size; the app follows the phone's (docs/BLOCKERS.md).
String resumenPreferencias(WidgetRef ref) {
  final tema = 'Tema ${ref.watch(aparienciaProvider).texto.toLowerCase()}';
  return ref.watch(contrasteProvider) ? '$tema · más contraste' : tema;
}

/// «Preferencias» (Ajustes, screens 113 and 349): this phone's theme and «Aumentar el contraste».
/// Both apply at once, stay on this device and survive signing out; the invited member changes
/// them too. The alerts keep their color.
class PantallaPreferencias extends ConsumerWidget {
  const PantallaPreferencias({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apariencia = ref.watch(aparienciaProvider);
    final contraste = ref.watch(contrasteProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          const EncabezadoSeccion('Tema', arriba: 4),
          for (final a in Apariencia.values)
            OpcionRadio<Apariencia>(
              valor: a,
              seleccion: apariencia,
              titulo: a.texto,
              subtitulo: a == Apariencia.automatica
                  ? 'Igual que tu celular'
                  : null,
              alElegir: ref.read(aparienciaProvider.notifier).elegir,
            ),
          const EncabezadoSeccion('Contraste', arriba: 18),
          ListaTarjeta(
            children: [
              MergeSemantics(
                child: FilaLista(
                  inicio: const IconoFila(Ico.contrast),
                  titulo: 'Aumentar el contraste',
                  subtitulo: 'Texto y bordes más marcados',
                  chevron: false,
                  alTocar: () =>
                      ref.read(contrasteProvider.notifier).cambiar(!contraste),
                  fin: Switch(
                    value: contraste,
                    onChanged: ref.read(contrasteProvider.notifier).cambiar,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colores.calma,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: context.colores.pistaApagada,
                    trackOutlineColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Las alertas conservan su color.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
