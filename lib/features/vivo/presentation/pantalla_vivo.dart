import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/tema/colores.dart';
import '../../../app/tema/tema.dart';
import '../../../core/dispositivo/llamada.dart';
import '../../../core/formato.dart';
import '../../../core/red/problema_api.dart';
import '../../../core/reloj.dart';
import '../../../core/ui/avisos_flotantes.dart';
import '../../../core/ui/botones.dart';
import '../../../core/ui/chips.dart';
import '../../../core/ui/iconos.dart';
import '../../alertas/data/alertas_repositorio.dart';
import '../../camaras/data/camaras_repositorio.dart';
import '../../camaras/domain/camara.dart';
import '../../hogar/data/hogar_repositorio.dart';
import '../data/cliente_whep.dart';
import '../data/vista_en_vivo_repositorio.dart';
import '../domain/vista_en_vivo.dart';
import 'reproductor_vivo.dart';
import 'reproductor_webrtc.dart';

/// Why the live view cannot open (`liveState`): CA-23.3, CA-23.4 and, without consent, CA-05.2.
enum _NoDisponible { desconectada, enPausa, detenida }

/// Live view (screens 38–40, 54 and 74): the room in real time, how long it has been open, and the
/// reminder that the access is recorded. From an alert it shows that alert's room (CA-23.2).
class PantallaVivo extends ConsumerStatefulWidget {
  const PantallaVivo({super.key, this.camaraId, this.alertaId});

  final String? camaraId;
  final String? alertaId;

  @override
  ConsumerState<PantallaVivo> createState() => _PantallaVivoState();
}

/// Waiting longer than this for the first frame counts as a lost stream [implementation choice].
const esperaPrimerFotograma = Duration(seconds: 20);

/// A stream whose position stops advancing this long is lost [implementation choice].
const esperaSinImagen = Duration(seconds: 10);

/// Pause between attempts to open the playlist while the camera starts publishing.
const pausaEntreIntentos = Duration(seconds: 2);

/// Longest one attempt to start the player may take before it is dropped and another one starts
/// [implementation choice].
const esperaInicio = Duration(seconds: 6);

/// Longest WebRTC may take to answer the offer, and then to show its first frame, before the view
/// plays LL-HLS instead [implementation choice].
const esperaWebrtc = Duration(seconds: 4);

/// Pause between WHEP offers while the camera starts publishing (MediaMTX answers `404`).
const pausaEntreOfertas = Duration(milliseconds: 500);

/// Longest the WHEP offer is sent again while MediaMTX answers `404`, counted from the session's
/// start; then LL-HLS gets the rest of [esperaPrimerFotograma], so a WebRTC route that always
/// answers `404` (e.g. a proxy without it) costs a few seconds, not the live view
/// [implementation choice].
const esperaPublicacionWebrtc = Duration(seconds: 8);

/// After WebRTC broke off mid-stream, how long LL-HLS has to show a frame before the stream counts
/// as lost: enough for LL-HLS to start on a stream that is still published, without keeping a
/// viewer waiting the whole [esperaPrimerFotograma] when the camera stopped (paused, consent
/// revoked, PC off) [implementation choice].
const esperaRescateHls = Duration(seconds: 10);

/// A WebRTC stream without new frames this long is replaced by LL-HLS [implementation choice].
const esperaSinImagenWebrtc = Duration(seconds: 3);

class _PantallaVivoState extends ConsumerState<PantallaVivo> {
  Camara? _camara;
  SesionVivo? _sesion;
  DateTime? _inicio;
  _NoDisponible? _noDisponible;
  DateTime? _pausadaHasta;
  ProblemaApi? _problema;

  /// When the stream was lost; the view offers to open a new session.
  DateTime? _cortadaEn;

  /// What the stream shows, and the mode chosen here, sent when a new session opens.
  ModoVista _modo = ModoVista.video;
  ModoVista? _modoElegido;
  bool _cambiandoModo = false;

  /// Seconds of the current session, and of the sessions already closed on this screen.
  int _segundos = 0;
  int _segundosVistos = 0;
  bool _huboSesion = false;

  ReproductorVivo? _reproductor;

  /// The current player is WebRTC (WHEP); otherwise LL-HLS.
  bool _porWebrtc = false;

