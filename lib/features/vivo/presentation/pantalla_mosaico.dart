import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/rutas.dart';
import '../../../app/tema/colores.dart';
import '../../../app/tema/paleta.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/aviso.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/ayuda.dart';
import '../../../core/ui/iconos.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/data/orden_camaras.dart';
import '../../camaras/domain/camara.dart';
import '../../camaras/presentation/favorita.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../../pcs/data/pcs_repositorio.dart';
import '../../pcs/domain/camaras_en_casa.dart';
import '../../pcs/presentation/refresco_pcs.dart';
import '../data/preferencias_vivo.dart';
import '../data/vista_en_vivo_repositorio.dart';
import '../domain/vista_en_vivo.dart';
import 'conexion_vivo.dart';
import 'modos_vista.dart';
import 'reproductor_vivo.dart';
import 'reproductor_webrtc.dart';

/// At most 4 cameras stream at once: a page of «Ver todas» (prototype decision: the bandwidth of the
/// household PC and of the phone, and what a phone screen can show).
const camarasPorPagina = 4;

/// The privacy help of «Ver todas» (`ML_PRIV`).
const textoPrivacidadMosaico =
    'No se graba. Al cerrar queda un solo acceso en el registro, con las '
    'habitaciones vistas y la duración.';

/// Turns the phone to landscape while «Ver todas» is open in landscape; replaceable in tests. The
/// web cannot lock the orientation, so the screen rotates its content when the window is portrait.
abstract interface class OrientacionMosaico {
  void horizontal();

  void liberar();
}

class OrientacionMosaicoSistema implements OrientacionMosaico {
  const OrientacionMosaicoSistema();

