import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../data/cliente_whep.dart';
import 'reproductor_vivo.dart';

/// Longest wait for the browser or the phone to gather its own (host) candidates before the offer
/// is sent anyway: without STUN or TURN servers this takes a few milliseconds, and MediaMTX also
/// learns the viewer's address from its first connectivity check.
const _esperaCandidatos = Duration(seconds: 1);

/// How often the receiver's statistics are read to see whether frames keep arriving.
const _sondeo = Duration(milliseconds: 250);

/// Longest the peer connection stays open waiting for the WHEP `DELETE` to be answered.
const _esperaBorrado = Duration(seconds: 2);

/// No new frame for this long counts as a stalled stream.
const _sinFotogramas = Duration(milliseconds: 1500);

/// The live stream over WebRTC, read from MediaMTX with WHEP: `flutter_webrtc` on Android and iOS
/// (libwebrtc) and on the web (the browser's own `RTCPeerConnection`, through `dart_webrtc`).
///
/// Receive only, video only (the camera has no audio), so the phone's audio session is never
/// touched. No ICE servers: MediaMTX offers host candidates on its public address, UDP and TCP
/// 8189 (`webrtcAdditionalHosts`, `webrtcLocalUDPAddress`, `webrtcLocalTCPAddress`), and the viewer
/// always starts the connectivity checks. The offer is sent once its own candidates are gathered,
/// and MediaMTX's answer carries all of its own, so no trickle (`PATCH`) is needed.
///
/// [listo] and [detenido] come from the receiver's statistics (`framesDecoded`), which work the
/// same on every platform; on the web the renderer only measures the video once its view is shown.
class ReproductorWebrtc extends ChangeNotifier implements ReproductorVivo {
  ReproductorWebrtc(this._endpoint, {this._token, ClienteWhep? cliente})
    : _cliente = cliente ?? ClienteWhep();

  final Uri _endpoint;
  final String? _token;
  final ClienteWhep _cliente;
  final _renderizador = RTCVideoRenderer();

  RTCPeerConnection? _conexion;

  /// A stream created here for a track that arrived without one; MediaMTX's tracks come with one.
  MediaStream? _flujoPropio;
  Uri? _recurso;
  Timer? _medicion;
  bool _renderizadorListo = false;
  bool _desechado = false;

  bool _listo = false;
  bool _cortado = false;
  int _fotogramas = 0;
  final _desdeUltimoFotograma = Stopwatch();
  double _relacionMedida = 0;

