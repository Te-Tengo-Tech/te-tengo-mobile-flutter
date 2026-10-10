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
import '../../hogar/data/hogar_repositorio.dart';
import '../data/familia_repositorio.dart';
import '../domain/familiar.dart';
import 'fila_miembro.dart';

/// Familia tab (screens 62, 72 and 78): who receives the alerts and in which order they answer.
class PantallaFamilia extends ConsumerWidget {
  const PantallaFamilia({super.key, this.alTocarMiembro});

  /// Member options of the owner (US-08, screen 70).
  final void Function(BuildContext, MiembroFamilia, int indice)? alTocarMiembro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final miembros = ref.watch(miembrosProvider);
    final aviso = ref.watch(avisoProvider).value;
    final titular = ref.watch(esTitularProvider);
    final yo = ref.watch(sesionControllerProvider)?.usuario.id;
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final texto = Theme.of(context).textTheme;
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
            child: Text('Familia', style: texto.headlineMedium),
          ),
          const SizedBox(height: 6),
          Text('Reciben las alertas de $nombre.', style: texto.bodyMedium),
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
    return [
      ListaTarjeta(
        children: [
          for (var i = 0; i < lista.length; i++)
            FilaMiembro(
              miembro: lista[i],
              indice: i,
              esYo: lista[i].familiar.usuarioId == yo,
              alTocar: titular && alTocarMiembro != null
                  ? () => alTocarMiembro!(context, lista[i], i)
                  : null,
            ),
        ],
      ),
      const SizedBox(height: 16),
      ListaTarjeta(
        children: [
          FilaLista(
            inicio: const IconoFila(Ico.swap),
            titulo: 'Orden de aviso y tiempo de espera',
            subtitulo: secundario == null
                ? '$pri · sin contacto secundario'
                : '$pri → ${secundario.familiar.nombrePila} · '
                      '${aviso?.esperaMinutos ?? ConfiguracionAviso.esperaPredeterminada} '
                      'min de espera',
            fin: titular
                ? null
                : Icono(Ico.lock, tamano: 22, color: context.colores.tinta3),
            alTocar: () => context.push(Rutas.ordenAviso),
          ),
        ],
      ),
      if (secundario == null) ...[
        const SizedBox(height: 16),
        Aviso(
          tono: TonoAviso.advertencia,
          icono: Ico.warn,
          titulo: 'No hay contacto secundario',
          texto: 'Si $pri no atiende a tiempo, nadie más será avisado.',
        ),
      ],
      const SizedBox(height: 20),
      if (titular)
        Boton(
          'Invitar a un familiar',
          icono: Ico.plus,
          alPresionar: () => context.push(Rutas.invitar),
        )
      else
        AvisoSoloLectura(
          titular: titularNombre,
          accion: 'invitar o retirar familiares y cambiar el orden de aviso',
        ),
    ];
  }
}
