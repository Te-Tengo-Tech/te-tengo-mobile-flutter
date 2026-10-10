import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../core/formato.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/plegable.dart';
import '../../../core/ui/tarjeta.dart';
import '../../camaras/domain/camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/ui/botones.dart';
import '../data/alertas_repositorio.dart';
import '../data/descarga_grabacion.dart';
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
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final linea = itemsDeAlerta(
      a,
      nombreAdultoMayor: nombre,
      avisados: avisadosDe(miembros),
      secundario: secundarioDe(miembros),
      esperaMinutos: esperaDe(ref),
    );
    // Who marked it and when is in the card: no notice repeats it.
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        TarjetaDetalle(alerta: a),
        const EncabezadoSeccion('Grabación'),
        ClipEvento(alerta: a),
        if (a.clip == EstadoClip.disponible) _Descarga(alerta: a),
        const SizedBox(height: 20),
        ListaTarjeta(
          children: [
            FilaPlegable(
              icono: Ico.clock,
              titulo: 'Registro del evento',
              resumen: '${linea.length} momentos',
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LineaDeTiempo(linea),
              ),
            ),
          ],
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

/// «Descargar grabación» (screens 89 and 90, CA-26.2): asks for the download link and saves the file.
class _Descarga extends ConsumerStatefulWidget {
  const _Descarga({required this.alerta});

  final Alerta alerta;

  @override
  ConsumerState<_Descarga> createState() => _DescargaState();
}

class _DescargaState extends ConsumerState<_Descarga> {
  bool _descargando = false;

  Future<void> _descargar() async {
    final a = widget.alerta;
    setState(() => _descargando = true);
    try {
      final enlace = await ref
          .read(alertasRepositorioProvider)
          .clip(a.id, descarga: true);
      final nombre = await ref.read(guardarArchivoProvider)(
        Uri.parse(enlace.url),
        nombreGrabacion(a),
      );
      if (!mounted) return;
      mostrarToast(
        context,
        titulo: 'Grabación descargada',
        texto: '$nombre en Archivos',
        icono: Ico.download,
      );
    } on Object catch (e) {
      if (!mounted) return;
      // A recording removed meanwhile (410 CLIP_ELIMINADO) shows as deleted (CA-26.3).
      if (e is ProblemaApi && e.codigo == 'CLIP_ELIMINADO') {
        ref.invalidate(alertaProvider(a.id));
      }
      mostrarToast(
        context,
        titulo: textoDeError(e),
        icono: Ico.warn,
        tono: TonoAviso.advertencia,
      );
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 12),
      Boton(
        'Descargar grabación',
        icono: Ico.download,
        estilo: EstiloBoton.secundario,
        cargando: _descargando,
        alPresionar: _descargar,
      ),
      const SizedBox(height: 8),
      Text(
        'MP4 · 12 s · disponible hasta el '
        '${fechaConAnio(widget.alerta.ocurridaEn.add(const Duration(days: 30)))}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