  @override
  void horizontal() {
    if (kIsWeb) return;
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Gives back the orientations of `Info.plist` and the Android manifest.
  @override
  void liberar() {
    if (kIsWeb) return;
    SystemChrome.setPreferredOrientations(const []);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

final orientacionMosaicoProvider = Provider<OrientacionMosaico>(
  (ref) => const OrientacionMosaicoSistema(),
);

/// What a cell shows when its camera cannot stream (`mosWhy`): «Desde las 10:31», «Hasta las
/// 11:42», «La PC no responde», «Sin consentimiento».
String porQueNoEnMosaico(CamaraEnCasa c) => switch (c.estado) {
  EstadoVisible.enPausa => 'Hasta las ${hora(c.camara.pausadaHasta!)}',
  EstadoVisible.desconectada => switch (c.camara.ultimaSenal) {
    final s? => 'Desde las ${hora(s)}',
    null => '',
  },
  EstadoVisible.sinConexion => 'La PC no responde',
  EstadoVisible.detenida => 'Sin consentimiento',
  _ => '',
};

/// The live view of one cell of «Ver todas».
class _Celda {
  _Celda(this.conexion);

  final ConexionVivo conexion;
  SesionVivo? sesion;

  /// Opening in flight.
  bool abriendo = false;

  /// The stream was lost at this time; the cell shows it as disconnected.
  DateTime? cortadaEn;

  /// The backend refused the session (`409`): the cell keeps its place with the reason.
  ProblemaApi? problema;
}

/// «Ver todas» (US-41, screens 314 to 327, 333 to 337, 340, 341 and 343): every camera of the
/// household at once, in the order of this phone. Opens in landscape (a 2 × 2 grid edge to edge and
/// a thin bar), «Vertical» is the option of the portrait grid, remembered on this phone (CA-41.1).
///
/// - At most 4 stream: pages of 4 when there are more, and only the visible page streams; the
///   cameras of the page left stop at once (CA-41.2).
/// - «Video» and «Esqueleto» change every cell (the API's `modo`); remembered on this phone. With
///   «Esqueleto» alone no camera pixel leaves the home (CA-41.3).
/// - Tapping a cell opens it full screen, and then only it streams; holding it and dragging, or
///   «Ordenar», moves it within its group of the order of this phone (CA-41.4).
/// - A camera that cannot stream keeps its place with the reason and does not stream (CA-41.5).
/// - The whole opening is one access of the log (`POST /api/vista-en-vivo/mosaicos`, CA-41.6):
///   closing it says which rooms were seen and for how long.
class PantallaMosaico extends ConsumerStatefulWidget {
  const PantallaMosaico({super.key});

  @override
  ConsumerState<PantallaMosaico> createState() => _PantallaMosaicoState();
}

class _PantallaMosaicoState extends ConsumerState<PantallaMosaico> {
  final _celdas = <String, _Celda>{};
  late final VistaEnVivoRepositorio _repositorio;
  late final OrientacionMosaico _orientacion;
  late final ProviderContainer _contenedor;
  late final AppLifecycleListener _ciclo;
  late final DateTime _abiertaEn;

  /// The opening's id; null until the API answers, or from an API without it.
  String? _mosaicoId;
  bool _mosaicoListo = false;

  int _pagina = 0;

  /// The camera open full screen in landscape.
  String? _completa;

  /// «Ordenar» in the landscape bar, and the camera chosen to move.
  bool _ordenando = false;
  String? _elegida;

  /// A cell held and dragged moved enough to be a drag rather than a long press.
  bool _arrastreMovido = false;

  /// The rooms with a session in this opening, in the order first seen (CA-41.6).
  final _vistas = <String, String>{};
  bool _oculta = false;
  bool _cerrada = false;

  List<CamaraEnCasa> _camaras = const [];

  bool get _vertical => ref.read(preferenciasVivoProvider).mosaicoVertical;

  /// Until this phone's choice of portrait or landscape is read, nothing is drawn.
  bool _preferenciasLeidas = false;

  @override
  void initState() {
    super.initState();
    _repositorio = ref.read(vistaEnVivoRepositorioProvider);
    _orientacion = ref.read(orientacionMosaicoProvider);
    _contenedor = ProviderScope.containerOf(context, listen: false);
    _abiertaEn = ref.read(relojProvider)();
    _ciclo = AppLifecycleListener(onHide: _alOcultar, onShow: _alMostrar);
    unawaited(_empezar());
  }

  /// Turns the phone once this phone's choice is known, then opens the mosaic.
  Future<void> _empezar() async {
    await ref.read(preferenciasVivoProvider.notifier).cargada;
    if (!mounted) return;
    if (!_vertical) _orientacion.horizontal();
    setState(() => _preferenciasLeidas = true);
    await _abrirMosaico();
  }

  Future<void> _abrirMosaico() async {
    try {
      _mosaicoId = await _repositorio.abrirMosaico();
    } on Object {
      // Without it each camera is its own access; the cameras still stream.
    }
    if (!mounted) return;
    _mosaicoListo = true;
    _sincronizar();
  }

  /// The cameras of [pagina].
  List<CamaraEnCasa> _dePagina(int pagina) =>
      _camaras.skip(pagina * camarasPorPagina).take(camarasPorPagina).toList();

  int get _paginas => math.max(1, (_camaras.length / camarasPorPagina).ceil());

  /// The cameras that should stream now: the visible page, or only the one full screen.
  Set<String> get _deseadas {
    if (_oculta || _cerrada || !_mosaicoListo) return const {};
    final visibles = _completa != null
        ? _camaras.where((c) => c.camara.id == _completa)
        : _dePagina(_pagina);
    return {
      for (final c in visibles)
        if (c.vivoDisponible &&
            _celdas[c.camara.id]?.problema == null &&
            _celdas[c.camara.id]?.cortadaEn == null)
          c.camara.id,
    };
  }

  /// Opens the sessions of the visible cameras and closes the others (CA-41.2).
  void _sincronizar() {
    final deseadas = _deseadas;
    for (final entrada in _celdas.entries.toList()) {
      if (!deseadas.contains(entrada.key)) _cerrarCelda(entrada.key);
    }
    for (final id in deseadas) {
      final celda = _celdas[id];
      if (celda == null || (celda.sesion == null && !celda.abriendo)) {
        unawaited(_abrirCelda(id));
      }
    }
  }

  Future<void> _abrirCelda(String id) async {
    final celda = _celdas.putIfAbsent(
      id,
      () => _Celda(
        ConexionVivo(
          fabricaHls: ref.read(fabricaReproductorVivoProvider),
          fabricaWebrtc: ref.read(fabricaReproductorWebrtcProvider),
          alPerder: () => _perder(id),
        )..addListener(_alCambiar),
      ),
    );
    celda.abriendo = true;
    try {
      final sesion = await _repositorio.abrir(
        id,
        modo: ref.read(preferenciasVivoProvider).modo,
        mosaicoId: _mosaicoId,
      );
      celda.abriendo = false;
      if (!mounted || !_deseadas.contains(id) || _celdas[id] != celda) {
        _cerrarSesion(sesion);
        return;
      }
      celda.sesion = sesion;
      final c = _camaras.where((c) => c.camara.id == id).firstOrNull;
      _vistas.putIfAbsent(id, () => c?.habitacion ?? '');
      celda.conexion.conectar(sesion);
      setState(() {});
    } on ProblemaApi catch (e) {
      celda.abriendo = false;
      if (!mounted) return;
      // Paused, unplugged or without consent since the list was read: the cell says so.
      setState(() => celda.problema = e);
      ref
        ..invalidate(camarasProvider)
        ..invalidate(hogarProvider);
    }
  }

  void _cerrarCelda(String id) {
    final celda = _celdas[id];
    if (celda == null) return;
    celda.conexion.detener();
    final sesion = celda.sesion;
    celda.sesion = null;
    if (sesion != null) _cerrarSesion(sesion);
  }

  void _cerrarSesion(SesionVivo sesion) => unawaited(
    _repositorio
        .cerrar(sesion.sesionId)
        .then((_) => _contenedor.invalidate(accesosVivoProvider))
        .catchError((Object _) {}),
  );

  /// A cell's stream failed or stalled: it ends and the cell shows the camera disconnected.
  void _perder(String id) {
    if (!mounted) return;
    _cerrarCelda(id);
    setState(() => _celdas[id]?.cortadaEn = ref.read(relojProvider)());
  }

  void _alCambiar() {
    if (mounted) setState(() {});
  }

  void _alOcultar() {
    if (_oculta) return;
    _oculta = true;
    _sincronizar();
  }

  void _alMostrar() {
    if (!_oculta) return;
    _oculta = false;
    _sincronizar();
  }

  void _irAPagina(int pagina) {
    final p = pagina.clamp(0, _paginas - 1);
    if (p == _pagina) return;
    setState(() => _pagina = p);
    _sincronizar();
  }

  /// A cell was tapped: full screen in landscape (only it streams), the live view in portrait.
  Future<void> _abrirCompleta(CamaraEnCasa c) async {
    // A camera that failed can be tried again from its full screen.
    final celda = _celdas[c.camara.id];
    celda?.problema = null;
    celda?.cortadaEn = null;
    if (!_vertical) {
      setState(() => _completa = c.camara.id);
      _sincronizar();
      return;
    }
    // Portrait: the usual live view, within the same access; the mosaic stops meanwhile.
    setState(() => _completa = c.camara.id);
    for (final id in _celdas.keys.toList()) {
      _cerrarCelda(id);
    }
    if (c.vivoDisponible) _vistas.putIfAbsent(c.camara.id, () => c.habitacion);
    await context.push(
      Uri(
        path: Rutas.vivo,
        queryParameters: {'camara': c.camara.id, 'mosaico': ?_mosaicoId},
      ).toString(),
    );
    if (!mounted) return;
    setState(() => _completa = null);
    _sincronizar();
  }

  void _volverATodas() {
    final id = _completa;
    setState(() => _completa = null);
    _sincronizar();
    if (id != null) _seguir(id);
  }

  /// Shows the page of [id] (after moving it or coming back from it).
  void _seguir(String id) {
    final i = _camaras.indexWhere((c) => c.camara.id == id);
    if (i >= 0) _irAPagina(i ~/ camarasPorPagina);
  }

  Future<void> _cambiarModo(ModoVista modo) async {
    await ref.read(preferenciasVivoProvider.notifier).elegirModo(modo);
    for (final celda in _celdas.values) {
      final sesion = celda.sesion;
      if (sesion == null) continue;
      unawaited(
        _repositorio
            .cambiarModo(sesion.sesionId, modo)
            .then<void>((_) {}, onError: (Object _) {}),
      );
    }
    if (mounted) setState(() {});
  }

  List<String> get _ids => [for (final c in _camaras) c.camara.id];

  /// Moves [id] [paso] places (−1 before, +1 after) within its group (CA-41.4).
  void _mover(String id, int paso, {bool avisar = true}) {
    final i = _ids.indexOf(id);
    final movida = ref
        .read(ordenCamarasProvider.notifier)
        .mover(_ids, id, i + paso);
    if (!movida) return;
    final c = _camaras.firstWhere((c) => c.camara.id == id);
    if (avisar) {
      ref
          .read(avisoFlotanteProvider.notifier)
          .mostrar(
            AvisoFlotante(
              titulo: '${c.habitacion} se movió',
              texto: 'Mismo orden en Cámaras y Ver en vivo.',
              icono: Ico.swap,
            ),
          );
    }
    // The moved camera stays in sight.
    final orden = ref.read(ordenCamarasProvider);
    final nuevas = orden.ordenar(_camaras, (c) => c.camara.id);
    final j = nuevas.indexWhere((x) => x.camara.id == id);
    if (j >= 0) _irAPagina(j ~/ camarasPorPagina);
  }

  /// A cell dropped on another: it takes its place, within its group.
  void _soltar(String id, String sobre) {
    if (id == sobre) return;
    final a = _ids.indexOf(sobre);
    final movida = ref.read(ordenCamarasProvider.notifier).mover(_ids, id, a);
    if (!movida) {
      final orden = ref.read(ordenCamarasProvider);
      if (orden.esFavorita(id) != orden.esFavorita(sobre)) {
        ref
            .read(avisoFlotanteProvider.notifier)
            .mostrar(
              const AvisoFlotante(
                titulo: 'Las favoritas van primero',
                texto: 'Cambia la estrella para pasarla al otro grupo.',
                icono: Ico.star,
                tono: TonoAviso.info,
              ),
            );
      }
    }
  }

  Future<void> _menu(CamaraEnCasa c) async {
    setState(() => _elegida = c.camara.id);
    final orden = ref.read(ordenCamarasProvider);
    final id = c.camara.id;
    final favorita = orden.esFavorita(id);
    final opcion = await showModalBottomSheet<_OpcionMenu>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => _HojaMover(
        habitacion: c.habitacion,
        favorita: favorita,
        antes: orden.puedeMover(_ids, id, -1),
        despues: orden.puedeMover(_ids, id, 1),
      ),
    );
    if (!mounted) return;
    setState(() => _elegida = null);
    switch (opcion) {
      case _OpcionMenu.antes:
        _mover(id, -1);
      case _OpcionMenu.despues:
        _mover(id, 1);
      case _OpcionMenu.favorita:
        await ref.read(ordenCamarasProvider.notifier).favorita(id, !favorita);
        _seguir(id);
      case _OpcionMenu.completa:
        await _abrirCompleta(c);
      case null:
        break;
    }
  }

  Future<void> _reanudar(CamaraEnCasa c) async {
    try {
      await ref.read(camarasRepositorioProvider).reanudar(c.camara.id);
      _celdas[c.camara.id]?.problema = null;
      ref.invalidate(camarasProvider);
    } on ProblemaApi catch (e) {
      ref
          .read(avisoFlotanteProvider.notifier)
          .mostrar(
            AvisoFlotante(
              titulo: e.detalle,
              icono: Ico.warn,
              tono: TonoAviso.error,
            ),
          );
    }
  }

  void _ponerVertical(bool vertical) {
    unawaited(
      ref.read(preferenciasVivoProvider.notifier).elegirVertical(vertical),
    );
    setState(() {
      _ordenando = false;
      _completa = null;
    });
    if (vertical) {
      _orientacion.liberar();
    } else {
      _orientacion.horizontal();
    }
    _sincronizar();
  }

  /// Leaving: every session ends and one access is confirmed with the rooms seen (CA-41.6).
  void _terminar() {
    if (_cerrada) return;
    _cerrada = true;
    for (final id in _celdas.keys.toList()) {
      _cerrarCelda(id);
    }
    _orientacion.liberar();
    final vistas = _vistas.values.where((h) => h.isNotEmpty).toList();
    if (vistas.isEmpty) return;
    final dura = _contenedor.read(relojProvider)().difference(_abiertaEn);
    _contenedor
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            titulo: 'Acceso registrado',
            texto: 'Viste ${enumerar(vistas)} · ${duracion(dura)}.',
            icono: Ico.eye,
          ),
        );
  }

