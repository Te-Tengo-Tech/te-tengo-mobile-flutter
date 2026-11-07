import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../l10n/l10n.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/familia_repositorio.dart';
import '../domain/familiar.dart';
import 'fila_miembro.dart';

/// Familia tab (screens 62, 72 and 78): who receives the alerts and in which order they answer.
class PantallaFamilia extends ConsumerWidget {
  const PantallaFamilia({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miembros = ref.watch(miembrosProvider);
    final aviso = ref.watch(avisoProvider).value;
    final titular = ref.watch(esTitularProvider);
    final yo = ref.watch(sesionControllerProvider)?.usuario.id;
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final texto = Theme.of(context).textTheme;
    final l = context.l10n;
    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(familiaresProvider)
          ..invalidate(avisoProvider);
        await ref.read(familiaresProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        children: [
          Semantics(
            header: true,
            child: Text(l.familiaTitulo, style: texto.headlineMedium),
          ),
          const SizedBox(height: 6),
          Text(l.familiaReciben(nombre), style: texto.bodyMedium),
          const SizedBox(height: 16),
          ...switch (miembros) {
            AsyncData(value: final lista) => _contenido(
              context,
              lista,
              aviso,
              titular: titular,
              yo: yo,
              titularNombre: ref.watch(nombreTitularProvider) ?? '',
            ),
            AsyncError(:final error) => [MensajeProblema(error)],
            _ => const [Center(child: CircularProgressIndicator())],
          },
        ],
      ),
    );
  }

  List<Widget> _contenido(
    BuildContext context,
    List<MiembroFamilia> lista,
    ConfiguracionAviso? aviso, {
    required bool titular,
    required String? yo,
    required String titularNombre,
  }) {
    final principal = lista
        .where((m) => m.papel == PapelAviso.principal)
        .firstOrNull;
    final secundario = lista
        .where((m) => m.papel == PapelAviso.secundario)
        .firstOrNull;
    final pri = principal?.familiar.nombrePila ?? '';
    final l = context.l10n;
    return [
      ListaTarjeta(
        children: [
          for (var i = 0; i < lista.length; i++)
            FilaMiembro(
              miembro: lista[i],
              indice: i,
              esYo: lista[i].familiar.usuarioId == yo,
              alTocar: () =>
                  context.push(Rutas.familiar(lista[i].familiar.usuarioId)),
            ),
        ],
      ),
      const SizedBox(height: 16),
      ListaTarjeta(
        children: [
          FilaLista(
            inicio: const IconoFila(Ico.swap),
            titulo: l.familiaOrdenFila,
            subtitulo: secundario == null
                ? l.familiaOrdenSinSecundario(pri)
                : l.familiaOrdenResumen(
                    pri,
                    secundario.familiar.nombrePila,
                    aviso?.esperaMinutos ??
                        ConfiguracionAviso.esperaPredeterminada,
                  ),
            fin: titular
                ? null
                : Icono(Ico.lock, tamano: 22, color: context.colores.icono),
            alTocar: () => context.push(Rutas.ordenAviso),
          ),
        ],
      ),
      if (secundario == null) ...[
        const SizedBox(height: 16),
        Aviso(
          tono: TonoAviso.advertencia,
          icono: Ico.warn,
          titulo: l.familiaSinSecundarioTitulo,
          texto: l.familiaSinSecundarioTexto(pri),
        ),
      ],
      const SizedBox(height: 20),
      if (titular)
        Boton(
          l.familiaInvitar,
          icono: Ico.plus,
          alPresionar: () => context.push(Rutas.invitar),
        )
      else
        AvisoSoloLectura(
          titular: titularNombre,
          accion: l.familiaSoloLecturaInvitar,
        ),
    ];
  }
}
