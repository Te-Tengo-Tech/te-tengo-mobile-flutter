import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/cliente_whep.dart';
import '../domain/vista_en_vivo.dart';
import 'reproductor_vivo.dart';
import 'reproductor_webrtc.dart';

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

/// Plays one live view session (contract §4): over WebRTC (WHEP) first when the session offers it,
/// and over LL-HLS when WebRTC fails, is slow to answer, shows no first frame or stalls. Until the
/// camera publishes, the stream does not exist yet, so a start that fails is retried until
/// [esperaPrimerFotograma] runs out. The live view and the webcam preview (US-29) both use it.
///
/// It only plays: opening and closing the session (`POST`/`DELETE`) is the screen's job, which
/// [alPerder] tells when the stream failed, stalled or never started.
class ConexionVivo extends ChangeNotifier {
  ConexionVivo({
    required this.fabricaHls,
    required this.fabricaWebrtc,
    required this.alPerder,
  });

  final FabricaReproductorVivo fabricaHls;
  final FabricaReproductorWebrtc fabricaWebrtc;
  final VoidCallback alPerder;

  SesionVivo? _sesion;
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
  int _segundos = 0;
  Timer? _reloj;
  Timer? _reintento;
  bool _desechada = false;

  /// The player once its first frame arrived.
  ReproductorVivo? get reproductorEnVivo => _enVivo ? _reproductor : null;

  bool get enVivo => _enVivo;

  /// Seconds since [conectar].
  int get segundos => _segundos;

  /// Starts playing [sesion] (any session played before is dropped).
  void conectar(SesionVivo sesion) {
    detener();
    _sesion = sesion;
    _segundos = 0;
    _enVivo = false;
    _esperando = 0;
    _sinAvance = 0;
    _soloHls = false;
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) => _cadaSegundo());
    unawaited(_conectar(sesion));
    notifyListeners();
  }

  /// Stops playing; the session itself is closed by the screen.
  void detener() {
    _reloj?.cancel();
    _reloj = null;
    _reintento?.cancel();
    _reintento = null;
    _soltarReproductor();
    _sesion = null;
  }

  /// Plays the session's stream: over WebRTC when the session offers it, else LL-HLS. A start that
  /// fails, or hangs for [esperaInicio], is retried with a new player.
  Future<void> _conectar(SesionVivo sesion) async {
    final whep = sesion.urlWebrtc;
    if (whep != null && !_soloHls) return _conectarWebrtc(sesion, whep);
    final reproductor = fabricaHls(sesion.urlTransmision);
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
  /// every [pausaEntreOfertas], for up to [esperaPublicacionWebrtc]. Any other failure, an answer
  /// slower than [esperaWebrtc] or no first frame within [esperaWebrtc] of the answer switches the
  /// session to LL-HLS.
  Future<void> _conectarWebrtc(SesionVivo sesion, Uri whep) async {
    final reproductor = fabricaWebrtc(whep, sesion.tokenEspectador);
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
    if (_desechada || _reproductor != reproductor || reproductor.listo) return;
    _plazoWebrtc = Timer(esperaWebrtc, () {
      if (_reproductor == reproductor && !reproductor.listo) {
        _pasarAHls(reproductor);
      }
    });
  }

  /// WebRTC did not start or broke off: the same session goes on over LL-HLS.
  void _pasarAHls(ReproductorVivo reproductor) {
    final sesion = _sesion;
    if (_desechada || _reproductor != reproductor || sesion == null) return;
    // Lost mid-stream: LL-HLS gets esperaRescateHls for its own first frame.
    if (_enVivo) {
      _esperando = esperaPrimerFotograma.inSeconds - esperaRescateHls.inSeconds;
    }
    _soloHls = true;
    _sinAvance = 0;
    _soltarReproductor();
    notifyListeners();
    unawaited(_conectar(sesion));
  }

  void _reintentar(
    ReproductorVivo reproductor, {
    Duration pausa = pausaEntreIntentos,
  }) {
    final sesion = _sesion;
    if (_desechada || _reproductor != reproductor || sesion == null) return;
    _soltarReproductor();
    _reintento = Timer(pausa, () {
      if (!_desechada && _sesion == sesion) unawaited(_conectar(sesion));
    });
  }

  void _alCambiarReproductor() {
    final r = _reproductor;
    if (r == null || _desechada) return;
    if (r.cortado) {
      if (_porWebrtc) return _pasarAHls(r);
      return _enVivo ? _perder() : _reintentar(r);
    }
    _enVivo = _enVivo || r.listo;
    notifyListeners();
  }

  /// The clock, and the watchdog for a stream that never starts or stalls.
  void _cadaSegundo() {
    if (_sesion == null) return;
    _segundos++;
    notifyListeners();
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

  /// The stream failed, stalled or never started.
  void _perder() {
    if (_sesion == null) return;
    detener();
    alPerder();
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

  @override
  void dispose() {
    _desechada = true;
    detener();
    super.dispose();
  }
}