  @override
  void dispose() {
    _ciclo.dispose();
    _terminar();
    for (final celda in _celdas.values) {
      celda.conexion
        ..removeListener(_alCambiar)
        ..dispose();
    }
    super.dispose();
  }

  /// Back closes the full screen or «Ordenar» first.
  bool _atras() {
    if (_completa != null && !_vertical) {
      _volverATodas();
      return true;
    }
    if (_ordenando) {
      setState(() {
        _ordenando = false;
        _elegida = null;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final lista = ref.watch(camarasEnCasaProvider).value;
    final vertical = ref.watch(preferenciasVivoProvider).mosaicoVertical;
    // The cells keep the state the family sees; the screen follows it as it changes.
    if (lista != null && !identical(lista, _camaras)) {
      _camaras = lista;
      if (_pagina >= _paginas) _pagina = _paginas - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sincronizar();
      });
    }
    final modo = ref.watch(preferenciasVivoProvider).modo ?? ModoVista.video;
    final orden = ref.watch(ordenCamarasProvider);
    final adulto = ref.watch(hogarProvider).value?.adultoMayor;
    final contenido = lista == null || !_preferenciasLeidas
        ? const ColoredBox(
            color: Colores.noche,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
        : vertical
        ? _vistaVertical(context, modo, orden)
        : _vistaHorizontal(context, modo, orden, adulto?.nombrePila ?? '', () {
            ref.read(llamarProvider)(adulto?.telefono);
          });
    return RefrescoPcs(
      child: PopScope(
        canPop: _ordenando == false && (_completa == null || vertical),
        onPopInvokedWithResult: (salio, _) {
          if (salio) {
            _terminar();
          } else {
            _atras();
          }
        },
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () {
              if (!_atras()) Navigator.of(context).maybePop();
            },
            const SingleActivator(LogicalKeyboardKey.pageDown): () =>
                _irAPagina(_pagina + 1),
            const SingleActivator(LogicalKeyboardKey.pageUp): () =>
                _irAPagina(_pagina - 1),
          },
          child: Focus(autofocus: true, child: contenido),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- landscape

  Widget _vistaHorizontal(
    BuildContext context,
    ModoVista modo,
    OrdenCamaras orden,
    String nombre,
    VoidCallback llamar,
  ) {
    final completa = _completa == null
        ? null
        : _camaras.where((c) => c.camara.id == _completa).firstOrNull;
    final Widget cuerpo = completa != null
        ? _completaHorizontal(context, completa, modo, nombre, llamar)
        : Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                  child: _rejilla(context, orden, horizontal: true),
                ),
              ),
              _barraHorizontal(context, modo),
            ],
          );
    return Scaffold(
      backgroundColor: const Color(0xFF0E0B14),
      body: LayoutBuilder(
        builder: (context, limites) {
          // A portrait window (the web, or the phone before it turns): the content turns instead.
          final girar = limites.maxHeight > limites.maxWidth;
          final contenido = SafeArea(
            child: Semantics(
              explicitChildNodes: true,
              label: completa != null
                  ? 'En vivo · ${completa.habitacion}'
                  : _paginas > 1
                  ? 'Todas en vivo, página ${_pagina + 1} de $_paginas'
                  : 'Todas en vivo',
              child: cuerpo,
            ),
          );
          return girar
              ? RotatedBox(quarterTurns: 1, child: contenido)
              : contenido;
        },
      ),
    );
  }

