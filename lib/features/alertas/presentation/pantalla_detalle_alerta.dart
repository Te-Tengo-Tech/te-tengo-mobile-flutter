import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/formato.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/domain/camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/alertas_repositorio.dart';
import '../domain/alerta.dart';
import 'clip_evento.dart';
import 'etiquetas.dart';
import 'linea_de_tiempo.dart';

/// Detail of a marked or past alert (screens 56, 60, 61, 76, 89–91): who marked it and when
/// (CA-19.1, CA-19.3), the recording and the record.
class PantallaDetalleAlerta extends ConsumerWidget {
  const PantallaDetalleAlerta({super.key, required this.alertaId});

  final String alertaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerta = ref.watch(alertaProvider(alertaId));
    ref.listen(alertaProvider(alertaId), (_, a) {
      // An active alert takes the whole screen.
      if (a.value case final a? when a.activa) {
        context.pushReplacement(Rutas.alerta(a.id));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          alerta.value == null
              ? 'Alerta'
              : 'Alerta del ${fechaCorta(alerta.value!.ocurridaEn)}',
        ),
      ),
      body: alerta.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorDePantalla(
          error: e,
          alReintentar: () => ref.refresh(alertaProvider(alertaId).future),
        ),
        data: (a) => _Detalle(alerta: a),
      ),
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.alerta});

  final Alerta alerta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = alerta;
    final yo = ref.watch(sesionControllerProvider)?.usuario;
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final otro =
        !a.activa &&
        a.atendidaPor != null &&
        a.atendidaEn != null &&
        (a.atendidaPorId != null
            ? a.atendidaPorId != yo?.id
            : a.atendidaPor != yo?.nombre);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        if (otro) ...[
          Aviso(
            tono: TonoAviso.ok,
            icono: Ico.check,
            titulo:
                '${a.atendidaPor!.split(' ').first} '
                '${a.estado == EstadoAlerta.falsaAlarma ? 'la marcó como falsa alarma' : 'ya atendió esta alerta'}',
            contenido: conHora(
              'A las ',
              hora(a.atendidaEn!),
              '. Toda la familia ve quién la atendió y a qué hora.',
            ),
          ),
          const SizedBox(height: 16),
        ],
        TarjetaDetalle(alerta: a),
        const EncabezadoSeccion('Grabación'),
        ClipEvento(alerta: a),
        const EncabezadoSeccion('Registro'),
        TarjetaBanda(
          child: LineaDeTiempo(
            itemsDeAlerta(
              a,
              nombreAdultoMayor: nombre,
              avisados: avisadosDe(miembros),
              secundario: secundarioDe(miembros),
              esperaMinutos: esperaDe(ref),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card of an alert (`detailCard`): band, kind and state, title, date and who marked it.
class TarjetaDetalle extends StatelessWidget {
  const TarjetaDetalle({super.key, required this.alerta});

  final Alerta alerta;

  @override
  Widget build(BuildContext context) {
    final a = alerta;
    final texto = Theme.of(context).textTheme;
    final falsa = a.estado == EstadoAlerta.falsaAlarma;
    return TarjetaBanda(
      banda: falsa
          ? Banda.pausa
          : a.esCaida
          ? Banda.caida
          : Banda.inestable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [EtiquetaTipo(a.tipo), SelloEstado(a)],
          ),
          const SizedBox(height: 12),
          Text(
            '${a.tipo.nombre} ${enHabitacion(a.habitacion)}',
            style: texto.titleLarge,
          ),
          const SizedBox(height: 8),
          Text.rich(
            conHora(
              '${mayusculaInicial(fechaLarga(a.ocurridaEn))} · ',
              hora(a.ocurridaEn),
            ),
            style: texto.bodyMedium,
          ),
          if (!a.activa) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(height: 1),
            ),
            Text(
              falsa ? 'Marcada como falsa alarma' : 'Marcada como atendida',
              style: texto.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (a.atendidaEn != null)
              Text.rich(
                conHora(
                  'por ${a.atendidaPor ?? ''} a las ',
                  hora(a.atendidaEn!),
                ),
                style: texto.bodyMedium,
              ),
            if (falsa) ...[
              const SizedBox(height: 8),
              Text(
                'No cuenta en el resumen de caídas.',
                style: texto.bodySmall,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
