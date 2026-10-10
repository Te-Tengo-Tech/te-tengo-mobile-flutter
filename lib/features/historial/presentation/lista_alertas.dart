import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../alertas/domain/alerta.dart';
import '../../alertas/presentation/etiquetas.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../data/historial_provider.dart';
import '../domain/filtro_historial.dart';
import 'hoja_filtros.dart';

/// History list (screens 83–88): date, time, room, kind and state of each alert (CA-25.1),
/// filters (CA-25.2), «Sin eventos registrados» (CA-25.3) and a loading state.
class ListaHistorial extends ConsumerWidget {
  const ListaHistorial({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historial = ref.watch(historialProvider);
    final filtro = ref.watch(filtroHistorialProvider);
    final hoy = ref.watch(relojProvider)();
    final hijos = switch (historial) {
      AsyncData(value: final p) when p.alertas.isEmpty && filtro.activos == 0 =>
        const [
          EstadoVacio(
            ilustracion: IlustracionVacio.calendario,
            titulo: 'Sin eventos registrados',
            texto: 'Aquí verás cada caída y movimiento inestable.',
          ),
        ],
      AsyncData(value: final p) => [
        _Filtros(filtro: filtro),
        if (p.alertas.isEmpty)
          EstadoVacio(
            ilustracion: IlustracionVacio.filtro,
            titulo: 'Ninguna alerta coincide',
            texto: 'Prueba con otro rango de fechas, tipo o estado.',
            accion: Boton(
              'Quitar filtros',
              estilo: EstiloBoton.secundario,
              alPresionar: () => ref
                  .read(filtroHistorialProvider.notifier)
                  .aplicar(FiltroHistorial.vacio),
            ),
          )
        else
          ..._porDia(
            p.alertas,
            hoy,
            // The room only tells something apart when there is more than one camera.
            conHabitacion: (ref.watch(camarasProvider).value?.length ?? 0) > 1,
          ),
        if (p.cargandoMas)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
      AsyncError(:final error) => [MensajeProblema(error)],
      _ => const [_Cargando()],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: hijos,
    );
  }

  /// Alerts grouped by local day (`.day-h` + `.list`).
  List<Widget> _porDia(
    List<Alerta> alertas,
    DateTime hoy, {
    required bool conHabitacion,
  }) {
    final grupos = <(DateTime, List<Alerta>)>[];
    for (final a in alertas) {
      if (grupos.isEmpty || !mismoDia(grupos.last.$1, a.ocurridaEn)) {
        grupos.add((a.ocurridaEn, [a]));
      } else {
        grupos.last.$2.add(a);
      }
    }
    return [
      for (final (dia, lista) in grupos) ...[
        EncabezadoDia('${mismoDia(dia, hoy) ? 'Hoy, ' : ''}${fechaLarga(dia)}'),
        ListaTarjeta(
          children: [
            for (final a in lista)
              FilaAlerta(alerta: a, conHabitacion: conHabitacion),
          ],
        ),
      ],
    ];
  }
}

class _Filtros extends ConsumerWidget {
  const _Filtros({required this.filtro});

  final FiltroHistorial filtro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final control = ref.read(filtroHistorialProvider.notifier);
    final n = filtro.activos;
    final chips = <(String, FiltroHistorial)>[
      if (filtro.rango != RangoFecha.todo)
        (filtro.rango.texto, filtro.con(rango: RangoFecha.todo)),
      if (filtro.tipo case final t?)
        (etiquetaTipo(t), filtro.con(sinTipo: true)),
      if (filtro.estado case final e?)
        (etiquetaEstado(e), filtro.con(sinEstado: true)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChipOpcion(
          texto: n == 0 ? 'Filtrar' : 'Filtrar ($n)',
          icono: Ico.filter,
          alTocar: () => abrirFiltros(context),
        ),
        for (final (texto, sin) in chips)
          ChipOpcion(
            texto: texto,
            elegido: true,
            iconoFinal: Ico.x,
            etiqueta: 'Quitar filtro $texto',
            alTocar: () => control.aplicar(sin),
          ),
      ],
    );
  }
}

/// History row (`.alert-row`): time, mark, «Caída» or «Inestable», who marked it («por Carmen»,
/// or «Sin marcar») and the state stamp. The room shows only with [conHabitacion].
class FilaAlerta extends StatelessWidget {
  const FilaAlerta({
    super.key,
    required this.alerta,
    this.conHabitacion = false,
  });

  final Alerta alerta;

  /// More than one camera: the room tells the rows apart.
  final bool conHabitacion;

  @override
  Widget build(BuildContext context) {
    final a = alerta;
    final quien = a.atendidaPor?.split(' ').first;
    final marcada = a.activa
        ? 'Sin marcar'
        : quien == null
        ? ''
        : 'por $quien';
    final detalle = [
      if (conHabitacion) a.habitacion,
      if (marcada.isNotEmpty) marcada,
    ].join(' · ');
    // With large text the stamp goes under the room instead of at the end of the row.
    final grande = MediaQuery.textScalerOf(context).scale(16) > 24;
    return InkWell(
      onTap: () => context.push(
        a.activa ? Rutas.alerta(a.id) : Rutas.detalleAlerta(a.id),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 52),
                child: Text(hora(a.ocurridaEn), style: estiloMono(tamano: 16)),
              ),
              const SizedBox(width: 4),
              MarcaAlerta(
                tipo: a.tipo,
                falsa: a.estado == EstadoAlerta.falsaAlarma,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.esCaida ? 'Caída' : 'Inestable',
                      style: estiloTexto(17, 700),
                    ),
                    if (detalle.isNotEmpty)
                      Text(
                        detalle,
                        style: estiloTexto(14, 400, color: Colores.tinta3),
                      ),
                    if (grande) ...[const SizedBox(height: 6), SelloEstado(a)],
                  ],
                ),
              ),
              if (!grande) ...[const SizedBox(width: 8), SelloEstado(a)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading skeleton (screen 88).
class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    Widget hueso(double ancho, double alto, [double radio = 9]) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        color: Colores.fondo2,
        borderRadius: BorderRadius.circular(radio),
      ),
    );
    return Semantics(
      label: 'Cargando historial',
      liveRegion: true,
      child: ListaTarjeta(
        children: [
          for (var i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: Row(
                children: [
                  hueso(44, 18),
                  const SizedBox(width: 12),
                  hueso(18, 18, 5),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: .7,
                          child: hueso(double.infinity, 16),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: .4,
                          child: hueso(double.infinity, 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  hueso(78, 24, 6),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