  bool _iconosSolos(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(16) > 22;

  Widget _barraHorizontal(
    BuildContext context,
    ModoVista modo,
  ) => LayoutBuilder(
    builder: (context, limites) => _barra(
      context,
      modo,
      // Names under the icons need about 860 dp with the pager (the prototype's 844 dp
      // phone minus its margins fits them at this size); below that, icons with their names
      // for screen readers.
      solo:
          _iconosSolos(context) ||
          limites.maxWidth < (_paginas > 1 ? 860 : 700),
    ),
  );

  Widget _barra(BuildContext context, ModoVista modo, {required bool solo}) {
    final elegida = _camaras.where((c) => c.camara.id == _elegida).firstOrNull;
    final orden = ref.read(ordenCamarasProvider);
    final hijos = _ordenando
        ? <Widget>[
            _BotonBarra(
              icono: Ico.check,
              texto: 'Listo',
              claro: true,
              soloIcono: solo,
              alTocar: () => setState(() {
                _ordenando = false;
                _elegida = null;
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text.rich(
                  elegida == null
                      ? const TextSpan(text: 'Elige una cámara para moverla')
                      : TextSpan(
                          children: [
                            const TextSpan(text: 'Arrastra o mueve '),
                            TextSpan(
                              text: elegida.habitacion,
                              style: estiloTexto(15, 800, color: Colors.white),
                            ),
                          ],
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: estiloTexto(15, 400, color: Colors.white),
                ),
              ),
            ),
            _BotonBarra(
              icono: Ico.chevL,
              texto: 'Mover antes',
              soloIcono: solo,
              alTocar:
                  elegida != null &&
                      orden.puedeMover(_ids, elegida.camara.id, -1)
                  ? () => _mover(elegida.camara.id, -1, avisar: false)
                  : null,
            ),
            _BotonBarra(
              icono: Ico.chevR,
              texto: 'Mover después',
              soloIcono: solo,
              alTocar:
                  elegida != null &&
                      orden.puedeMover(_ids, elegida.camara.id, 1)
                  ? () => _mover(elegida.camara.id, 1, avisar: false)
                  : null,
            ),
          ]
        : <Widget>[
            _BotonBarra(
              icono: Ico.x,
              texto: 'Cerrar',
              soloIcono: true,
              alTocar: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 6),
            ModosVista(
              modo: modo,
              expandir: false,
              soloIconos: solo,
              alCambiar: _cambiarModo,
            ),
            const Spacer(),
            if (_paginas > 1) _Paginador(this),
            const Spacer(),
            const AyudaInfo(
              texto: textoPrivacidadMosaico,
              tema: 'privacidad',
              sobreOscuro: true,
              arriba: true,
            ),
            _BotonBarra(
              icono: Ico.swap,
              texto: 'Ordenar',
              soloIcono: solo,
              alTocar: () => setState(() => _ordenando = true),
            ),
            _BotonBarra(
              icono: Ico.portrait,
              texto: 'Vertical',
              soloIcono: solo,
              alTocar: () => _ponerVertical(true),
            ),
          ];
    return Semantics(
      container: true,
      label: _ordenando ? 'Ordenar las cámaras' : 'Controles de Ver todas',
      child: SizedBox(
        height: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: hijos),
        ),
      ),
    );
  }

  Widget _completaHorizontal(
    BuildContext context,
    CamaraEnCasa c,
    ModoVista modo,
    String nombre,
    VoidCallback llamar,
  ) {
    final celda = _celdas[c.camara.id];
    final disponible =
        c.vivoDisponible && celda?.problema == null && celda?.cortadaEn == null;
    return LayoutBuilder(
      builder: (context, limites) {
        // Names next to the icons need about 800 dp; below, icons named for screen readers.
        final solo = _iconosSolos(context) || limites.maxWidth < 800;
        return _completaConBarra(
          context,
          c,
          modo,
          nombre,
          llamar,
          celda,
          disponible,
          solo,
        );
      },
    );
  }

  Widget _completaConBarra(
    BuildContext context,
    CamaraEnCasa c,
    ModoVista modo,
    String nombre,
    VoidCallback llamar,
    _Celda? celda,
    bool disponible,
    bool solo,
  ) {
    final reproductor = celda?.conexion.reproductorEnVivo;
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (disponible)
                ColoredBox(
                  color: Colores.nocheRaya,
                  child: reproductor == null
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Semantics(
                          image: true,
                          label: 'En vivo · ${c.habitacion}',
                          child: reproductor.vista(),
                        ),
                )
              else
                _NoDisponible(camara: c, celda: celda, grande: true),
              if (disponible)
                Positioned(
                  top: 10,
                  left: 10,
                  child: _Etiqueta(
                    texto: c.habitacion,
                    segundos: celda?.sesion == null
                        ? null
                        : celda!.conexion.segundos,
                  ),
                ),
              if (disponible)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: AyudaInfo(
                    texto: textoPrivacidadMosaico,
                    tema: 'privacidad',
                    sobreOscuro: true,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _BotonBarra(
                  icono: Ico.grid,
                  texto: 'Volver a todas',
                  soloIcono: solo,
                  alTocar: _volverATodas,
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: disponible
                          ? ModosVista(
                              modo: modo,
                              expandir: false,
                              soloIconos: solo,
                              alCambiar: _cambiarModo,
                            )
                          : Text(
                              c.habitacion,
                              style: estiloTexto(17, 800, color: Colors.white),
                            ),
                    ),
                  ),
                ),
                if (c.estado == EstadoVisible.enPausa)
                  _BotonBarra(
                    icono: Ico.refresh,
                    texto: 'Reanudar',
                    soloIcono: solo,
                    alTocar: () => _reanudar(c),
                  ),
                _BotonBarra(
                  icono: Ico.phone,
                  texto: 'Llamar a $nombre',
                  claro: true,
                  soloIcono: solo,
                  alTocar: llamar,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- portrait

  Widget _vistaVertical(
    BuildContext context,
    ModoVista modo,
    OrdenCamaras orden,
  ) => Scaffold(
    backgroundColor: Colores.noche,
    appBar: AppBar(
      backgroundColor: Colores.noche,
      foregroundColor: Colors.white,
      leading: IconButton(
        tooltip: 'Cerrar Ver todas',
        icon: const Icono(Ico.x, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'Todas en vivo',
        style: estiloTexto(20, 700, color: Colors.white),
      ),
      actions: [
        const AyudaInfo(
          texto: textoPrivacidadMosaico,
          tema: 'privacidad',
          sobreOscuro: true,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Ver en horizontal',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x1FFFFFFF),
              minimumSize: const Size(48, 48),
            ),
            icon: const Icono(Ico.landscape, color: Colors.white),
            onPressed: () => _ponerVertical(false),
          ),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        ModosVista(modo: modo, alCambiar: _cambiarModo),
        const SizedBox(height: 16),
        _rejilla(context, orden, horizontal: false),
        if (_paginas > 1) ...[
          const SizedBox(height: 12),
          Center(child: _Paginador(this, corto: true)),
        ],
      ],
    ),
  );

  // ---------------------------------------------------------------- grid

  Widget _rejilla(
    BuildContext context,
    OrdenCamaras orden, {
    required bool horizontal,
  }) {
    final camaras = _dePagina(_pagina);
    // Empty slots only keep the grid's shape when there are pages; no «+» (cameras are added in
    // Cámaras › PC).
    final huecos = horizontal || _paginas > 1
        ? camarasPorPagina - camaras.length
        : 0;
    final celdas = [
      for (final c in camaras)
        _celdaArrastrable(
          context,
          c,
          favorita: orden.esFavorita(c.camara.id),
          horizontal: horizontal,
        ),
      for (var i = 0; i < huecos; i++)
        _Hueco(key: ValueKey('hueco-$i'), rayado: !horizontal),
    ];
    Widget fila(List<Widget> dos) => Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: dos.isNotEmpty ? dos[0] : const SizedBox()),
        SizedBox(width: horizontal ? 3 : 10),
        Expanded(child: dos.length > 1 ? dos[1] : const SizedBox()),
      ],
    );
    final grid = horizontal
        ? Column(
            children: [
              Expanded(child: fila(celdas.take(2).toList())),
              const SizedBox(height: 3),
              Expanded(child: fila(celdas.skip(2).take(2).toList())),
            ],
          )
        : Column(
            children: [
              for (var i = 0; i < celdas.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 10),
                IntrinsicHeight(child: fila(celdas.skip(i).take(2).toList())),
              ],
            ],
          );
    // Swiping changes the page (CA-41.2).
    return GestureDetector(
      onHorizontalDragEnd: _paginas < 2
          ? null
          : (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -200) _irAPagina(_pagina + 1);
              if (v > 200) _irAPagina(_pagina - 1);
            },
      child: grid,
    );
  }

  Widget _celdaArrastrable(
    BuildContext context,
    CamaraEnCasa c, {
    required bool favorita,
    required bool horizontal,
  }) {
    final id = c.camara.id;
    final celda = _CeldaMosaico(
      camara: c,
      celda: _celdas[id],
      favorita: favorita,
      horizontal: horizontal,
      seleccionada: _elegida == id,
      ordenando: _ordenando,
      alTocar: () {
        if (_ordenando) {
          setState(() => _elegida = id);
        } else {
          unawaited(_abrirCompleta(c));
        }
      },
      alMantener: _ordenando ? null : () => _menu(c),
    );
    final destino = DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data != id,
      onAcceptWithDetails: (d) => _soltar(d.data, id),
      builder: (context, candidatas, _) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(horizontal ? 6 : 16),
          border: candidatas.isNotEmpty
              ? Border.all(color: Colores.coral, width: 2.5)
              : null,
        ),
        child: celda,
      ),
    );
    Widget arrastre(Widget hijo) => Opacity(opacity: .5, child: hijo);
    final retroalimentacion = SizedBox(
      width: 160,
      height: 100,
      child: Material(
        color: Colors.transparent,
        child: _CeldaMosaico(
          camara: c,
          celda: null,
          favorita: favorita,
          horizontal: true,
          seleccionada: true,
          ordenando: true,
          alTocar: () {},
          alMantener: null,
        ),
      ),
    );
    // With «Ordenar» it drags at once; otherwise after holding it (450 ms). Releasing a held cell
    // without moving it opens «Mover antes», «Mover después», the star and full screen.
    if (_ordenando) {
      return Draggable<String>(
        data: id,
        feedback: retroalimentacion,
        childWhenDragging: arrastre(destino),
        onDragStarted: () => setState(() => _elegida = id),
        child: destino,
      );
    }
    return LongPressDraggable<String>(
      data: id,
      delay: const Duration(milliseconds: 450),
      feedback: retroalimentacion,
      childWhenDragging: arrastre(destino),
      hapticFeedbackOnStart: true,
      onDragStarted: () => _arrastreMovido = false,
      onDragUpdate: (d) {
        if (d.delta.distance > 0) _arrastreMovido = true;
      },
      onDragEnd: (d) {
        if (!d.wasAccepted && !_arrastreMovido) unawaited(_menu(c));
      },
      child: destino,
    );
  }
}