  /// WebRTC failed in this session: it plays LL-HLS until it ends.
  bool _soloHls = false;

  /// Runs out when WebRTC answered but no frame came within [esperaWebrtc].
  Timer? _plazoWebrtc;

  /// The first frame of the current session arrived.
  bool _enVivo = false;
  int _esperando = 0;
  int _sinAvance = 0;
  Timer? _reloj;
  Timer? _reintento;

  /// Bumped to drop an opening in flight (the screen closed or went to the background).
  int _intento = 0;
  bool _oculta = false;
  bool _abrirAlVolver = false;

  late final VistaEnVivoRepositorio _repositorio;
  late final ProviderContainer _contenedor;
  late final AppLifecycleListener _ciclo;

  bool get _desdeAlerta => widget.alertaId != null;

  @override
  void initState() {
    super.initState();
    _repositorio = ref.read(vistaEnVivoRepositorioProvider);
    // The DELETE may finish after the widget is gone: refresh the log through the container.
    _contenedor = ProviderScope.containerOf(context, listen: false);
    _ciclo = AppLifecycleListener(onHide: _alOcultar, onShow: _alMostrar);
    unawaited(_abrir());
  }

  Future<void> _abrir() async {
    final intento = ++_intento;
    bool vigente() => mounted && intento == _intento;
    setState(() {
      _problema = null;
      _noDisponible = null;
      _cortadaEn = null;
    });
    try {
      final hogar = await ref.read(hogarProvider.future);
      final camaras = await ref.read(camarasProvider.future);
      var camaraId = widget.camaraId;
      if (camaraId == null && widget.alertaId != null) {
        camaraId = (await ref.read(
          alertaProvider(widget.alertaId!).future,
        )).camaraId;
      }
      final camara =
          camaras.where((c) => c.id == camaraId).firstOrNull ??
          camaras.firstOrNull;
      if (!vigente() || camara == null) return;
      setState(() {
        _camara = camara;
        _pausadaHasta = camara.pausadaHasta;
      });
      final noDisponible = switch (camara.estadoVisible(
        conConsentimiento: hogar.conConsentimiento,
      )) {
        EstadoVisible.detenida => _NoDisponible.detenida,
        EstadoVisible.desconectada => _NoDisponible.desconectada,
        EstadoVisible.enPausa => _NoDisponible.enPausa,
        _ => null,
      };
      if (noDisponible != null) {
        return setState(() => _noDisponible = noDisponible);
      }
      final sesion = await _repositorio.abrir(
        camara.id,
        alertaId: widget.alertaId,
        modo: _modoElegido,
      );
      if (!vigente()) return _cerrarSesion(sesion);
      setState(() {
        _sesion = sesion;
        _huboSesion = true;
        _modo = sesion.modo;
        _inicio = ref.read(relojProvider)();
        _segundos = 0;
        _enVivo = false;
        _esperando = 0;
        _sinAvance = 0;
        _soloHls = false;
      });
      _reloj = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _cadaSegundo(),
      );
      unawaited(_conectar(sesion));
    } on ProblemaApi catch (e) {
      if (!vigente()) return;
      setState(() {
        switch (e.codigo) {
          case 'CAMARA_DESCONECTADA':
            _noDisponible = _NoDisponible.desconectada;
          case 'CAMARA_EN_PAUSA':
            _noDisponible = _NoDisponible.enPausa;
            _pausadaHasta =
                fechaDesdeJson(e.extras['pausadaHasta']) ?? _pausadaHasta;
          case 'SIN_CONSENTIMIENTO':
            // The consent was revoked after the household was loaded (CA-05.2): the camera does
            // not stream, and the rest of the app learns it from a fresh household.
            _noDisponible = _NoDisponible.detenida;
            ref
              ..invalidate(hogarProvider)
              ..invalidate(camarasProvider);
          default:
            _problema = e;
        }
      });
    }
  }

  /// Plays the session's stream: over WebRTC when the session offers it, else LL-HLS. Until the
  /// camera publishes, the stream does not exist yet, so a start that fails, or hangs for
  /// [esperaInicio], is retried with a new player until [esperaPrimerFotograma] runs out.
  Future<void> _conectar(SesionVivo sesion) async {
    final whep = sesion.urlWebrtc;
    if (whep != null && !_soloHls) return _conectarWebrtc(sesion, whep);
    final reproductor = ref.read(fabricaReproductorVivoProvider)(
      sesion.urlTransmision,
    );
    _reproductor = reproductor;
    reproductor.addListener(_alCambiarReproductor);
    try {
      await reproductor.iniciar().timeout(esperaInicio);
    } on TimeoutException {
      // Slow to finish, but already showing the stream: keep it.
      if (!reproductor.listo) _reintentar(reproductor);
    } on Object {
      _reintentar(reproductor);
    }
  }

  /// WebRTC first: MediaMTX answers `404` until the camera publishes, so the offer is sent again
  /// every [pausaEntreOfertas], for up to [esperaPublicacionWebrtc]. Any other failure, an answer slower than [esperaWebrtc] or no first
  /// frame within [esperaWebrtc] of the answer switches the session to LL-HLS.
  Future<void> _conectarWebrtc(SesionVivo sesion, Uri whep) async {
    final reproductor = ref.read(fabricaReproductorWebrtcProvider)(
      whep,
      sesion.tokenEspectador,
    );
    _reproductor = reproductor;
    _porWebrtc = true;
    reproductor.addListener(_alCambiarReproductor);
    try {
      await reproductor.iniciar().timeout(esperaWebrtc);
    } on OfertaRechazada catch (e) {
      return e.sinTransmision && _esperando < esperaPublicacionWebrtc.inSeconds
          ? _reintentar(reproductor, pausa: pausaEntreOfertas)
          : _pasarAHls(reproductor);
    } on Object {
      // A timeout, no connection, a CORS or SDP error: LL-HLS may still work.
      if (!reproductor.listo) _pasarAHls(reproductor);
      return;
    }
    if (!mounted || _reproductor != reproductor || reproductor.listo) return;
    _plazoWebrtc = Timer(esperaWebrtc, () {
      if (_reproductor == reproductor && !reproductor.listo) {
        _pasarAHls(reproductor);
      }
    });
  }

  /// WebRTC did not start or broke off: the same session goes on over LL-HLS.
  void _pasarAHls(ReproductorVivo reproductor) {
    final sesion = _sesion;
    if (!mounted || _reproductor != reproductor || sesion == null) return;
    // Lost mid-stream: LL-HLS gets esperaRescateHls for its own first frame.
    if (_enVivo) {
      _esperando = esperaPrimerFotograma.inSeconds - esperaRescateHls.inSeconds;
    }
    _soloHls = true;
    _sinAvance = 0;
    _soltarReproductor();
    setState(() {});
    unawaited(_conectar(sesion));
  }

  void _reintentar(
    ReproductorVivo reproductor, {
    Duration pausa = pausaEntreIntentos,
  }) {
    final sesion = _sesion;
    if (!mounted || _reproductor != reproductor || sesion == null) return;
    _soltarReproductor();
    _reintento = Timer(pausa, () {
      if (mounted && _sesion == sesion) unawaited(_conectar(sesion));
    });
  }

  void _alCambiarReproductor() {
    final r = _reproductor;
    if (r == null || !mounted) return;
    if (r.cortado) {
      if (_porWebrtc) return _pasarAHls(r);
      return _enVivo ? _perder() : _reintentar(r);
    }
    setState(() => _enVivo = _enVivo || r.listo);
  }

  /// The «EN VIVO» clock, and the watchdog for a stream that never starts or stalls.
  void _cadaSegundo() {
    if (_sesion == null) return;
    setState(() => _segundos++);
    final r = _reproductor;
    if (!_enVivo || r == null) {
      if (++_esperando >= esperaPrimerFotograma.inSeconds) _perder();
      return;
    }
    if (r.detenido) {
      if (_porWebrtc) {
        if (++_sinAvance >= esperaSinImagenWebrtc.inSeconds) _pasarAHls(r);
      } else if (++_sinAvance >= esperaSinImagen.inSeconds) {
        _perder();
      }
    } else {
      _sinAvance = 0;
    }
  }

  /// The stream failed, stalled or never started: the session ends and the view offers a new one.
  void _perder() {
    if (_sesion == null) return;
    _detener();
    setState(() {
      _noDisponible = _NoDisponible.desconectada;
      _cortadaEn = ref.read(relojProvider)();
    });
  }

  void _soltarReproductor() {
    final r = _reproductor;
    _reproductor = null;
    _enVivo = false;
    _porWebrtc = false;
    _plazoWebrtc?.cancel();
    _plazoWebrtc = null;
    if (r == null) return;
    r.removeListener(_alCambiarReproductor);
    // It may be the one notifying right now: dispose it once the notification is over.
    scheduleMicrotask(r.dispose);
  }

  /// Stops playback and ends the session, which records the access (CA-24.1).
  void _detener() {
    _reloj?.cancel();
    _reloj = null;
    _reintento?.cancel();
    _reintento = null;
    _soltarReproductor();
    final sesion = _sesion;
    _sesion = null;
    if (sesion == null) return;
    _segundosVistos += _segundos;
    _segundos = 0;
    _cerrarSesion(sesion);
  }

  void _cerrarSesion(SesionVivo sesion) => unawaited(
    _repositorio
        .cerrar(sesion.sesionId)
        .then((_) => _contenedor.invalidate(accesosVivoProvider))
        .catchError((Object _) {}),
  );

  /// Nobody watches an app in the background: end the session, and open a new one on return.
  void _alOcultar() {
    if (_oculta) return;
    _oculta = true;
    _abrirAlVolver =
        _noDisponible == null && _problema == null && _camara != null;
    _intento++;
    _detener();
    setState(() {});
  }

  void _alMostrar() {
    if (!_oculta) return;
    _oculta = false;
    if (_abrirAlVolver) unawaited(_abrir());
  }

  /// Leaving the screen: end the session and confirm the access was recorded.
  void _terminar() {
    _intento++;
    _detener();
    if (!_huboSesion) return;
    final habitacion = _camara?.nombreHabitacion ?? '';
    ref
        .read(avisoFlotanteProvider.notifier)
        .mostrar(
          AvisoFlotante(
            titulo: 'Acceso registrado',
            texto:
                'Viste ${conArticulo(habitacion)} en vivo durante '
                '${duracion(Duration(seconds: _segundosVistos))}.',
            icono: Ico.eye,
          ),
        );
  }

  Future<void> _cambiarModo(ModoVista modo) async {
    final sesion = _sesion;
    if (sesion == null || modo == _modo) return;
    setState(() {
      _cambiandoModo = true;
      _problema = null;
    });
    try {
      final nuevo = await _repositorio.cambiarModo(sesion.sesionId, modo);
      if (mounted) {
        setState(() {
          _modo = nuevo;
          _modoElegido = nuevo;
        });
      }
    } on ProblemaApi catch (e) {
      if (mounted) setState(() => _problema = e);
    } finally {
      if (mounted) setState(() => _cambiandoModo = false);
    }
  }

  Future<void> _reanudar() async {
    final camara = _camara;
    if (camara == null) return;
    try {
      await ref.read(camarasRepositorioProvider).reanudar(camara.id);
      ref.invalidate(camarasProvider);
      await _abrir();
    } on ProblemaApi catch (e) {
      if (mounted) setState(() => _problema = e);
    }
  }

  @override
  void dispose() {
    _ciclo.dispose();
    // Left without popping (e.g. replaced): still end the session.
    _intento++;
    _detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitacion = _camara?.nombreHabitacion ?? '';
    final adulto = ref.watch(hogarProvider).value?.adultoMayor;
    final nombre = adulto?.nombrePila ?? '';
    final cerrar = _desdeAlerta
        ? 'Volver a la alerta'
        : 'Cerrar la vista en vivo';
    final viendo = _sesion != null;
    return PopScope(
      onPopInvokedWithResult: (_, _) => _terminar(),
      child: Scaffold(
        backgroundColor: Colores.noche,
        appBar: AppBar(
          backgroundColor: Colores.noche,
          foregroundColor: Colors.white,
          leading: IconButton(
            tooltip: cerrar,
            icon: Icono(_desdeAlerta ? Ico.back : Ico.x, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            habitacion.isEmpty ? 'En vivo' : 'En vivo · $habitacion',
            style: estiloTexto(20, 700, color: Colors.white),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            if (_noDisponible case final motivo?)
              _NoDisponibleVista(
                motivo: motivo,
                habitacion: habitacion,
                nombre: nombre,
                desdeAlerta: _desdeAlerta,
                ultimaSenal: _cortadaEn ?? _camara?.ultimaSenal,
                pausadaHasta: _pausadaHasta,
                ahora: ref.watch(relojProvider)(),
              )
            else
              _Imagen(
                reproductor: _enVivo ? _reproductor : null,
                segundos: viendo ? _segundos : null,
                habitacion: habitacion,
              ),
            if (_problema != null) ...[
              const SizedBox(height: 16),
              Text(
                _problema!.detalle,
                style: estiloTexto(16, 400, color: Colores.nocheTexto),
              ),
            ],
            if (viendo) ...[
              const SizedBox(height: 16),
              _Modos(
                modo: _modo,
                alElegir: _cambiandoModo ? null : _cambiarModo,
              ),
              const SizedBox(height: 16),
              Text(
                queSeVe(
                  _modo,
                  habitacion: habitacion,
                  nombre: nombre,
                  desdeAlerta: _desdeAlerta,
                ),
                style: estiloTexto(16, 400, color: Colores.nocheTexto),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icono(Ico.eye, tamano: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'No se graba. Tu acceso desde las ',
                          ),
                          TextSpan(
                            text: hora(_inicio!),
                            style: const TextStyle(fontFamily: fuenteMono),
                          ),
                          const TextSpan(
                            text: ' queda en el registro de la familia.',
                          ),
                        ],
                      ),
                      style: estiloTexto(16, 400, color: Colores.nocheTexto),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (_cortadaEn != null) ...[
              Boton(
                'Ver en vivo',
                icono: Ico.refresh,
                estilo: EstiloBoton.blanco,
                colorTexto: Colores.tinta,
                alPresionar: _abrir,
              ),
              const SizedBox(height: 12),
            ],
            if (viendo || _desdeAlerta) ...[
              Boton(
                'Llamar a $nombre',
                icono: Ico.phone,
                estilo: EstiloBoton.blanco,
                colorTexto: Colores.tinta,
                alPresionar: () => ref.read(llamarProvider)(adulto?.telefono),
              ),
              const SizedBox(height: 12),
            ],
            if (_noDisponible == _NoDisponible.enPausa) ...[
              Boton(
                'Reanudar la cámara ahora',
                icono: Ico.refresh,
                estilo: EstiloBoton.blanco,
                colorTexto: Colores.tinta,
                alPresionar: _reanudar,
              ),
              const SizedBox(height: 12),
            ],
            Boton(
              cerrar,
              estilo: EstiloBoton.sobreRojo,
              alPresionar: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the viewer sees in each mode, worded from the prototype's «Ves la Sala y la postura de
/// Rosa en este momento» (see docs/BLOCKERS.md).
String queSeVe(
  ModoVista modo, {
  required String habitacion,
  required String nombre,
  required bool desdeAlerta,
}) {
  final que = switch (modo) {
    ModoVista.video =>
      desdeAlerta
          ? 'Ves la habitación.'
          : 'Ves ${conArticulo(habitacion)} en este momento.',
    ModoVista.videoConPostura =>
      desdeAlerta
          ? 'Ves la habitación y la postura detectada.'
          : 'Ves ${conArticulo(habitacion)} y la postura de $nombre en este '
                'momento.',
    ModoVista.soloPostura =>
      desdeAlerta
          ? 'Ves la postura detectada.'
          : 'Ves la postura de $nombre en este momento.',
  };
  // «No se graba» is said once, next to the access record below the image.
  return que;
}

/// The three modes of the stream as chips; the chosen one is filled and checked.
class _Modos extends StatelessWidget {
  const _Modos({required this.modo, required this.alElegir});

  final ModoVista modo;

  /// Null while a change is on its way.
  final ValueChanged<ModoVista>? alElegir;

  static const _textos = {
    ModoVista.video: 'Video',
    ModoVista.videoConPostura: 'Video y postura',
    ModoVista.soloPostura: 'Solo postura',
  };

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final m in ModoVista.values)
        ChipOpcion(
          texto: _textos[m]!,
          elegido: m == modo,
          icono: m == modo ? Ico.check : null,
          alTocar: alElegir == null ? null : () => alElegir!(m),
        ),
    ],
  );
}

/// The live frame, whole at its own aspect ratio, with the «EN VIVO · mm:ss» tag.
class _Imagen extends StatelessWidget {
  const _Imagen({
    required this.reproductor,
    required this.segundos,
    required this.habitacion,
  });

  /// Set once the first frame arrived.
  final ReproductorVivo? reproductor;
  final int? segundos;
  final String habitacion;

  @override
  Widget build(BuildContext context) {
    final r = reproductor;
    final s = segundos;
    final relacion = r == null || r.relacionAspecto <= 0
        ? 3 / 4
        : r.relacionAspecto;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: relacion,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colores.nocheRaya,
              child: r == null
                  ? const Center(
                      child: Icono(
                        Ico.video,
                        tamano: 40,
                        color: Colores.nocheTexto,
                      ),
                    )
                  : Semantics(
                      image: true,
                      label: 'En vivo · $habitacion',
                      child: r.vista(),
                    ),
            ),
            if (s != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.nocheEtiqueta,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Colores.grabando,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'EN VIVO · '),
                            TextSpan(
                              text: minutosSegundos(s),
                              style: const TextStyle(fontFamily: fuenteMono),
                            ),
                          ],
                        ),
                        style: estiloTexto(13, 700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// «00:37».
String minutosSegundos(int segundos) =>
    '${(segundos ~/ 60).toString().padLeft(2, '0')}:'
    '${(segundos % 60).toString().padLeft(2, '0')}';

/// Striped box of an unavailable live view (screens 39 and 40).
class _NoDisponibleVista extends StatelessWidget {
  const _NoDisponibleVista({
    required this.motivo,
    required this.habitacion,
    required this.nombre,
    required this.desdeAlerta,
    required this.ultimaSenal,
    required this.pausadaHasta,
    required this.ahora,
  });

  final _NoDisponible motivo;
  final String habitacion;
  final String nombre;
  final bool desdeAlerta;
  final DateTime? ultimaSenal;
  final DateTime? pausadaHasta;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: fuenteMono);
    final (icono, color, titulo, texto) = switch (motivo) {
      _NoDisponible.desconectada => (
        Ico.wifiOff,
        Colores.nocheAviso,
        'La cámara ${deHabitacion(habitacion)} no está disponible',
        TextSpan(
          children: [
            if (ultimaSenal case final s?) ...[
              const TextSpan(text: 'Sin conexión desde las '),
              TextSpan(text: hora(s), style: mono),
              const TextSpan(text: '. '),
            ],
            TextSpan(
              text: desdeAlerta
                  ? 'Llama a $nombre o pide a alguien cercano que vaya a verla.'
                  : 'Revisa el cable, la PC y el internet de la casa.',
            ),
          ],
        ),
      ),
      _NoDisponible.enPausa => (
        Ico.pause,
        Colores.nochePausa,
        'La vista en vivo no está disponible',
        TextSpan(
          children: [
            if (pausadaHasta case final p?) ...[
              const TextSpan(text: 'En pausa hasta las '),
              TextSpan(text: finDePausa(p, ahora), style: mono),
              const TextSpan(text: ', o hasta que la reanudes.'),
            ] else
              TextSpan(
                text: 'La cámara ${deHabitacion(habitacion)} está en pausa.',
              ),
          ],
        ),
      ),
      _NoDisponible.detenida => (
        Ico.lock,
        Colores.nochePausa,
        'La cámara está detenida',
        TextSpan(text: 'Sin el consentimiento de $nombre no hay video.'),
      ),
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colores.linea2, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: CustomPaint(
            painter: const _Rayas(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icono(icono, tamano: 40, color: color),
                  const SizedBox(height: 12),
                  Semantics(
                    header: true,
                    child: Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: estiloTexto(22, 700, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    texto,
                    textAlign: TextAlign.center,
                    style: estiloTexto(16, 400, color: Colores.nocheTexto),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
