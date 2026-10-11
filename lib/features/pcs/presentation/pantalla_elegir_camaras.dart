import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/sesion/sesion_controller.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/formulario.dart';
import '../../../core/ui/iconos.dart';
import '../../../core/ui/lista.dart';
import '../../../core/ui/piezas.dart';
import '../../camaras/domain/camara.dart';
import '../../familia/data/familia_repositorio.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/pcs_repositorio.dart';
import '../domain/camara_detectada.dart';
import '../domain/pc.dart';
import 'acciones_camara.dart';
import 'navegacion_pc.dart';
import 'piezas_pc.dart';
import 'refresco_pcs.dart';
import 'vista_previa.dart';

/// The rooms offered as chips (`PICK_ROOMS`), before the household's own.
const habitacionesSugeridas = [
  'Sala',
  'Dormitorio',
  'Cocina',
  'Comedor',
  'Pasillo',
];

/// After «Buscar de nuevo», how long the PC gets to report its webcams again before the list is
/// read (contract §9: «read them again after a few seconds») [implementation choice].
const esperaBusquedaCamaras = Duration(seconds: 4);

/// With this many cameras in use, the screen reminds that each one loads the PC (`inUse>=3`).
const camarasQueCarganLaPc = 3;

/// The «Otra…» chip.
const _otra = '__otra';

/// «Elige las cámaras» (screens 250 to 283): the owner chooses from the phone which of the PC's
/// webcams to use and the room of each one, recognising them by name and a short preview
/// (CA-29.1 to CA-29.7). One camera per room on any PC (CA-29.3), never in a bathroom; the invited
/// member sees it read-only (CA-29.9).
class PantallaElegirCamaras extends ConsumerStatefulWidget {
  const PantallaElegirCamaras({
    super.key,
    required this.pcId,
    this.enConfiguracion = false,
  });

  final String pcId;
  final bool enConfiguracion;

  @override
  ConsumerState<PantallaElegirCamaras> createState() =>
      _PantallaElegirCamarasState();
}

class _PantallaElegirCamarasState extends ConsumerState<PantallaElegirCamaras> {
  /// The open card; null when all are closed, unset until the list arrives (the first «sin usar»
  /// opens then).
  String? _abierta;
  bool _abiertaElegida = false;

  /// The chosen chip: a room name, or [_otra].
  String? _habitacion;
  final _otraControl = TextEditingController();
  String? _error;
  bool _guardando = false;
  bool _buscando = false;
  Timer? _busqueda;

  @override
  void dispose() {
    _busqueda?.cancel();
    _otraControl.dispose();
    super.dispose();
  }

  void _abrir(String? id) => setState(() {
    _abierta = id;
    _abiertaElegida = true;
    _habitacion = null;
    _error = null;
    _otraControl.clear();
  });

  /// «Buscar de nuevo» (CA-29.6): the PC reports its webcams again; the list is read after a few
  /// seconds.
  Future<void> _buscarDeNuevo() async {
    setState(() => _buscando = true);
    try {
      await ref.read(pcsRepositorioProvider).buscarCamaras(widget.pcId);
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      setState(() => _buscando = false);
      return _avisarError(e);
    }
    _busqueda = Timer(esperaBusquedaCamaras, () {
      if (!mounted) return;
      ref.invalidate(camarasDetectadasProvider(widget.pcId));
      setState(() => _buscando = false);
    });
  }

  void _avisarError(ProblemaApi e) => mostrarToast(
    context,
    titulo: e.codigo == ProblemaApi.sinConexion ? 'Sin internet' : e.detalle,
    texto: e.codigo == ProblemaApi.sinConexion
        ? 'Revisa tu conexión y vuelve a intentarlo.'
        : null,
    icono: e.codigo == ProblemaApi.sinConexion ? Ico.wifiOff : Ico.warn,
    tono: TonoAviso.advertencia,
  );

  /// «Ya hay una cámara en la Cocina (PC Cocina-Rosa). Por ahora, cada habitación usa una sola
  /// cámara.» (CA-29.3).
  String _ocupada(String habitacion, String? pc) =>
      'Ya hay una cámara ${enHabitacion(habitacion)}'
      '${pc == null ? '' : ' (PC $pc)'}. Por ahora, cada habitación usa una '
      'sola cámara.';

