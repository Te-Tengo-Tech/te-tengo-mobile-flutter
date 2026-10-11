import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/ilustraciones.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../camaras/presentation/estado_camara.dart';
import '../../camaras/presentation/pausa_camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/pcs_repositorio.dart';
import '../domain/camaras_en_casa.dart';
import '../domain/pc.dart';
import 'piezas_pc.dart';
import 'refresco_pcs.dart';

/// «Cámaras» (screens 144 to 152, 158, 159 and 284 to 302; Ajustes › «Cámaras y PCs»): organised by
/// room, because the family thinks in rooms, and compact with many cameras: a summary, «Necesitan
/// atención» first with one action each, the rooms that work in a grid, a filter by PC when there
/// are several, and «PCs de la casa», each opening its detail with its version and cameras
/// (CA-30.1 to CA-30.3, CA-29.5). The invited member sees it read-only.
class PantallaCamaras extends ConsumerStatefulWidget {
  const PantallaCamaras({super.key});

  @override
  ConsumerState<PantallaCamaras> createState() => _PantallaCamarasState();
}

class _PantallaCamarasState extends ConsumerState<PantallaCamaras> {
  /// The PC whose cameras are shown; null for «Todas».
  String? _filtro;

  @override
  Widget build(BuildContext context) {
    final titular = ref.watch(esTitularProvider);
    final pcs = ref.watch(pcsProvider);
    final camaras = ref.watch(camarasEnCasaProvider);
    final hogar = ref.watch(hogarProvider);
    Future<void> recargar() async => ref
      ..invalidate(pcsProvider)
      ..invalidate(camarasProvider)
      ..invalidate(hogarProvider);
    return RefrescoPcs(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cámaras'),
          actions: [
            if (!titular)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: EtiquetaSoloVer()),
              ),
          ],
        ),
        body: switch ((pcs, camaras, hogar)) {
          (AsyncError(:final error), _, _) ||
          (_, AsyncError(:final error), _) ||
          (
            _,
            _,
            AsyncError(:final error),
          ) => ErrorDePantalla(error: error, alReintentar: recargar),
          (
            AsyncData(value: final lista),
            AsyncData(value: final cs),
            AsyncData(value: final h),
          ) =>
            RefreshIndicator(
              onRefresh: recargar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [
                  if (!h.conConsentimiento) ...[
                    Aviso(
                      tono: TonoAviso.error,
                      icono: Ico.lock,
                      titulo: 'Falta el consentimiento',
                      texto: 'Sin él no detectamos caídas.',
                      accion: titular
                          ? Boton(
                              'Registrar consentimiento',
                              pequeno: true,
                              alPresionar: () =>
                                  context.push(Rutas.consentimiento),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (lista.isEmpty)
                    _SinPcs(
                      titular: titular,
                      nombreTitular: ref.watch(nombreTitularProvider) ?? '',
                    )
                  else
                    ..._pagina(
                      context,
                      lista,
                      cs,
                      h.conConsentimiento,
                      titular,
                    ),
                ],
              ),
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  List<Widget> _pagina(
    BuildContext context,
    List<Pc> pcs,
    List<CamaraEnCasa> todas,
    bool conConsentimiento,
    bool titular,
  ) {
    final varias = pcs.length > 1;
    final filtro = varias && pcs.any((p) => p.id == _filtro) ? _filtro : null;
    final visibles = pcs
        .where((p) => filtro == null || p.id == filtro)
        .toList();
    final camaras = todas
        .where((c) => filtro == null || c.camara.pcId == filtro || c.pc == null)
        .toList();
    final resumen = resumenCamaras(todas, conConsentimiento: conConsentimiento);
    final atencion = _filasAtencion(context, visibles, camaras, titular);
    final bien = camaras.where((c) => !c.necesitaAtencion).toList();
    return [
      _Resumen(resumen),
      if (varias) ...[
        const SizedBox(height: 12),
        Semantics(
          label: 'Ver las cámaras de',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (id, nombre) in [
                  (null, 'Todas'),
                  for (final p in pcs) (p.id, p.nombre),
                ]) ...[
                  ChipOpcion(
                    texto: nombre,
                    elegido: filtro == id,
                    alTocar: () => setState(() => _filtro = id),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ],
      if (atencion.isNotEmpty) ...[
        const EncabezadoSeccion('Necesitan atención'),
        ListaTarjeta(children: atencion),
      ],
      if (bien.isNotEmpty) ...[
        EncabezadoSeccion(conConsentimiento ? 'Funcionando' : 'Detenidas'),
        _Rejilla([
          for (final c in bien)
            TarjetaHabitacion(
              camara: c,
              alTocar: () => context.push(Rutas.camara(c.camara.id)),
            ),
        ]),
      ],
      const EncabezadoSeccion('PCs de la casa'),
      ListaTarjeta(
        children: [
          for (final pc in pcs)
            FilaPc(pc: pc, alTocar: () => context.push(Rutas.pc(pc.id))),
        ],
      ),
      const SizedBox(height: 16),
      if (titular) ...[
        Boton(
          'Agregar PC',
          icono: Ico.plus,
          estilo: EstiloBoton.secundario,
          alPresionar: () => context.push(Rutas.vincular),
        ),
        const SizedBox(height: 8),
        Text(
          'Una cámara por habitación.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ] else
        AvisoSoloLectura(
          titular: ref.watch(nombreTitularProvider) ?? '',
          accion: 'agregar o quitar PCs',
        ),
    ];
  }

  /// «Necesitan atención» (`attRows`): where, what happens and one action, PC by PC.
  List<Widget> _filasAtencion(
    BuildContext context,
    List<Pc> pcs,
    List<CamaraEnCasa> camaras,
    bool titular,
  ) {
    final filas = <Widget>[];
    void elegir(Pc pc) => context.push(Rutas.elegirCamaras(pc.id));
    for (final pc in pcs) {
      final propias = camaras.where((c) => c.camara.pcId == pc.id).toList();
      if (pc.sinConexion) {
        filas.add(
          FilaAtencion(
            estado: EstadoVisible.sinConexion,
            titulo: propias.isEmpty
                ? 'PC ${pc.nombre} sin conexión'
                : '${enumerar([for (final c in propias) c.habitacion])} sin '
                      'conexión',
            detalle: TextSpan(
              children: [
                TextSpan(text: 'La PC ${pc.nombre} no responde'),
                if (pc.ultimaSenal case final s?) ...[
                  const TextSpan(text: ' desde las '),
                  TextSpan(
                    text: hora(s),
                    style: estiloMono(tamano: 15, peso: 400),
                  ),
                ],
              ],
            ),
            accion: 'Qué revisar',
            alActuar: () => context.push(Rutas.pc(pc.id)),
          ),
        );
        continue;
      }
      for (final c in propias.where((c) => c.necesitaAtencion)) {
        filas.add(_filaCamara(context, c));
      }
      if (pc.camarasSinUsar > 0) {
        filas.add(
          FilaAtencion(
            estado: EstadoVisible.detenida,
            icono: Ico.plus,
            titulo: contar(
              pc.camarasSinUsar,
              'cámara sin usar',
              'cámaras sin usar',
            ),
            detalle: TextSpan(
              text:
                  'En la PC ${pc.nombre}'
                  '${titular ? ' · elige en qué habitación está' : ''}',
            ),
            accion: titular ? 'Elegir las cámaras' : null,
            alActuar: () => elegir(pc),
          ),
        );
      } else if (propias.isEmpty) {
        filas.add(
          FilaAtencion(
            estado: EstadoVisible.detenida,
            icono: Ico.pc,
            titulo: 'PC ${pc.nombre}',
            detalle: const TextSpan(text: 'Falta elegir las cámaras'),
            accion: titular ? 'Elegir las cámaras' : null,
            alActuar: () => elegir(pc),
          ),
        );
      }
    }
    // Cameras of installations older than PCs have none.
    for (final c in camaras.where((c) => c.pc == null && c.necesitaAtencion)) {
      filas.add(_filaCamara(context, c));
    }
    return filas;
  }

  Widget _filaCamara(BuildContext context, CamaraEnCasa c) {
    final camara = c.camara;
    final info = infoAtencion(c);
    final enPausa = c.estado == EstadoVisible.enPausa;
    return FilaAtencion(
      estado: c.estado,
      titulo: info.titulo,
      detalle: info.detalle,
      accion: enPausa ? 'Reanudar ahora' : 'Qué revisar',
      alActuar: enPausa
          ? () => reanudarCamara(context, ref, camara)
          : () => context.push(Rutas.camara(camara.id)),
    );
  }
}

/// What happens to a camera, in one phrase (`attInfo`): where (the title) and what (the detail).
({String titulo, InlineSpan detalle}) infoAtencion(CamaraEnCasa c) {
  final camara = c.camara;
  final mono = estiloMono(tamano: 15, peso: 400);
  return switch (c.estado) {
    EstadoVisible.sinConexion => (
      titulo: '${c.habitacion} sin conexión',
      detalle: TextSpan(text: 'La PC ${c.pc?.nombre ?? ''} no responde'),
    ),
    EstadoVisible.desconectada => (
      titulo: '${c.habitacion}: cámara desconectada',
      detalle: TextSpan(
        children: [
          if (camara.ultimaSenal case final s?) ...[
            const TextSpan(text: 'Desde las '),
            TextSpan(text: hora(s), style: mono),
          ],
        ],
      ),
    ),
    EstadoVisible.enPausa => (
      titulo: '${c.habitacion} en pausa',
      detalle: TextSpan(
        text: 'Hasta las ${hora(camara.pausadaHasta!)} · se reactiva sola',
      ),
    ),
    _ => (
      titulo: 'Detección no confiable · ${c.habitacion}',
      detalle: const TextSpan(text: 'Revisa la luz y el encuadre'),
    ),
  };
}

/// «4 cámaras · todas funcionan bien» with a round state icon (`camSummary`).
class _Resumen extends StatelessWidget {
  const _Resumen(this.resumen);

  final ({bool ok, String cuantas, String estado}) resumen;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = resumen.ok ? c.calmaTinta : c.aviso;
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: resumen.ok ? c.calmaSuave : c.avisoSuave,
              shape: BoxShape.circle,
            ),
            child: Icono(
              resumen.ok ? Ico.check : Ico.warn,
              tamano: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: resumen.cuantas,
                    style: estiloTexto(18, 800, color: c.tinta),
                  ),
                  if (resumen.estado.isNotEmpty)
                    TextSpan(text: ' · ${resumen.estado}'),
                ],
              ),
              style: estiloTexto(17, 400, color: c.tinta2),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of «Necesitan atención» (`attRow`): the action goes under the text, so large text does not
/// cut it.
class FilaAtencion extends StatelessWidget {
  const FilaAtencion({
    super.key,
    required this.estado,
    required this.titulo,
    required this.detalle,
    required this.accion,
    required this.alActuar,
    this.icono,
  });

  final EstadoVisible estado;

  /// Instead of the state's icon («cámaras sin usar», «Falta elegir las cámaras»).
  final Ico? icono;
  final String titulo;
  final InlineSpan detalle;

  /// Null for the invited member when only the owner can act.
  final String? accion;
  final VoidCallback alActuar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icono == null)
          IconoEstadoCamara(estado: estado)
        else
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colores.fondo2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icono(icono!, tamano: 22, color: context.colores.tinta3),
          ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: estiloTexto(17, 700, color: context.colores.tinta),
              ),
              Text.rich(
                detalle,
                style: estiloTexto(15, 400, color: context.colores.tinta3),
              ),
              if (accion != null) ...[
                const SizedBox(height: 10),
                Boton(
                  accion!,
                  estilo: EstiloBoton.secundario,
                  pequeno: true,
                  alPresionar: alActuar,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// The grid of rooms (`.room-grid`): 2 columns, 1 with large text.
class _Rejilla extends StatelessWidget {
  const _Rejilla(this.tarjetas);

  final List<Widget> tarjetas;

  @override
  Widget build(BuildContext context) {
    final grande = MediaQuery.textScalerOf(context).scale(16) > 24;
    final columnas = grande ? 1 : 2;
    return LayoutBuilder(
      builder: (context, limites) {
        const espacio = 12.0;
        final ancho = (limites.maxWidth - espacio * (columnas - 1)) / columnas;
        return Wrap(
          spacing: espacio,
          runSpacing: espacio,
          children: [
            for (final t in tarjetas) SizedBox(width: ancho, child: t),
          ],
        );
      },
    );
  }
}

/// A room that works (`roomCard`): its illustration without people, its name and its state. Opens
/// the camera's detail.
class TarjetaHabitacion extends StatelessWidget {
  const TarjetaHabitacion({
    super.key,
    required this.camara,
    required this.alTocar,
  });

  final CamaraEnCasa camara;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final estado = camara.estado;
    final color = estado.colorEn(c);
    return Semantics(
      button: true,
      label: '${camara.habitacion}, ${estado.texto}',
      excludeSemantics: true,
      child: Material(
        color: c.tarjeta,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alTocar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Habitacion(
                  // «Dormitorio 2» draws a bedroom.
                  nombre: camara.habitacion.replaceAll(RegExp(r'\s*\d+$'), ''),
                  postura: Postura.ninguna,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camara.habitacion,
                      style: estiloTexto(16, 700, color: c.tinta),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icono(
                          estado == EstadoVisible.enLinea
                              ? Ico.check
                              : estado.icono,
                          tamano: 16,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            estado.texto,
                            style: estiloTexto(14, 700, color: color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A PC in «PCs de la casa» (`pcRow`): «3 cámaras · En línea», «1 cámara · Sin conexión» or
/// «Falta elegir las cámaras».
class FilaPc extends StatelessWidget {
  const FilaPc({super.key, required this.pc, required this.alTocar});

  final Pc pc;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final estado = EstadoPc.de(pc);
    final n = pc.camaras.length;
    return FilaLista(
      inicio: IconoPc(estado: estado, tamano: 40),
      titulo: pc.nombre,
      subtituloRico: switch (estado) {
        EstadoPc.faltanCamaras => TextSpan(
          text: 'Falta elegir las cámaras',
          style: estiloTexto(15, 700, color: c.moradoTinta),
        ),
        EstadoPc.sinConexion => TextSpan(
          children: [
            TextSpan(text: '${contar(n, 'cámara', 'cámaras')} · '),
            TextSpan(
              text: 'Sin conexión',
              style: estiloTexto(15, 700, color: c.aviso),
            ),
          ],
        ),
        EstadoPc.enLinea => TextSpan(
          children: [
            TextSpan(text: '${contar(n, 'cámara', 'cámaras')} · '),
            TextSpan(
              text: 'En línea',
              style: estiloTexto(15, 700, color: c.calmaTinta),
            ),
          ],
        ),
      },
      alTocar: alTocar,
    );
  }
}

/// «Aún no hay una PC vinculada» (screen 148).
class _SinPcs extends StatelessWidget {
  const _SinPcs({required this.titular, required this.nombreTitular});

  final bool titular;
  final String nombreTitular;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: Column(
        children: [
          IconoGrande(
            icono: Ico.pc,
            fondo: context.colores.moradoSuave,
            color: context.colores.moradoTinta,
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no hay una PC vinculada',
            textAlign: TextAlign.center,
            style: texto.titleLarge,
          ),
          const SizedBox(height: 16),
          if (titular)
            Boton(
              'Agregar PC',
              icono: Ico.plus,
              alPresionar: () => context.push(Rutas.vincular),
            )
          else
            AvisoSoloLectura(titular: nombreTitular, accion: 'agregar una PC'),
        ],
      ),
    );
  }
}