/// «‹ 01/02 ›» (`mosPager`): the ends are disabled; the page number is a status for screen readers.
class _Paginador extends StatelessWidget {
  const _Paginador(this.estado, {this.corto = false});

  final _PantallaMosaicoState estado;

  /// «‹ 1/2 ›» under the portrait grid.
  final bool corto;

  @override
  Widget build(BuildContext context) {
    final p = estado._pagina;
    final n = estado._paginas;
    String dos(int x) => corto ? '$x' : x.toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BotonBarra(
          icono: Ico.chevL,
          texto: 'Página anterior',
          soloIcono: true,
          alTocar: p == 0 ? null : () => estado._irAPagina(p - 1),
        ),
        Semantics(
          container: true,
          liveRegion: true,
          label: 'Página ${p + 1} de $n',
          excludeSemantics: true,
          child: Text(
            '${dos(p + 1)}/${dos(n)}',
            style: estiloMono(tamano: 16, color: Colors.white),
          ),
        ),
        _BotonBarra(
          icono: Ico.chevR,
          texto: 'Página siguiente',
          soloIcono: true,
          alTocar: p == n - 1 ? null : () => estado._irAPagina(p + 1),
        ),
      ],
    );
  }
}

/// A button of the dark bar (`mlBtn`): 48 dp, icon and name (the name only for screen readers when
/// [soloIcono]); [claro] is the white pill («Listo», «Llamar a Rosa»).
class _BotonBarra extends StatelessWidget {
  const _BotonBarra({
    required this.icono,
    required this.texto,
    required this.alTocar,
    this.soloIcono = false,
    this.claro = false,
  });

