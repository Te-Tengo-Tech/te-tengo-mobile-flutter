import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/ayuda.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../../core/ui/plegable.dart';
import '../../../l10n/l10n.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../alertas/domain/alerta.dart';
import '../../alertas/presentation/etiquetas.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../movimientos/data/fuente_fotogramas.dart';
import '../../movimientos/data/movimientos_repositorio.dart';
import '../../movimientos/domain/movimientos.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../../pcs/domain/pc.dart';
import '../../pcs/presentation/acciones_camara.dart';
import '../../pcs/presentation/piezas_pc.dart';
import '../../repeticion/data/repeticiones_repositorio.dart';
import '../../repeticion/presentation/piezas_reproductor.dart';
import '../../repeticion/presentation/reproductor_camara.dart';
import '../../vivo/data/registro_accesos.dart';
import '../../vivo/presentation/pantalla_accesos.dart';
import '../../vivo/presentation/preparar_vivo.dart';
import '../data/camaras_repositorio.dart';
import '../domain/camara.dart';
import 'pausa_camara.dart';

/// The days with events of a camera in the last two weeks («Elegir día…»).
final diasConEventosProvider = FutureProvider.autoDispose
    .family<Set<DateTime>, String>((ref, camaraId) async {
      final ahora = ref.read(relojProvider)();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      final p = await ref
          .watch(alertasRepositorioProvider)
          .listar(
            FiltroAlertas(
              desde: hoy.subtract(const Duration(days: 13)),
              tamano: FiltroAlertas.tamanoMaximo,
            ),
          );
      return {
        for (final a in p.elementos)
          if (a.camaraId == camaraId)
            DateTime(a.ocurridaEn.year, a.ocurridaEn.month, a.ocurridaEn.day),
      };
    });

/// Camera detail, player first (screens 35, 168, 199 to 211, 303 to 312; PRODUCT.md, «Detalle de
/// la cámara con el reproductor primero»): the stored movements as a skeleton, never video, with
/// the timeline and its events, «En vivo», the state and what to check, the day and range filters,
/// the events of the day, and everything else in «Ajustes de la cámara».
class PantallaCamara extends ConsumerStatefulWidget {
  const PantallaCamara({super.key, required this.camaraId, this.momento});

  final String camaraId;

  /// Open the player at this moment (an alert's «Ver qué pasó», «Abrir de nuevo»).
  final DateTime? momento;

  @override
  ConsumerState<PantallaCamara> createState() => _PantallaCamaraState();
}

class _PantallaCamaraState extends ConsumerState<PantallaCamara> {
  ReproductorCamara? _reproductor;
  late final AvisosFlotantes _avisos;
  late final ProviderContainer _contenedor;
  final _claveAjustes = GlobalKey();
  var _ajustesAbiertos = 0;

  /// The texts, kept for the notice shown after the screen is gone.
  late AppLocalizations _l;

