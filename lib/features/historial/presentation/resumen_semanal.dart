import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../alertas/domain/alerta.dart';
import '../../alertas/presentation/etiquetas.dart';
import '../data/resumen_repositorio.dart';
import '../domain/resumen_semanal.dart';

/// «Resumen semanal» (screens 92 and 93): the events of each day, the counts by kind and how each
/// changed against the previous week (US-27).
class VistaResumenSemanal extends ConsumerWidget {
  const VistaResumenSemanal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desplazamiento = ref.watch(semanaElegidaProvider);
    final resumen = ref.watch(resumenSemanalProvider(desplazamiento));
    final hoy = ref.watch(relojProvider)();
    final lunes = lunesDe(hoy).add(Duration(days: 7 * desplazamiento));
    final domingo = lunes.add(const Duration(days: 6));
    final lunesAnterior = lunes.subtract(const Duration(days: 7));
    final domingoAnterior = lunes.subtract(const Duration(days: 1));
    final texto = Theme.of(context).textTheme;
    final control = ref.read(semanaElegidaProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Semana anterior',
              icon: const Icono(Ico.chevL, color: Colores.tinta),
              onPressed: () => control.mover(-1),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    switch (desplazamiento) {
                      0 => 'Esta semana',
                      -1 => 'Semana pasada',
                      _ => 'Hace ${-desplazamiento} semanas',
                    },
                    textAlign: TextAlign.center,
                    style: estiloTexto(18, 800),
                  ),
                  Text(
                    '${rangoDias(lunes, domingo)}'
                    '${desplazamiento == 0 ? ' · hasta hoy' : ' ${domingo.year}'}',
                    textAlign: TextAlign.center,
                    style: texto.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Semana siguiente',
              icon: Icono(
                Ico.chevR,
                color: desplazamiento >= 0 ? Colores.linea2 : Colores.tinta,
              ),
              onPressed: desplazamiento >= 0 ? null : () => control.mover(1),
            ),
          ],
        ),
        ...switch (resumen) {
          AsyncData(value: final r) => [
            if (r.conteos.total == 0)
              const EstadoVacio(
                ilustracion: IlustracionVacio.semana,
                titulo: 'Semana sin eventos',
                texto: 'No hubo caídas ni movimientos inestables.',
              )
            else ...[
              const SizedBox(height: 12),
              _Dias(desplazamiento: desplazamiento, lunes: lunes, hoy: hoy),
            ],
            EncabezadoSeccion(
              'Por tipo',
              arriba: 22,
              accion: Text(
                'vs. ${rangoDias(lunesAnterior, domingoAnterior, corto: true)}',
                style: estiloTexto(15, 600, color: Colores.tinta3),
              ),
            ),
            ListaTarjeta(
              children: [
                _FilaConteo(
                  tipo: TipoAlerta.caida,
                  titulo: 'Caídas',
                  actual: r.conteos.caidas,
                  anterior: r.semanaAnterior.caidas,
                  tendencia: r.tendenciaCaidas,
                ),
                _FilaConteo(
                  tipo: TipoAlerta.movimientoInestable,
                  titulo: 'Movimientos inestables',
                  actual: r.conteos.movimientosInestables,
                  anterior: r.semanaAnterior.movimientosInestables,
                  tendencia: r.tendenciaInestables,
                ),
                _FilaConteo(
                  tipo: TipoAlerta.caida,
                  falsa: true,
                  titulo: 'Falsas alarmas',
                  actual: r.conteos.falsasAlarmas,
                  anterior: r.semanaAnterior.falsasAlarmas,
                  tendencia: r.tendenciaFalsas,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Las falsas alarmas no suman a caídas ni a inestables.',
              style: texto.bodySmall,
            ),
          ],
          AsyncError(:final error) => [
            const SizedBox(height: 12),
            MensajeProblema(error),
          ],
          _ => const [
            Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        },
      ],
    );
  }
}

/// Day grid (`.week`): the mark of each event under its day.
class _Dias extends ConsumerWidget {
  const _Dias({
    required this.desplazamiento,
    required this.lunes,
    required this.hoy,
  });

  final int desplazamiento;
  final DateTime lunes;
  final DateTime hoy;