  final Ico icono;
  final String texto;
  final VoidCallback? alTocar;
  final bool soloIcono;
  final bool claro;

  @override
  Widget build(BuildContext context) {
    final activo = alTocar != null;
    final color = claro
        ? const Color(0xFF221A38)
        : activo
        ? Colors.white
        : const Color(0x73FFFFFF);
    return Semantics(
      button: true,
      enabled: activo,
      label: texto,
      excludeSemantics: true,
      onTap: alTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: claro ? Colors.white : Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: alTocar,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: soloIcono ? 12 : 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icono(icono, tamano: 22, color: color),
                    if (!soloIcono) ...[
                      const SizedBox(width: 6),
                      Text(texto, style: estiloTexto(15, 700, color: color)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// «● EN VIVO» (and the room and the time in full screen).
class _Etiqueta extends StatelessWidget {
  const _Etiqueta({this.texto, this.segundos});

  final String? texto;
  final int? segundos;

  @override
  Widget build(BuildContext context) {
    final s = segundos;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colores.nocheEtiqueta,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (texto != null) ...[
            Text(texto!, style: estiloTexto(15, 800, color: Colors.white)),
            const SizedBox(width: 8),
          ],
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colores.grabando,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: s == null ? 'EN VIVO' : 'EN VIVO · '),
                if (s != null)
                  TextSpan(
                    text:
                        '${(s ~/ 60).toString().padLeft(2, '0')}:'
                        '${(s % 60).toString().padLeft(2, '0')}',
                    style: estiloCifras,
                  ),
              ],
            ),
            style: estiloTexto(13, 800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// One camera of the grid (`mosTile`): its live image with «● EN VIVO» and its name (with the star
/// when it is a favourite), or the striped block with the reason when it cannot stream (CA-41.5).
class _CeldaMosaico extends StatelessWidget {
  const _CeldaMosaico({
    required this.camara,
    required this.celda,
    required this.favorita,
    required this.horizontal,
    required this.seleccionada,
    required this.ordenando,
    required this.alTocar,
    required this.alMantener,
  });

  final CamaraEnCasa camara;
  final _Celda? celda;
  final bool favorita;
  final bool horizontal;
  final bool seleccionada;
  final bool ordenando;
  final VoidCallback alTocar;

  /// Holding a cell without dragging it (the menu); the drag itself is the parent's.
  final VoidCallback? alMantener;

  bool get _disponible =>
      camara.vivoDisponible &&
      celda?.problema == null &&
      celda?.cortadaEn == null;

  @override
  Widget build(BuildContext context) {
    final reproductor = celda?.conexion.reproductorEnVivo;
    final escala = MediaQuery.textScalerOf(context).scale(16) / 16;
    final estado = _disponible
        ? 'en vivo'
        : _estadoDe(camara, celda).toLowerCase();
    final radio = BorderRadius.circular(horizontal ? 6 : 16);
    final nombre = Row(
      children: [
        Flexible(
          child: Text(
            camara.habitacion,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: estiloTexto(16, 800, color: Colors.white),
          ),
        ),
        if (favorita) ...[
          const SizedBox(width: 6),
          const EstrellaFavorita(tamano: 16),
        ],
      ],
    );
    final imagen = _disponible
        ? ColoredBox(
            color: Colores.nocheRaya,
            child: reproductor == null
                ? const SizedBox.expand()
                : reproductor.vista(),
          )
        : _NoDisponible(camara: camara, celda: celda, grande: false);
    final contenido = horizontal
        ? Stack(
            fit: StackFit.expand,
            children: [
              imagen,
              if (_disponible)
                const Positioned(top: 8, right: 8, child: _Etiqueta()),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 18 * escala, 10, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xB3000000)],
                    ),
                  ),
                  child: nombre,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imagen,
                    if (_disponible)
                      const Positioned(top: 8, left: 8, child: _Etiqueta()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: nombre,
              ),
            ],
          );
    return Semantics(
      button: true,
      selected: ordenando ? seleccionada : null,
      label:
          '${camara.habitacion}, $estado. '
          '${ordenando ? 'Elegir para mover' : 'Abrir en pantalla completa'}',
      hint: ordenando
          ? 'Arrástrala o usa Mover antes y Mover después'
          : 'Mantén presionado para moverla',
      excludeSemantics: true,
      onTap: alTocar,
      onLongPress: alMantener,
      child: Material(
        color: horizontal ? Colors.black : const Color(0xFF221B2E),
        borderRadius: radio,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alTocar,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: radio,
              border: seleccionada
                  ? Border.all(color: const Color(0xFF8EB4FF), width: 2.5)
                  : context.colores.contraste
                  ? Border.all(color: const Color(0xB3FFFFFF), width: 1.5)
                  : null,
            ),
            child: contenido,
          ),
        ),
      ),
    );
  }
}

