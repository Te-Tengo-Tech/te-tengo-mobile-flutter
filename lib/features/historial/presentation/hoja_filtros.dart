import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/formulario.dart';
import '../../alertas/domain/alerta.dart';
import '../data/historial_provider.dart';
import '../domain/filtro_historial.dart';

/// Screen 84: filter the alerts by date, kind and state (CA-25.2).
Future<void> abrirFiltros(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => const _HojaFiltros(),
);

class _HojaFiltros extends ConsumerStatefulWidget {
  const _HojaFiltros();

  @override
  ConsumerState<_HojaFiltros> createState() => _HojaFiltrosState();
}

class _HojaFiltrosState extends ConsumerState<_HojaFiltros> {
  late FiltroHistorial _borrador = ref.read(filtroHistorialProvider);

  @override
  Widget build(BuildContext context) {
    final f = _borrador;
    final conteo = ref.watch(conteoFiltroProvider(f)).value;
    Widget grupo<T>(
      String titulo,
      List<(T, String)> opciones,
      T actual,
      FiltroHistorial Function(T) con,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        EtiquetaCampo(titulo),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (v, texto) in opciones)
              ChipOpcion(
                texto: texto,
                elegido: v == actual,
                alTocar: () => setState(() => _borrador = con(v)),
              ),
          ],
        ),
      ],
    );
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
                'Filtrar alertas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            grupo<RangoFecha>(
              'Fecha',
              [for (final r in RangoFecha.values) (r, r.texto)],
              f.rango,
              (v) => f.con(rango: v),
            ),
            grupo<TipoAlerta?>(
              'Tipo',
              const [
                (null, 'Todas'),
                (TipoAlerta.caida, 'Caída'),
                (TipoAlerta.movimientoInestable, 'Movimiento inestable'),
              ],
              f.tipo,
              (v) => v == null ? f.con(sinTipo: true) : f.con(tipo: v),
            ),
            grupo<EstadoAlerta?>(
              'Estado',
              const [
                (null, 'Todos'),
                (EstadoAlerta.activa, 'Activa'),
                (EstadoAlerta.atendida, 'Atendida'),
                (EstadoAlerta.falsaAlarma, 'Falsa alarma'),
              ],
              f.estado,
              (v) => v == null ? f.con(sinEstado: true) : f.con(estado: v),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Boton(
                    'Limpiar',
                    estilo: EstiloBoton.fantasma,
                    alPresionar: () =>
                        setState(() => _borrador = FiltroHistorial.vacio),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Boton(
                    conteo == null
                        ? 'Ver alertas'
                        : 'Ver $conteo alerta${conteo == 1 ? '' : 's'}',
                    alPresionar: () {
                      ref.read(filtroHistorialProvider.notifier).aplicar(f);
                      Navigator.of(context).pop();
                    },
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
