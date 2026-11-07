import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/formulario.dart';
import '../../../l10n/l10n.dart';
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
    final l = context.l10n;
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
                l.historialFiltrarTitulo,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            grupo<RangoFecha>(
              l.historialFiltroFecha,
              [for (final r in RangoFecha.values) (r, r.texto(l))],
              f.rango,
              (v) => f.con(rango: v),
            ),
            grupo<TipoAlerta?>(
              l.historialFiltroTipo,
              [
                (null, l.historialFiltroTodas),
                (TipoAlerta.caida, l.historialFiltroCaida),
                (TipoAlerta.movimientoInestable, l.historialFiltroInestable),
              ],
              f.tipo,
              (v) => v == null ? f.con(sinTipo: true) : f.con(tipo: v),
            ),
            grupo<EstadoAlerta?>(
              l.historialFiltroEstado,
              [
                (null, l.historialFiltroTodos),
                (EstadoAlerta.activa, l.historialFiltroActiva),
                (EstadoAlerta.atendida, l.historialFiltroAtendida),
                (EstadoAlerta.falsaAlarma, l.historialFiltroFalsa),
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
                    l.historialLimpiar,
                    estilo: EstiloBoton.fantasma,
                    alPresionar: () =>
                        setState(() => _borrador = FiltroHistorial.vacio),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Boton(
                    conteo == null
                        ? l.historialVerAlertas
                        : l.historialVerConteo(conteo),
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