/// «Desconectada», «En pausa», «Sin conexión» or «Detenida».
String _estadoDe(CamaraEnCasa c, _Celda? celda) {
  if (celda?.cortadaEn != null) return EstadoVisible.desconectada.texto;
  return switch (celda?.problema?.codigo) {
    'CAMARA_EN_PAUSA' => EstadoVisible.enPausa.texto,
    'CAMARA_DESCONECTADA' => EstadoVisible.desconectada.texto,
    'SIN_CONSENTIMIENTO' => EstadoVisible.detenida.texto,
    _ => c.estado.texto,
  };
}

/// The striped block of a camera that cannot stream, with its icon, state and reason.
class _NoDisponible extends StatelessWidget {
  const _NoDisponible({
    required this.camara,
    required this.celda,
    required this.grande,
  });

  final CamaraEnCasa camara;
  final _Celda? celda;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final cortada = celda?.cortadaEn;
    final estado = _estadoDe(camara, celda);
    final motivo = cortada != null
        ? 'Desde las ${hora(cortada)}'
        : celda?.problema != null && camara.vivoDisponible
        ? celda!.problema!.detalle
        : porQueNoEnMosaico(camara);
    final (icono, color) = switch (estado) {
      'En pausa' => (Ico.pause, Colores.nochePausa),
      'Detenida' => (Ico.lock, Colores.nochePausa),
      'Sin conexión' => (Ico.pc, Colores.nochePausa),
      _ => (Ico.wifiOff, Colores.nocheAviso),
    };
    return CustomPaint(
      painter: const _Rayas(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icono(icono, tamano: grande ? 40 : 26, color: color),
                const SizedBox(height: 6),
                Text(
                  estado,
                  style: estiloTexto(
                    grande ? 22 : 17,
                    800,
                    color: Colors.white,
                  ),
                ),
                if (motivo.isNotEmpty)
                  Text(
                    motivo,
                    textAlign: TextAlign.center,
                    style: estiloTexto(
                      grande ? 16 : 14,
                      400,
                      color: Colores.nocheTexto,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An empty slot of the grid: plain dark in landscape, striped in portrait.
class _Hueco extends StatelessWidget {
  const _Hueco({super.key, required this.rayado});

  final bool rayado;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(rayado ? 16 : 6),
      child: rayado
          ? const AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(painter: _Rayas()),
            )
          : const ColoredBox(color: Color(0xFF17121F)),
    ),
  );
}

class _Rayas extends CustomPainter {
  const _Rayas();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colores.nocheRaya);
    final raya = Paint()
      ..color = Colores.nocheRaya2
      ..strokeWidth = 10;
    for (var x = -size.height; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), raya);
    }
  }

  @override
  bool shouldRepaint(_Rayas oldDelegate) => false;
}

