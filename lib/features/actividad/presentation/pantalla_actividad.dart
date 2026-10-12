import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/ayuda.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/tarjeta.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../familia/presentation/fila_miembro.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../data/actividad_repositorio.dart';
import '../domain/actividad.dart';

/// «Hoy», «Ayer» or «08/10/2026» (`dayLbl`).
String etiquetaDia(DateTime dia, DateTime hoy) => mismoDia(dia, hoy)
    ? 'Hoy'
    : mismoDia(dia, hoy.subtract(const Duration(days: 1)))
    ? 'Ayer'
    : fechaNumerica(dia);

/// «Último cambio: hoy 10:33», «… ayer 18:44», «… el 08/10/2026 18:44» (Ajustes).
String resumenUltimoCambio(Actividad? a, DateTime hoy) {
  if (a == null) return 'Aún no hay actividad';
  final dia = etiquetaDia(a.ocurridaEn, hoy);
  final d = dia == 'Hoy' || dia == 'Ayer' ? dia.toLowerCase() : 'el $dia';
  return 'Último cambio: $d ${hora(a.ocurridaEn)}';
}

/// «Actividad» (screens 215 to 220, US-33): who changed what and when, in the app or on a PC,
/// grouped by day, filtered by PC (CA-33.2); nobody can edit or delete it. The invited member
/// reads the same.
class PantallaActividad extends ConsumerStatefulWidget {
  const PantallaActividad({super.key});

  @override
  ConsumerState<PantallaActividad> createState() => _PantallaActividadState();
}

class _PantallaActividadState extends ConsumerState<PantallaActividad> {
  /// The PC chip; null is «Todas».
  String? _pcId;

  @override
  Widget build(BuildContext context) {
    final actividad = ref.watch(actividadProvider(_pcId));
    final pcs = ref.watch(pcsProvider).value ?? const [];
    final hoy = ref.watch(relojProvider)();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: AyudaInfo(
              texto: 'Nadie puede borrar ni cambiar este registro.',
              tema: 'registro de actividad',
            ),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 300) {
            ref.read(actividadProvider(_pcId).notifier).cargarMas();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(actividadProvider(_pcId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              if (pcs.isNotEmpty &&
                  (_pcId != null ||
                      (actividad.value?.elementos.isNotEmpty ?? false)))
                Semantics(
                  container: true,
                  label: 'Filtrar por PC',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (id, nombre) in [
                        (null, 'Todas'),
                        for (final p in pcs) (p.id, p.nombre),
                      ])
                        ChipOpcion(
                          texto: nombre,
                          elegido: _pcId == id,
                          alTocar: () => setState(() => _pcId = id),
                        ),
                    ],
                  ),
                ),
              ...switch (actividad) {
                AsyncData(value: final p) when p.elementos.isEmpty => const [
                  EstadoVacio(
                    ilustracion: IlustracionVacio.filtro,
                    titulo: 'Aún no hay actividad registrada',
                    texto: 'Aquí verás cada cambio en PCs, cámaras y datos.',
                  ),
                ],
                AsyncData(value: final p) => [
                  for (final (dia, grupo) in _porDia(p.elementos)) ...[
                    EncabezadoDia(etiquetaDia(dia, hoy)),
                    ListaTarjeta(
                      children: [for (final a in grupo) FilaActividad(a)],
                    ),
                  ],
                  if (p.cargandoMas)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
                AsyncError(:final error) => [
                  const SizedBox(height: 16),
                  MensajeProblema(error),
                  const SizedBox(height: 12),
                  Boton(
                    'Volver a intentarlo',
                    icono: Ico.refresh,
                    estilo: EstiloBoton.secundario,
                    alPresionar: () => ref.invalidate(actividadProvider(_pcId)),
                  ),
                ],
                _ => const [SizedBox(height: 12), _Cargando()],
              },
            ],
          ),
        ),
      ),
    );
  }

  /// Entries grouped by local day, keeping the newest-first order.
  static List<(DateTime, List<Actividad>)> _porDia(List<Actividad> lista) {
    final grupos = <(DateTime, List<Actividad>)>[];
    for (final a in lista) {
      if (grupos.isEmpty || !mismoDia(grupos.last.$1, a.ocurridaEn)) {
        grupos.add((a.ocurridaEn, [a]));
      } else {
        grupos.last.$2.add(a);
      }
    }
    return grupos;
  }
}

/// A row (`actRow`): the member's avatar or the PC's icon, the sentence and the time; it opens
/// the detail.
class FilaActividad extends ConsumerWidget {
  const FilaActividad(this.actividad, {super.key});

  final Actividad actividad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = actividad;
    final miembros = ref.watch(miembrosProvider).value ?? const [];
    final i = miembros.indexWhere((m) => m.familiar.usuarioId == a.usuarioId);
    final nombre = ref.watch(nombreAdultoMayorProvider) ?? '';
    return FilaLista(
      inicio: switch (a.actor) {
        _ when a.esActualizacion => const IconoFila(Ico.refresh),
        TipoActor.familiar => Avatar(
          Avatar.inicialesDe(a.usuario ?? '?'),
          tono: tonoDe(i < 0 ? 0 : i),
        ),
        TipoActor.pc => const IconoFila(Ico.pc),
        TipoActor.sistema => const IconoFila(Ico.shield),
      },
      titulo: a.frase(adultoMayor: nombre),
      fin: Text(
        hora(a.ocurridaEn),
        style: estiloMono(tamano: 15, peso: 400, color: context.colores.tinta3),
      ),
      alTocar: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => HojaActividad(a),
      ),
    );
  }
}

/// The detail of a change (screen 217): who, from where, before, after, date and time.
class HojaActividad extends ConsumerWidget {
  const HojaActividad(this.actividad, {super.key});

  final Actividad actividad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = actividad;
    final (antes, despues) = a.antesYDespues;
    final repeticion = a.momentoYDuracion;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              a.frase(adultoMayor: ref.watch(nombreAdultoMayorProvider) ?? ''),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          DatosTarjeta([
            FilaDato(clave: 'Quién', valor: a.quien),
            FilaDato(clave: 'Desde', valor: a.desde),
            if (repeticion case (final momento, final visto)) ...[
              FilaDato(clave: 'Momento', valor: momento),
              FilaDato(clave: 'Duración', valor: visto),
            ] else ...[
              FilaDato(clave: 'Antes', valor: antes),
              FilaDato(clave: 'Después', valor: despues),
            ],
            FilaDato(
              clave: 'Fecha y hora',
              valor: '',
              valorRico: TextSpan(
                children: [
                  TextSpan(text: '${fechaNumerica(a.ocurridaEn)} · '),
                  TextSpan(
                    text: hora(a.ocurridaEn),
                    style: const TextStyle(fontFamily: fuenteMono),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Boton(
            'Cerrar',
            estilo: EstiloBoton.secundario,
            alPresionar: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Four gray rows while the log loads (screen 218).
class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    final gris = context.colores.fondo2;
    Widget barra(double ancho, double alto) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        color: gris,
        borderRadius: BorderRadius.circular(6),
      ),
    );
    return Semantics(
      label: 'Cargando actividad',
      child: ExcludeSemantics(
        child: ListaTarjeta(
          children: [
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: gris,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FractionallySizedBox(
                            widthFactor: 0.85,
                            child: barra(double.infinity, 16),
                          ),
                          const SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: 0.5,
                            child: barra(double.infinity, 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    barra(40, 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