  /// «Usar esta cámara» (CA-29.2): the PC hears it at once and the camera starts detecting there.
  Future<void> _usar(
    CamaraDetectada camara,
    List<Ambiente> ambientes,
    List<CamaraDetectada> todas,
  ) async {
    final elegida = _habitacion;
    if (elegida == null || _guardando) return;
    var nombre = elegida == _otra
        ? _otraControl.text.trim().replaceAll(RegExp(r'\s+'), ' ')
        : elegida;
    if (nombre.isEmpty) {
      return setState(() => _error = 'Escribe el nombre de la habitación.');
    }
    nombre = nombre[0].toUpperCase() + nombre.substring(1);
    if (esBano(nombre)) {
      return setState(
        () => _error = 'Por privacidad, Te Tengo no admite cámaras en el baño.',
      );
    }
    final ambiente = ambientes
        .where((a) => a.nombre.toLowerCase() == nombre.toLowerCase())
        .firstOrNull;
    if (ambiente != null && ambiente.conCamara) {
      return setState(
        () =>
            _error = _ocupada(ambiente.nombre, ambiente.camaras.first.pcNombre),
      );
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final usada = await ref
          .read(pcsRepositorioProvider)
          .usarCamara(
            camara.id,
            ambienteId: ambiente?.id,
            nombreAmbiente: ambiente == null ? nombre : null,
          );
      refrescarCamaras(ref, pcId: widget.pcId);
      if (!mounted) return;
      final habitacion = usada.nombreHabitacion;
      final conConsentimiento =
          ref.read(hogarProvider).value?.conConsentimiento ?? true;
      mostrarToast(
        context,
        titulo:
            'La cámara ${camara.nombreDispositivo} cuida ahora '
            '${conArticulo(habitacion)}',
        texto: conConsentimiento
            ? 'Las próximas alertas dirán «${enHabitacion(habitacion)}».'
            : 'Detectará caídas cuando registres el consentimiento.',
        icono: Ico.cam,
      );
      // The next webcam without a room opens.
      final siguiente = todas
          .where((w) => w.id != camara.id && !w.enUso && w.conectada)
          .firstOrNull;
      _abrir(siguiente?.id);
    } on ProblemaApi catch (e) {
      if (!mounted) return;
      switch (e.codigo) {
        case 'AMBIENTE_OCUPADO':
          final otra = CamaraDeAmbiente.desde(e.extras['camara']);
          setState(
            () => _error = _ocupada(
              e.extras['ambiente'] as String? ?? nombre,
              otra?.pcNombre,
            ),
          );
          ref.invalidate(ambientesProvider);
        case 'AMBIENTE_NO_PERMITIDO':
          setState(
            () => _error =
                'Por privacidad, Te Tengo no admite cámaras en el baño.',
          );
        case 'AMBIENTE_NOMBRE_VACIO':
          setState(() => _error = 'Escribe el nombre de la habitación.');
        case 'AMBIENTE_NOMBRE_MUY_LARGO':
          setState(() => _error = e.detalle);
        default:
          _avisarError(e);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _terminar() => widget.enConfiguracion
      ? context.go(Rutas.configFamilia)
      : salirA(context, Rutas.pcs);

  @override
  Widget build(BuildContext context) {
    final pcs = ref.watch(pcsProvider);
    final pc = pcs.value?.where((p) => p.id == widget.pcId).firstOrNull;
    final webcams = ref.watch(camarasDetectadasProvider(widget.pcId));
    final ambientes = ref.watch(ambientesProvider);
    final hogar = ref.watch(hogarProvider);
    final titular = ref.watch(esTitularProvider);
    final escala = MediaQuery.textScalerOf(context);
    Future<void> recargar() async => ref
      ..invalidate(pcsProvider)
      ..invalidate(camarasDetectadasProvider(widget.pcId))
      ..invalidate(ambientesProvider)
      ..invalidate(hogarProvider);
    return RefrescoPcs(
      pcId: widget.pcId,
      child: Scaffold(
        appBar: widget.enConfiguracion
            ? CabeceraConfiguracion(
                paso: 3,
                titulo: 'PC de la casa',
                escala: escala,
              )
            : AppBar(title: Text(pc?.nombre ?? 'Elige las cámaras')),
        body: switch ((pcs, webcams, ambientes, hogar)) {
          (AsyncError(:final error), _, _, _) ||
          (_, AsyncError(:final error), _, _) ||
          (_, _, AsyncError(:final error), _) ||
          (
            _,
            _,
            _,
            AsyncError(:final error),
          ) => ErrorDePantalla(error: error, alReintentar: recargar),
          (
            AsyncData(),
            AsyncData(value: final lista),
            AsyncData(value: final habitaciones),
            AsyncData(value: final h),
          ) =>
            RefreshIndicator(
              onRefresh: recargar,
              child: _contenido(
                context,
                pc,
                lista,
                habitaciones,
                h.conConsentimiento,
                h.adultoMayor.nombrePila,
                titular,
              ),
            ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _contenido(
    BuildContext context,
    Pc? pc,
    List<CamaraDetectada> lista,
    List<Ambiente> ambientes,
    bool conConsentimiento,
    String nombre,
    bool titular,
  ) {
    final texto = Theme.of(context).textTheme;
    final sinConexion = pc != null && EstadoPc.de(pc) == EstadoPc.sinConexion;
    final nombrePc = pc?.nombre ?? '';
    if (!_abiertaElegida && titular) {
      _abierta = lista.where((w) => !w.enUso && w.conectada).firstOrNull?.id;
    }
    final enUso = lista.where((w) => w.enUso).length;
    final n = lista.length;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, widget.enConfiguracion ? 0 : 4, 20, 28),
      children: [
        Semantics(
          header: true,
          child: Text('Elige las cámaras', style: texto.titleLarge),
        ),
        const SizedBox(height: 8),
        Text(
          sinConexion || n == 0
              ? 'Una cámara por habitación. Te Tengo solo usa las que elijas.'
              : 'La PC $nombrePc encontró $n cámara${n == 1 ? '' : 's'}. Dinos en '
                    'qué habitación está cada una; por ahora, cada habitación '
                    'usa una sola cámara.',
          style: texto.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (!conConsentimiento && !sinConexion) ...[
          Aviso(
            tono: TonoAviso.error,
            icono: Ico.lock,
            titulo: 'Falta el consentimiento de $nombre',
            texto:
                'Puedes elegir las cámaras, pero no habrá vista previa ni '
                'detección hasta que lo registres.',
            accion: titular
                ? Boton(
                    'Registrar consentimiento',
                    pequeno: true,
                    alPresionar: () => widget.enConfiguracion
                        ? context.go(Rutas.configConsentimiento)
                        : context.push(Rutas.consentimiento),
                  )
                : null,
          ),
          const SizedBox(height: 16),
        ],
        if (!titular) ...[
          AvisoSoloLectura(
            titular: ref.watch(nombreTitularProvider) ?? '',
            accion: 'elegir las cámaras',
          ),
          const SizedBox(height: 16),
        ],
        if (sinConexion) ...[
          Aviso(
            tono: TonoAviso.advertencia,
            icono: Ico.wifiOff,
            titulo: 'La PC $nombrePc no responde',
            contenido: TextSpan(
              children: [
                if (pc.ultimaSenal case final s?) ...[
                  const TextSpan(text: 'Sin conexión desde las '),
                  TextSpan(
                    text: hora(s),
                    style: estiloMono(tamano: 15.5, peso: 400),
                  ),
                  const TextSpan(text: '. '),
                ],
                const TextSpan(text: 'Cuando vuelva, verás aquí sus cámaras.'),
              ],
            ),
          ),
          const EncabezadoSeccion('Qué revisar en la casa'),
          const QueRevisarPc(),
        ] else if (_buscando)
          _Buscando(nombrePc: nombrePc)
        else if (n == 0)
          EstadoVacioCamaras(
            nombrePc: nombrePc,
            alBuscar: titular ? _buscarDeNuevo : null,
          )
        else ...[
          for (final w in lista) ...[
            _TarjetaWebcam(
              webcam: w,
              abierta: titular && _abierta == w.id,
              titular: titular,
              alTocar: titular
                  ? () => _abrir(_abierta == w.id ? null : w.id)
                  : null,
              cuerpo: titular && _abierta == w.id
                  ? _cuerpo(context, w, pc, ambientes, lista)
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          if (enUso >= camarasQueCarganLaPc) ...[
            Text(
              'Cada cámara usa más la PC. Si la detección se vuelve lenta, '
              'conecta algunas cámaras a otra PC.',
              style: texto.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
          if (titular) ...[
            Text(
              '¿Falta una cámara? Pide que la conecten por USB a la PC.',
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 4),
            Boton(
              'Buscar de nuevo',
              icono: Ico.refresh,
              estilo: EstiloBoton.fantasma,
              alPresionar: _buscarDeNuevo,
            ),
          ],
        ],
        if (titular) ...[
          const SizedBox(height: 20),
          Boton(
            widget.enConfiguracion ? 'Continuar' : 'Listo',
            alPresionar: _terminar,
          ),
        ],
      ],
    );
  }

  /// The open card's content (`webCard` body).
  Widget _cuerpo(
    BuildContext context,
    CamaraDetectada w,
    Pc? pc,
    List<Ambiente> ambientes,
    List<CamaraDetectada> todas,
  ) {
    final texto = Theme.of(context).textTheme;
    final vistaPrevia = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Boton(
          'Ver vista previa',
          icono: Ico.eye,
          estilo: EstiloBoton.secundario,
          pequeno: true,
          alPresionar: () => abrirVistaPrevia(context, camara: w, pc: pc),
        ),
        const SizedBox(height: 6),
        Text(
          'No se graba. Queda en el registro de la familia.',
          style: texto.bodySmall,
        ),
      ],
    );
    final habitacion = w.nombreHabitacion ?? '';
    if (w.enUso) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (w.conectada)
            vistaPrevia
          else
            Aviso(
              tono: TonoAviso.advertencia,
              icono: Ico.wifiOff,
              texto:
                  'Revisa el cable USB. $habitacion sigue con esta cámara: no '
                  'pasa a otra.',
            ),
          const SizedBox(height: 12),
          Boton(
            'Dejar de usar',
            icono: Ico.x,
            estilo: EstiloBoton.peligroContorno,
            alPresionar: () => dejarDeUsarCamara(
              context,
              ref,
              camaraId: w.id,
              dispositivo: w.nombreDispositivo,
              habitacion: habitacion,
              pcId: widget.pcId,
            ),
          ),
        ],
      );
    }
    if (!w.conectada) {
      return const Aviso(
        tono: TonoAviso.neutral,
        icono: Ico.plug,
        texto: 'Pide a alguien en la casa que la conecte por USB a la PC.',
      );
    }
    final propias = ambientes
        .map((a) => a.nombre)
        .where(
          (n) => !habitacionesSugeridas.any(
            (s) => s.toLowerCase() == n.toLowerCase(),
          ),
        )
        .toList();
    Ambiente? ambienteDe(String nombre) => ambientes
        .where((a) => a.nombre.toLowerCase() == nombre.toLowerCase())
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        vistaPrevia,
        const SizedBox(height: 16),
        Text(
          '¿En qué habitación está?',
          style: estiloTexto(16, 700, color: context.colores.tinta),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: '¿En qué habitación está?',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in [...habitacionesSugeridas, ...propias])
                ChipHabitacion(
                  texto: h,
                  elegido: _habitacion == h,
                  ocupada: ambienteDe(h)?.conCamara ?? false,
                  alTocar: () => setState(() {
                    _habitacion = h;
                    _error = null;
                  }),
                ),
              ChipHabitacion(
                texto: 'Otra…',
                elegido: _habitacion == _otra,
                ocupada: false,
                alTocar: () => setState(() {
                  _habitacion = _otra;
                  _error = null;
                }),
              ),
            ],
          ),
        ),
        if (_habitacion == _otra) ...[
          const SizedBox(height: 12),
          CampoTexto(
            etiqueta: 'Nombre de la habitación',
            controlador: _otraControl,
            marcador: 'Ej.: Estudio',
            ayuda: 'Aparece en cada alerta.',
            error: _error,
            longitudMaxima: 40,
            alCambiar: (_) => setState(() => _error = null),
            alEnviar: (_) => _usar(w, ambientes, todas),
          ),
        ] else if (_error != null) ...[
          const SizedBox(height: 10),
          MensajeCampo(_error!),
        ],
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icono(
                Ico.shield,
                tamano: 20,
                color: context.colores.tinta3,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Por privacidad, Te Tengo no admite cámaras en el baño.',
                style: texto.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Boton(
          'Usar esta cámara',
          icono: Ico.check,
          cargando: _guardando,
          alPresionar: _habitacion == null
              ? null
              : () => _usar(w, ambientes, todas),
        ),
      ],
    );
  }
}

/// «Buscando cámaras en la PC Sala-Rosa…» (screen 270).
class _Buscando extends StatelessWidget {
  const _Buscando({required this.nombrePc});

  final String nombrePc;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colores.moradoSuave,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buscando cámaras en la PC $nombrePc…',
                  style: estiloTexto(
                    16,
                    700,
                    color: context.colores.moradoTinta,
                  ),
                ),
                Text(
                  'Puede tardar unos segundos.',
                  style: estiloTexto(
                    15,
                    400,
                    color: context.colores.moradoTinta,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// «No encontramos cámaras en la PC Sala-Rosa» (screen 271, CA-29.6).
class EstadoVacioCamaras extends StatelessWidget {
  const EstadoVacioCamaras({
    super.key,
    required this.nombrePc,
    required this.alBuscar,
  });

  final String nombrePc;

  /// «Buscar de nuevo»; null for the invited member.
  final VoidCallback? alBuscar;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      child: Column(
        children: [
          IconoGrande(
            icono: Ico.cam,
            fondo: context.colores.moradoSuave,
            color: context.colores.moradoTinta,
          ),
          const SizedBox(height: 16),
          Text(
            'No encontramos cámaras en la PC $nombrePc',
            textAlign: TextAlign.center,
            style: texto.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Pide a alguien en la casa que conecte una webcam por USB a la PC.',
            textAlign: TextAlign.center,
            style: texto.bodyMedium,
          ),
          if (alBuscar != null) ...[
            const SizedBox(height: 16),
            Boton(
              'Buscar de nuevo',
              icono: Ico.refresh,
              estilo: EstiloBoton.secundario,
              alPresionar: alBuscar,
            ),
          ],
        ],
      ),
    );
  }
}

/// What a webcam card says about it (`webState`): never by color alone.
({Ico icono, String texto, EstadoVisible estado}) estadoWebcam(
  CamaraDetectada w,
) {
  final habitacion = w.nombreHabitacion ?? '';
  if (w.enUso) {
    if (!w.conectada) {
      return (
        icono: Ico.wifiOff,
        texto: 'Desconectada · $habitacion',
        estado: EstadoVisible.desconectada,
      );
    }
    if (w.enPausa) {
      return (
        icono: Ico.pause,
        texto: 'En uso · $habitacion · en pausa',
        estado: EstadoVisible.enPausa,
      );
    }
    return (
      icono: Ico.cam,
      texto: 'En uso · $habitacion',
      estado: EstadoVisible.enLinea,
    );
  }
  if (!w.conectada) {
    return (
      icono: Ico.wifiOff,
      texto: 'Desconectada',
      estado: EstadoVisible.desconectada,
    );
  }
  return (icono: Ico.cam, texto: 'Sin usar', estado: EstadoVisible.detenida);
}

/// One webcam the PC reported (`webCard`): its name and state, open one at a time.
class _TarjetaWebcam extends StatelessWidget {
  const _TarjetaWebcam({
    required this.webcam,
    required this.abierta,
    required this.titular,
    required this.alTocar,
    required this.cuerpo,
  });

  final CamaraDetectada webcam;
  final bool abierta;
  final bool titular;
  final VoidCallback? alTocar;
  final Widget? cuerpo;

  @override
  Widget build(BuildContext context) {
    final e = estadoWebcam(webcam);
    final color = switch (e.estado) {
      EstadoVisible.enLinea => context.colores.calmaTinta,
      EstadoVisible.desconectada => context.colores.aviso,
      EstadoVisible.enPausa => context.colores.pausa,
      _ => context.colores.tinta3,
    };
    final cabecera = FilaLista(
      inicio: _IconoWebcam(icono: e.icono, estado: e.estado),
      titulo: webcam.nombreDispositivo,
      subtituloRico: TextSpan(
        text: e.texto,
        style: estiloTexto(15, 700, color: color),
      ),
      fin: titular
          ? RotatedBox(
              quarterTurns: abierta ? 2 : 0,
              child: Icono(
                Ico.chevD,
                tamano: 22,
                color: context.colores.tinta3,
              ),
            )
          : null,
      alTocar: alTocar,
    );
    return Semantics(
      expanded: titular ? abierta : null,
      child: Container(
        decoration: BoxDecoration(
          color: context.colores.tarjeta,
          borderRadius: BorderRadius.circular(22),
          border: e.estado == EstadoVisible.desconectada
              ? Border.all(color: context.colores.aviso, width: 1.5)
              : null,
          boxShadow: sombraTarjeta,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cabecera,
              if (cuerpo != null) ...[
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: cuerpo,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IconoWebcam extends StatelessWidget {
  const _IconoWebcam({required this.icono, required this.estado});

  final Ico icono;
  final EstadoVisible estado;

  @override
  Widget build(BuildContext context) {
    final (fondo, color) = switch (estado) {
      EstadoVisible.enLinea => (
        context.colores.calmaSuave,
        context.colores.calmaTinta,
      ),
      EstadoVisible.desconectada => (
        context.colores.avisoSuave,
        context.colores.aviso,
      ),
      EstadoVisible.enPausa => (
        context.colores.pausaSuave,
        context.colores.pausa,
      ),
      _ => (context.colores.fondo2, context.colores.tinta3),
    };
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icono(icono, tamano: 24, color: color),
    );
  }
}