  @override
  void initState() {
    super.initState();
    _avisos = ref.read(avisoFlotanteProvider.notifier);
    _contenedor = ProviderScope.containerOf(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l = context.l10n;
  }

  @override
  void dispose() {
    final r = _reproductor;
    _reproductor = null;
    if (r != null) {
      final habitacion = r.habitacion;
      final l = _l;
      unawaited(
        r.cerrar().then((dura) {
          if (dura == null) return;
          // The app may be gone (its container disposed): then nobody is left to tell.
          try {
            _contenedor.invalidate(accesosRepeticionesProvider);
            _avisos.mostrar(
              AvisoFlotante(
                titulo: l.accesosRegistrado,
                texto: l.camaraRepeticionAcceso(
                  deHabitacion(habitacion, l),
                  l.formato.duracion(dura),
                ),
                icono: Ico.eye,
              ),
            );
          } on Object {
            // Nothing to show.
          }
        }),
      );
      r.dispose();
    }
    super.dispose();
  }

  /// The player, once the camera and the cloud's dates are known.
  ReproductorCamara _crear(Camara camara, MovimientosEnLaNube nube) {
    final r = ReproductorCamara(
      camaraId: camara.id,
      habitacion: camara.nombreHabitacion,
      repeticiones: ref.read(repeticionesRepositorioProvider),
      alertas: ref.read(alertasRepositorioProvider),
      reloj: ref.read(relojProvider),
      fuente: ref.read(fuenteFotogramasProvider),
      momento: widget.momento,
      datosDesde: nube.datosDesde,
      avisar: (t) {
        if (mounted) mostrarToast(context, titulo: t, icono: Ico.info);
      },
      textos: context.l10n,
    );
    unawaited(r.iniciar());
    return r;
  }

  void _abrirAjustes() {
    setState(() => _ajustesAbiertos++);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _claveAjustes.currentContext;
      if (c != null) {
        unawaited(Scrollable.ensureVisible(c, alignment: 0.1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final camaras = ref.watch(camarasProvider);
    final hogar = ref.watch(hogarProvider);
    final camara = camaras.value
        ?.where((c) => c.id == widget.camaraId)
        .firstOrNull;
    final pc = ref
        .watch(pcsProvider)
        .value
        ?.where((p) => p.id == camara?.pcId)
        .firstOrNull;
    Future<void> recargar() async {
      ref
        ..invalidate(camarasProvider)
        ..invalidate(hogarProvider);
      await ref.read(camarasProvider.future);
    }

    return PrepararVivo(
      camaraId: widget.camaraId,
      child: Scaffold(
        appBar: AppBar(
          title: Text(camara?.nombreHabitacion ?? context.l10n.camaraTitulo),
          actions: [
            if (camara != null)
              IconButton(
                tooltip: context.l10n.camaraAjustes,
                onPressed: _abrirAjustes,
                icon: Icono(Ico.puntos, color: context.colores.icono),
              ),
          ],
        ),
        body: switch ((camaras, hogar)) {
          (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
            ErrorDePantalla(error: error, alReintentar: recargar),
          (AsyncData(), AsyncData(value: final h)) when camara != null =>
            _detalle(
              context,
              camara: camara,
              pc: pc,
              estado: camara.estadoVisible(
                conConsentimiento: h.conConsentimiento,
                pcSinConexion: pc?.sinConexion ?? false,
              ),
              conConsentimiento: h.conConsentimiento,
              nombre: h.adultoMayor.nombrePila,
            ),
          (AsyncData(), AsyncData()) => const SizedBox.shrink(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _detalle(
    BuildContext context, {
    required Camara camara,
    required Pc? pc,
    required EstadoVisible estado,
    required bool conConsentimiento,
    required String nombre,
  }) {
    final titular = ref.watch(esTitularProvider);
    final nube = ref.watch(movimientosEnLaNubeProvider);
    final hoy = ref.watch(relojProvider)();
    final titularNombre = ref.watch(nombreTitularProvider) ?? '';
    final l = context.l10n;
    final enVivo = BotonEnVivo(
      habitacion: camara.nombreHabitacion,
      alTocar: () => context.push(
        Uri(
          path: Rutas.vivo,
          queryParameters: {'camara': camara.id},
        ).toString(),
      ),
    );
    final n = nube.value;
    final conMovimientos =
        conConsentimiento &&
        n != null &&
        n.consentimientoVigente &&
        n.retencionDias != null;
    if (conMovimientos && _reproductor == null) {
      _reproductor = _crear(camara, n);
    }
    final r = _reproductor;
    if (r != null) {
      r.corte = switch (estado) {
        EstadoVisible.sinConexion when pc?.ultimaSenal != null => (
          desde: pc!.ultimaSenal!,
          motivo: l.camaraPcNoRespondeMotivo,
        ),
        EstadoVisible.desconectada when camara.ultimaSenal != null => (
          desde: camara.ultimaSenal!,
          motivo: l.camaraDesconectadaMotivo,
        ),
        _ => null,
      };
    }
    Widget? accionActivar(String ruta) => titular
        ? Boton(
            l.camaraActivar,
            pequeno: true,
            alPresionar: () => context.push(ruta),
          )
        : Text(
            l.camaraSoloTitularActiva(titularNombre),
            style: estiloTexto(14, 600, color: context.colores.tinta2),
          );
    return ListenableBuilder(
      listenable: r ?? ValueNotifier(0),
      builder: (context, _) {
        final datos =
            conMovimientos && r != null && r.iniciado && !r.fueraDePlazo;
        final Widget escenario = switch (nube) {
          _ when !conConsentimiento => EscenarioApagado(
            icono: Ico.lock,
            texto: l.camaraDetenidaSinConsentimiento,
            enVivo: enVivo,
            accion: titular
                ? Boton(
                    l.camaraRegistrarConsentimiento,
                    pequeno: true,
                    alPresionar: () => context.push(Rutas.consentimiento),
                  )
                : null,
          ),
          AsyncError(:final error)
              when error is ProblemaApi &&
                  error.codigo == ProblemaApi.sinConexion =>
            EscenarioApagado(
              icono: Ico.wifiOff,
              texto: l.camaraSinInternet,
              enVivo: enVivo,
            ),
          AsyncData(value: final v) when !v.consentimientoVigente =>
            EscenarioApagado(
              icono: Ico.body,
              texto: l.camaraActivaGuardarMovimientos,
              enVivo: enVivo,
              accion: accionActivar(Rutas.movimientos),
            ),
          AsyncError() => EscenarioApagado(
            icono: Ico.body,
            texto: l.camaraActivaGuardarMovimientos,
            enVivo: enVivo,
            accion: accionActivar(Rutas.movimientos),
          ),
          AsyncData(value: final v) when v.retencionDias == null =>
            EscenarioApagado(
              icono: Ico.cloud,
              texto: l.camaraActivaNube,
              enVivo: enVivo,
              accion: accionActivar(Rutas.nube),
            ),
          _ when r != null && r.iniciado && r.fueraDePlazo => EscenarioApagado(
            icono: Ico.clock,
            texto: l.camaraNoHayMovimientos(
              diaMes(r.dia, l.formato),
              l.formato.fechaNumerica(r.datosDesde!),
            ),
            enVivo: enVivo,
            accion: Boton(
              l.camaraVerLoUltimo,
              pequeno: true,
              estilo: EstiloBoton.secundario,
              alPresionar: () => unawaited(r.verLoUltimo()),
            ),
          ),
          _ when datos => EscenarioMovimientos(
            reproductor: r,
            hoy: hoy,
            enVivo: enVivo,
            nombreAdultoMayor: nombre,
          ),
          _ => EscenarioApagado(
            icono: Ico.clock,
            texto: l.camaraCargando,
            enVivo: enVivo,
          ),
        };
        final habilitado = datos && r.estado == EstadoReproductor.listo;
        final arriba = <Widget>[
          escenario,
          if (datos) ...[
            LineaDeTiempoReproductor(reproductor: r, habilitada: habilitado),
            ControlesReproductor(reproductor: r, habilitados: habilitado),
          ],
          const Divider(height: 1, thickness: 1),
        ];
        final abajo = <Widget>[
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _EstadoCamara(estado: estado, camara: camara, pc: pc, hoy: hoy),
              if (datos)
                AyudaInfo(texto: l.camaraAyudaPrivacidad, tema: 'privacidad'),
            ],
          ),
          ..._queRevisar(estado, nombre),
          if (conMovimientos && r != null && r.iniciado)
            ..._filtros(context, r, hoy, n),
          if (datos) ..._eventos(r, hoy) else ..._ultimos(context, camara),
          const SizedBox(height: 20),
          ListaTarjeta(
            key: _claveAjustes,
            children: [
              FilaPlegable(
                key: ValueKey(_ajustesAbiertos),
                icono: Ico.sliders,
                titulo: l.camaraAjustes,
                resumen: l.camaraAjustesResumen,
                abierta: _ajustesAbiertos > 0,
                child: _ajustes(context, camara, pc, estado, titular, hoy),
              ),
            ],
          ),
        ];
        final grande = MediaQuery.textScalerOf(context).scale(16) > 24;
        Future<void> recargar() async {
          ref
            ..invalidate(camarasProvider)
            ..invalidate(hogarProvider)
            ..invalidate(movimientosEnLaNubeProvider);
          await ref.read(camarasProvider.future);
        }

        if (grande) {
          return RefreshIndicator(
            onRefresh: recargar,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                ...arriba,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: abajo,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...arriba,
            Expanded(
              child: RefreshIndicator(
                onRefresh: recargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  children: abajo,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// «Qué revisar» (`camChecks`): what to check in the house.
  List<Widget> _queRevisar(EstadoVisible estado, String nombre) {
    final l = context.l10n;
    final Widget? lista = switch (estado) {
      EstadoVisible.sinConexion => const QueRevisarPc(),
      EstadoVisible.desconectada => ListaTarjeta(
        borde: true,
        children: [
          FilaLista(
            inicio: const IconoFila(Ico.cam),
            titulo: l.camaraRevisarCable,
          ),
          FilaLista(
            inicio: const IconoFila(Ico.pc),
            titulo: l.camaraRevisarPc,
            subtitulo: l.camaraRevisarPcDetalle,
          ),
          FilaLista(
            inicio: const IconoFila(Ico.wifi),
            titulo: l.camaraRevisarInternet,
          ),
        ],
      ),
      EstadoVisible.noConfiable => ListaTarjeta(
        borde: true,
        children: [
          FilaLista(
            inicio: const IconoFila(Ico.sun),
            titulo: l.camaraRevisarLuz,
            subtitulo: l.camaraRevisarLuzDetalle,
          ),
          FilaLista(
            inicio: const IconoFila(Ico.cam),
            titulo: l.camaraRevisarEncuadre,
            subtitulo: l.camaraRevisarEncuadreDetalle(nombre),
          ),
        ],
      ),
      _ => null,
    };
    if (lista == null) return const [];
    return [
      VerMas(
        etiqueta: l.camaraQueRevisar,
        child: Padding(padding: const EdgeInsets.only(top: 8), child: lista),
      ),
    ];
  }

  /// «Hoy · Ayer · Elegir día…» and «10 min · 1 hora · Solo eventos» (`camFilters`).
  List<Widget> _filtros(
    BuildContext context,
    ReproductorCamara r,
    DateTime hoy,
    MovimientosEnLaNube? nube,
  ) {
    final h = DateTime(hoy.year, hoy.month, hoy.day);
    final ayer = h.subtract(const Duration(days: 1));
    final otro = r.dia != h && r.dia != ayer;
    final l = context.l10n;
    return [
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChipOpcion(
            texto: l.camaraHoy,
            elegido: r.dia == h,
            alTocar: () => unawaited(r.elegirDia(h)),
          ),
          ChipOpcion(
            texto: l.camaraAyer,
            elegido: r.dia == ayer,
            alTocar: () => unawaited(r.elegirDia(ayer)),
          ),
          ChipOpcion(
            texto: otro ? l.formato.fechaCorta(r.dia) : l.camaraElegirDia,
            icono: Ico.cal,
            elegido: otro,
            alTocar: () => _elegirDia(context, r, hoy),
          ),
        ],
      ),
      if (!r.fueraDePlazo) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChipOpcion(
              texto: l.camara10Min,
              elegido: r.largo == ReproductorCamara.diezMinutos,
              alTocar: () => r.cambiarLargo(ReproductorCamara.diezMinutos),
            ),
            ChipOpcion(
              texto: l.camara1Hora,
              elegido: r.largo == ReproductorCamara.unaHora,
              alTocar: () => r.cambiarLargo(ReproductorCamara.unaHora),
            ),
            ChipOpcion(
              texto: l.camaraSoloEventos,
              icono: Ico.list,
              elegido: r.soloEventos,
              alTocar: r.alternarSoloEventos,
            ),
          ],
        ),
      ],
    ];
  }

  Future<void> _elegirDia(
    BuildContext context,
    ReproductorCamara r,
    DateTime hoy,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (hoja) => Consumer(
      builder: (context, ref, _) => HojaElegirDia(
        hoy: hoy,
        elegido: r.dia,
        datosDesde: r.datosDesde,
        conEventos:
            ref.watch(diasConEventosProvider(r.camaraId)).value ?? const {},
        alElegir: (d) {
          Navigator.of(hoja).pop();
          unawaited(r.elegirDia(d));
        },
      ),
    ),
  );

  /// «Eventos · Hoy» (`camEvList`), newest first.
  List<Widget> _eventos(ReproductorCamara r, DateTime hoy) {
    final l = context.l10n;
    final d = DateTime(r.dia.year, r.dia.month, r.dia.day);
    final h = DateTime(hoy.year, hoy.month, hoy.day);
    final esHoy = d == h;
    final esAyer = d == h.subtract(const Duration(days: 1));
    final etiqueta = esHoy
        ? l.camaraHoy
        : esAyer
        ? l.camaraAyer
        : l.formato.fechaCorta(d);
    final actual =
        r.seleccionado ??
        r.eventos
            .where(
              (e) => r.posicion.difference(e.en).abs().inMilliseconds < 1500,
            )
            .firstOrNull
            ?.en;
    return [
      EncabezadoDia(l.camaraEventosDe(etiqueta)),
      if (r.eventos.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icono(Ico.check, tamano: 20, color: context.colores.calmaTinta),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  esHoy
                      ? l.camaraSinEventosHoy
                      : esAyer
                      ? l.camaraSinEventosAyer
                      : l.camaraSinEventosEl(etiqueta),
                  style: estiloTexto(16, 600, color: context.colores.tinta2),
                ),
              ),
            ],
          ),
        )
      else
        ListaTarjeta(
          children: [
            for (final e in r.eventos.reversed)
              FilaEvento(
                evento: e,
                actual: e.en == actual,
                alTocar: r.estado == EstadoReproductor.listo
                    ? () => r.irA(e.en, evento: true)
                    : null,
              ),
          ],
        ),
    ];
  }

  /// Without stored movements, the camera's latest events open their alert (`camRecent`).
  List<Widget> _ultimos(BuildContext context, Camara camara) {
    final r = _reproductor;
    final List<Alerta> recientes = r != null && r.iniciado
        ? r.recientes
        : ref.watch(_ultimasAlertasProvider(camara.id)).value ?? const [];
    if (recientes.isEmpty) return const [];
    final l = context.l10n;
    return [
      EncabezadoDia(l.camaraUltimosEventos),
      ListaTarjeta(
        children: [
          for (final a in recientes.take(4))
            FilaLista(
              inicio: SizedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      diaMes(a.ocurridaEn, l.formato),
                      style: estiloMono(
                        tamano: 16,
                        color: context.colores.tinta,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MarcaAlerta(
                      tipo: a.tipo,
                      falsa: a.estado == EstadoAlerta.falsaAlarma,
                    ),
                  ],
                ),
              ),
              titulo: a.esCaida ? l.camaraCaida : l.camaraInestable,
              subtituloRico: TextSpan(
                text: l.formato.hora(a.ocurridaEn),
                style: estiloCifras,
              ),
              fin: SelloEstado(a),
              alTocar: () => context.push(
                a.activa ? Rutas.alerta(a.id) : Rutas.detalleAlerta(a.id),
              ),
            ),
        ],
      ),
    ];
  }

  /// «Ajustes de la cámara» (`camSettings`): pause or resume, the room's name, the access log,
  /// its PC, «¿Hubo una caída y no avisó?» and «Dejar de usar esta cámara».
  Widget _ajustes(
    BuildContext context,
    Camara camara,
    Pc? pc,
    EstadoVisible estado,
    bool titular,
    DateTime hoy,
  ) {
    final habitacion = camara.nombreHabitacion;
    final ultimo = ref.watch(registroAccesosProvider).value?.firstOrNull;
    final instalada = camara.instaladaEn;
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (estado == EstadoVisible.enPausa)
          FilaLista(
            inicio: const IconoFila(Ico.refresh),
            titulo: l.camaraReanudarAhora,
            subtitulo: l.camaraEnPausaHastaLas(
              finDePausa(camara.pausadaHasta!, hoy, l),
            ),
            chevron: false,
            alTocar: () => reanudarCamara(context, ref, camara),
          )
        else if (estado == EstadoVisible.enLinea ||
            estado == EstadoVisible.noConfiable)
          FilaLista(
            inicio: const IconoFila(Ico.pause),
            titulo: l.camaraPausar,
            subtitulo: l.camaraSinDeteccionNiVivo,
            chevron: false,
            alTocar: () => pausarCamara(context, camara),
          ),
        if (titular)
          FilaLista(
            inicio: const IconoFila(Ico.pin),
            titulo: l.camaraNombreDe(habitacion),
            alTocar: () => context.push(
              Uri(
                path: Rutas.nombreCamara(camara.id),
                queryParameters: {'actual': habitacion},
              ).toString(),
            ),
          )
        else
          FilaLista(
            inicio: const IconoFila(Ico.pin),
            titulo: l.camaraNombreDe(habitacion),
            fin: const EtiquetaSoloVer(),
          ),
        FilaLista(
          inicio: const IconoFila(Ico.eye),
          titulo: l.accesosTitulo,
          subtitulo: resumenUltimoAcceso(
            ultimo,
            yo: ref.watch(sesionControllerProvider)?.usuario.id,
            hoy: hoy,
            l: l,
          ),
          alTocar: () => context.push(Rutas.accesos),
        ),
        FilaLista(
          inicio: const IconoFila(Ico.pc),
          titulo: pc == null ? l.camaraPcDeLaCasa : l.camaraPcNombre(pc.nombre),
          subtitulo: [
            ?camara.nombreDispositivo,
            if (instalada != null)
              l.camaraDesdeElFecha(l.formato.fechaNumerica(instalada)),
          ].join(' · '),
        ),
        FilaLista(
          inicio: const IconoFila(Ico.report),
          titulo: l.camaraHuboCaida,
          alTocar: () => context.push(Rutas.reportar(habitacion: habitacion)),
        ),
        if (titular && camara.pcId != null)
          FilaLista(
            inicio: const IconoFila(Ico.x, peligro: true),
            titulo: l.camaraDejarDeUsar,
            peligro: true,
            chevron: false,
            alTocar: () async {
              final hecho = await dejarDeUsarCamara(
                context,
                ref,
                camaraId: camara.id,
                dispositivo:
                    camara.nombreDispositivo ??
                    l.camaraDispositivoDeHabitacion(habitacion),
                habitacion: habitacion,
                pcId: camara.pcId,
              );
              if (hecho && context.mounted) {
                await Navigator.of(context).maybePop();
              }
            },
          ),
      ],
    );
  }
}

/// The camera's latest alerts, newest first (without stored movements).
final _ultimasAlertasProvider = FutureProvider.autoDispose
    .family<List<Alerta>, String>((ref, camaraId) async {
      final p = await ref
          .watch(alertasRepositorioProvider)
          .listar(const FiltroAlertas(tamano: FiltroAlertas.tamanoMaximo));
      return [
        for (final a in p.elementos)
          if (a.camaraId == camaraId) a,
      ];
    });

/// The state under the player (`camStatus`): «En línea», «En pausa hasta las 11:42»,
/// «Desconectada desde las 10:31», «Sin conexión desde las 09:58», «Detección no confiable»,
/// «Detenida».
class _EstadoCamara extends StatelessWidget {
  const _EstadoCamara({
    required this.estado,
    required this.camara,
    required this.pc,
    required this.hoy,
  });

  final EstadoVisible estado;
  final Camara camara;
  final Pc? pc;
  final DateTime hoy;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final l = context.l10n;
    final (texto, icono, fondo, color) = switch (estado) {
      EstadoVisible.enLinea => (
        estado.texto(l),
        Ico.check,
        c.calmaSuave,
        c.calmaTinta,
      ),
      EstadoVisible.enPausa => (
        l.camaraEnPausaHastaLas(finDePausa(camara.pausadaHasta!, hoy, l)),
        Ico.pause,
        c.pausaSuave,
        c.pausa,
      ),
      EstadoVisible.desconectada => (
        camara.ultimaSenal == null
            ? estado.texto(l)
            : l.camaraDesconectadaDesde(l.formato.hora(camara.ultimaSenal!)),
        Ico.plug,
        c.avisoSuave,
        c.avisoTinta,
      ),
      EstadoVisible.sinConexion => (
        pc?.ultimaSenal == null
            ? estado.texto(l)
            : l.camaraSinConexionDesde(l.formato.hora(pc!.ultimaSenal!)),
        Ico.wifiOff,
        c.fondo2,
        c.tinta2,
      ),
      EstadoVisible.noConfiable => (
        estado.texto(l),
        Ico.eyeOff,
        c.avisoSuave,
        c.avisoTinta,
      ),
      EstadoVisible.detenida => (estado.texto(l), Ico.lock, c.fondo2, c.tinta2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icono(icono, tamano: 18, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(texto, style: estiloTexto(16, 700, color: color)),
          ),
        ],
      ),
    );
  }
}