  @override
  Future<void> iniciar() async {
    await _renderizador.initialize();
    _renderizadorListo = true;
    if (_desechado) return _liberar();
    final conexion = _conexion = await createPeerConnection({
      'iceServers': <Map<String, dynamic>>[],
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
    });
    if (_desechado) return _liberar();
    final reunidos = Completer<void>();
    conexion
      ..onIceGatheringState = (estado) {
        if (estado == RTCIceGatheringState.RTCIceGatheringStateComplete &&
            !reunidos.isCompleted) {
          reunidos.complete();
        }
      }
      ..onConnectionState = (estado) {
        if (estado == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            estado == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          _cortar();
        }
      }
      ..onTrack = _alRecibirPista;
    await conexion.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );
    final oferta = await conexion.createOffer();
    await conexion.setLocalDescription(oferta);
    await reunidos.future.timeout(_esperaCandidatos, onTimeout: () {});
    if (_desechado) return _liberar();
    final local = await conexion.getLocalDescription() ?? oferta;
    final respuesta = await _cliente.ofrecer(
      _endpoint,
      local.sdp!,
      token: _token,
    );
    _recurso = respuesta.recurso;
    if (_desechado) return _liberar();
    await conexion.setRemoteDescription(
      RTCSessionDescription(respuesta.sdp, 'answer'),
    );
    if (_desechado) return _liberar();
    _medicion = Timer.periodic(_sondeo, (_) => unawaited(_medir()));
  }

  Future<void> _alRecibirPista(RTCTrackEvent evento) async {
    if (evento.track.kind != 'video' || _desechado) return;
    var flujo = evento.streams.firstOrNull;
    if (flujo == null) {
      flujo = _flujoPropio = await createLocalMediaStream('vivo');
      await flujo.addTrack(evento.track);
    }
    evento.track.onEnded = _cortar;
    if (!_desechado) _renderizador.srcObject = flujo;
  }

  /// Reads `framesDecoded` and the frame size of the incoming video.
  Future<void> _medir() async {
    final conexion = _conexion;
    if (conexion == null || _desechado) return;
    final List<StatsReport> informes;
    try {
      informes = await conexion.getStats();
    } on Object {
      return;
    }
    if (_desechado) return;
    for (final informe in informes) {
      final v = informe.values;
      if (informe.type != 'inbound-rtp' ||
          (v['kind'] ?? v['mediaType']) != 'video') {
        continue;
      }
      final fotogramas = _numero(v['framesDecoded'])?.toInt() ?? 0;
      final ancho = _numero(v['frameWidth']) ?? 0;
      final alto = _numero(v['frameHeight']) ?? 0;
      if (ancho > 0 && alto > 0) _relacionMedida = ancho / alto;
      if (fotogramas > _fotogramas) {
        _fotogramas = fotogramas;
        _desdeUltimoFotograma
          ..reset()
          ..start();
        if (!_listo) {
          _listo = true;
          notifyListeners();
        }
      }
    }
  }

  static num? _numero(Object? valor) =>
      valor is num ? valor : num.tryParse('${valor ?? ''}');

  void _cortar() {
    if (_cortado || _desechado) return;
    _cortado = true;
    notifyListeners();
  }

  @override
  bool get listo => _listo && !_cortado;

  @override
  bool get cortado => _cortado;

  @override
  bool get detenido =>
      !_listo || _desdeUltimoFotograma.elapsed > _sinFotogramas;

  @override
  double get relacionAspecto {
    // The renderer knows the rotation of a phone's frames; on the web it measures only once shown.
    final valor = _renderizador.value;
    if (valor.width > 0 && valor.height > 0) return valor.aspectRatio;
    return _relacionMedida;
  }

  @override
  Widget vista() => RTCVideoView(
    _renderizador,
    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
  );

  /// Closes the peer connection and the WHEP session; safe to call more than once.
  void _liberar() {
    _medicion?.cancel();
    _medicion = null;
    final conexion = _conexion;
    _conexion = null;
    final recurso = _recurso;
    _recurso = null;
    if (conexion != null) {
      conexion
        ..onConnectionState = null
        ..onIceGatheringState = null
        ..onTrack = null;
      // The WHEP DELETE first, so MediaMTX ends the session cleanly; closing the peer connection
      // before it arrives would leave the DELETE nothing to delete.
      final borrado = recurso == null
          ? Future<void>.value()
          : _cliente.cerrar(recurso).timeout(_esperaBorrado, onTimeout: () {});
      unawaited(
        borrado
            .then((_) => conexion.close())
            .then((_) => conexion.dispose())
            .catchError((Object _) {}),
      );
    } else if (recurso != null) {
      unawaited(_cliente.cerrar(recurso));
    }
    final flujo = _flujoPropio;
    _flujoPropio = null;
    if (flujo != null) unawaited(flujo.dispose().catchError((Object _) {}));
    if (_renderizadorListo) {
      _renderizadorListo = false;
      _renderizador.srcObject = null;
      unawaited(_renderizador.dispose().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    _desechado = true;
    _liberar();
    super.dispose();
  }
}

/// Creates the WebRTC player for a session's WHEP endpoint and viewer token.
typedef FabricaReproductorWebrtc =
    ReproductorVivo Function(Uri endpoint, String? token);

final fabricaReproductorWebrtcProvider = Provider<FabricaReproductorWebrtc>(
  (ref) =>
      (endpoint, token) => ReproductorWebrtc(endpoint, token: token),
);