enum _OpcionMenu { antes, despues, favorita, completa }

/// What to do with a held camera (`O.mosMenu`): its four options in 2 × 2.
class _HojaMover extends StatelessWidget {
  const _HojaMover({
    required this.habitacion,
    required this.favorita,
    required this.antes,
    required this.despues,
  });

  final String habitacion;
  final bool favorita;
  final bool antes;
  final bool despues;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    Widget opcion(Ico icono, String texto, _OpcionMenu? valor) => Semantics(
      button: true,
      enabled: valor != null,
      label: texto,
      excludeSemantics: true,
      onTap: valor == null ? null : () => Navigator.of(context).pop(valor),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: valor == null ? null : () => Navigator.of(context).pop(valor),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.moradoSuave,
                    shape: BoxShape.circle,
                  ),
                  child: Icono(
                    icono,
                    tamano: 22,
                    color: valor == null ? c.tinta3 : c.icono,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: estiloTexto(
                      17,
                      700,
                      color: valor == null ? c.tinta3 : c.tinta,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final opciones = [
      opcion(Ico.chevL, 'Mover antes', antes ? _OpcionMenu.antes : null),
      opcion(Ico.chevR, 'Mover después', despues ? _OpcionMenu.despues : null),
      opcion(
        favorita ? Ico.starOn : Ico.star,
        favorita ? 'Quitar de favoritas' : 'Marcar como favorita',
        _OpcionMenu.favorita,
      ),
      opcion(Ico.expand, 'Ver en pantalla completa', _OpcionMenu.completa),
    ];
    final ancho = MediaQuery.sizeOf(context).width > 520;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              habitacion,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          if (ancho)
            for (var i = 0; i < opciones.length; i += 2)
              Row(
                children: [
                  Expanded(child: opciones[i]),
                  Expanded(child: opciones[i + 1]),
                ],
              )
          else
            ...opciones,
        ],
      ),
    );
  }
}

/// Opens «Ver todas» (US-41): from «Cámaras» and the room picker.
void verTodas(BuildContext context) => context.push(Rutas.verTodas);