  static const _iniciales = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertas =
        ref.watch(alertasDeSemanaProvider(desplazamiento)).value ?? const [];
    return Semantics(
      label: 'Eventos por día',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        decoration: BoxDecoration(
          color: Colores.tarjeta,
          borderRadius: BorderRadius.circular(24),
          boxShadow: sombraTarjeta,
        ),
        child: Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: _Dia(
                  inicial: _iniciales[i],
                  dia: lunes.add(Duration(days: i)),
                  hoy: hoy,
                  alertas: alertas
                      .where(
                        (a) => mismoDia(
                          a.ocurridaEn,
                          lunes.add(Duration(days: i)),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({
    required this.inicial,
    required this.dia,
    required this.hoy,
    required this.alertas,
  });

  final String inicial;
  final DateTime dia;
  final DateTime hoy;
  final List<Alerta> alertas;

  @override
  Widget build(BuildContext context) {
    final esHoy = mismoDia(dia, hoy);
    return ExcludeSemantics(
      child: Column(
        children: [
          Text(inicial, style: estiloTexto(14, 700, color: Colores.tinta3)),
          const SizedBox(height: 8),
          Container(
            height: 82,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: esHoy ? Colores.moradoSuave : Colores.fondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (final a in alertas.take(3))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: MarcaAlerta(
                      tipo: a.tipo,
                      falsa: a.estado == EstadoAlerta.falsaAlarma,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('${dia.day}', style: estiloMono(tamano: 13)),
        ],
      ),
    );
  }
}

/// Count of one kind with its trend (`.count-row`): amber when falls or unstable movements
/// increase, green when they decrease (DESIGN.md).
class _FilaConteo extends StatelessWidget {
  const _FilaConteo({
    required this.tipo,
    required this.titulo,
    required this.actual,
    required this.anterior,
    required this.tendencia,
    this.falsa = false,
  });

  final TipoAlerta tipo;
  final bool falsa;
  final String titulo;
  final int actual;
  final int anterior;
  final Tendencia tendencia;

  @override
  Widget build(BuildContext context) {
    final (icono, color, texto) = switch (tendencia) {
      Tendencia.igual => (Ico.equal, Colores.tinta3, 'Igual ($anterior)'),
      Tendencia.aumento => (
        Ico.up,
        falsa ? Colores.tinta3 : Colores.aviso,
        'Subió de $anterior a $actual',
      ),
      Tendencia.disminucion => (
        Ico.down,
        Colores.calmaTinta,
        'Bajó de $anterior a $actual',
      ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              '$actual',
              textAlign: TextAlign.center,
              style: estiloMono(tamano: 32, peso: 700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MarcaAlerta(tipo: tipo, falsa: falsa),
                    const SizedBox(width: 8),
                    Flexible(child: Text(titulo, style: estiloTexto(18, 700))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icono(icono, tamano: 16, color: color),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        texto,
                        style: estiloTexto(15, 700, color: color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «Esta semana» on the home screen (`.wk`): one card with three large figures in mono (falls,
/// unstable movements and false alarms). The last event lives in the history.
class SemanaEnInicio extends ConsumerWidget {
  const SemanaEnInicio({super.key, required this.alVerResumen});

  final VoidCallback alVerResumen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenSemanalProvider(0)).value;
    if (resumen == null) return const SizedBox.shrink();
    final c = resumen.conteos;
    Widget cifra(int n, Widget marca, String singular, String plural) =>
        Semantics(
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$n',
                style: estiloMono(tamano: 28, peso: 600).copyWith(height: 1.1),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  marca,
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      n == 1 ? singular : plural,
                      style: estiloTexto(15, 400, color: Colores.tinta2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EncabezadoSeccion(
          'Esta semana',
          accion: Enlace('Ver resumen', alTocar: alVerResumen),
        ),
        ListaTarjeta(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: cifra(
                      c.caidas,
                      const MarcaAlerta(tipo: TipoAlerta.caida),
                      'caída',
                      'caídas',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: cifra(
                      c.movimientosInestables,
                      const MarcaAlerta(tipo: TipoAlerta.movimientoInestable),
                      'inestable',
                      'inestables',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: cifra(
                      c.falsasAlarmas,
                      const MarcaAlerta(tipo: TipoAlerta.caida, falsa: true),
                      'falsa',
                      'falsas',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
