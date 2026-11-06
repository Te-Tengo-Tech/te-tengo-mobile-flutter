import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../l10n/l10n.dart';
import '../data/apariencia.dart';
import '../data/contraste.dart';
import '../data/tamano_letra.dart';

/// The «Preferencias» row's subtitle (`prefLbl`): «Tema automático · letra estándar», «Tema oscuro ·
/// letra grande · más contraste».
String resumenPreferencias(AppLocalizations l, WidgetRef ref) {
  final tema = switch (ref.watch(aparienciaProvider)) {
    Apariencia.automatica => l.preferenciasResumenTemaAutomatico,
    Apariencia.clara => l.preferenciasResumenTemaClaro,
    Apariencia.oscura => l.preferenciasResumenTemaOscuro,
  };
  final letra = switch (ref.watch(tamanoLetraProvider)) {
    TamanoLetra.estandar => l.preferenciasResumenLetraEstandar,
    TamanoLetra.grande => l.preferenciasResumenLetraGrande,
  };
  return [
    tema,
    letra,
    if (ref.watch(contrasteProvider)) l.preferenciasResumenContraste,
  ].join(' · ');
}

/// «Preferencias» (Ajustes, screens 113 and 349): this phone's theme, text size and «Aumentar el
/// contraste». They apply at once, stay on this device and survive signing out; the invited member changes
/// them too. The alerts keep their color.
class PantallaPreferencias extends ConsumerWidget {
  const PantallaPreferencias({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apariencia = ref.watch(aparienciaProvider);
    final contraste = ref.watch(contrasteProvider);
    final letra = ref.watch(tamanoLetraProvider);
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.preferenciasTitulo)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          EncabezadoSeccion(l.preferenciasTema, arriba: 4),
          for (final a in Apariencia.values)
            OpcionRadio<Apariencia>(
              valor: a,
              seleccion: apariencia,
              titulo: a.texto(l),
              subtitulo: a == Apariencia.automatica
                  ? l.preferenciasIgualQueCelular
                  : null,
              alElegir: ref.read(aparienciaProvider.notifier).elegir,
            ),
          EncabezadoSeccion(l.preferenciasTamanoLetra, arriba: 18),
          for (final t in TamanoLetra.values)
            OpcionRadio<TamanoLetra>(
              valor: t,
              seleccion: letra,
              titulo: t.texto(l),
              alElegir: ref.read(tamanoLetraProvider.notifier).elegir,
            ),
          EncabezadoSeccion(l.preferenciasContraste, arriba: 18),
          ListaTarjeta(
            children: [
              MergeSemantics(
                child: FilaLista(
                  inicio: const IconoFila(Ico.contrast),
                  titulo: l.preferenciasAumentarContraste,
                  subtitulo: l.preferenciasContrasteTexto,
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
            l.preferenciasAlertasConservanColor,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
