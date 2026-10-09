import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// Playback of the camera's live stream, replaceable in tests (`video_player` needs the platform).
abstract interface class ReproductorVivo implements Listenable {
  /// Loads the playlist and starts playing; throws when the stream cannot be opened. It may also
  /// never complete, so the caller bounds it.
  Future<void> iniciar();

  /// The first frame is ready to show.
  bool get listo;

  /// Playback failed (a live stream has no end; stalls are reported by [detenido]).
  bool get cortado;

  /// The player is waiting for data or not playing: true for as long as the stream is stalled.
  bool get detenido;

  /// Width / height of the frames: the whole frame is shown, never cropped.
  double get relacionAspecto;

  Widget vista();

  void dispose();
}

/// The playlist is not served yet: MediaMTX answers `404` until the camera publishes.
class ListaNoDisponible implements Exception {
  const ListaNoDisponible(this.estado);

  final int? estado;

  @override
  String toString() => 'ListaNoDisponible($estado)';
}

/// Throws [ListaNoDisponible] unless the playlist at [url] answers `2xx`.
///
/// Only an HTTP answer counts: when the request itself fails (no connection, a timeout, or a browser
/// origin that MediaMTX does not allow for CORS) the player is tried anyway, as it was before.
Future<void> comprobarLista(Dio dio, Uri url) async {
  final Response<String> respuesta;
  try {
    respuesta = await dio.getUri<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );
  } on DioException {
    return;
  }
  final estado = respuesta.statusCode;
  if (estado == null || estado < 200 || estado > 299) {
    throw ListaNoDisponible(estado);
  }
}

final _sonda = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ),
);

/// LL-HLS through `video_player`: AVPlayer on iOS, ExoPlayer on Android, the browser's own HLS or
/// hls.js on the web (`video_player_web_hls`).
class ReproductorHls extends ChangeNotifier implements ReproductorVivo {
  ReproductorHls(this._url, {Dio? dio})
    : _dio = dio ?? _sonda,
      _video = VideoPlayerController.networkUrl(
        _url,
        formatHint: VideoFormat.hls,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      ) {
    _video.addListener(notifyListeners);
  }

  final Uri _url;
  final Dio _dio;
  final VideoPlayerController _video;
  bool _desechado = false;

  @override
  Future<void> iniciar() async {
    // Until the camera publishes, the playlist answers 404. The platform player is only created once
    // it is served: on the web, `video_player_web_hls` 1.3.0 swallows hls.js's fatal error for a 404
    // playlist, so `initialize` would never complete, and its `dispose` leaves hls.js loading.
    await comprobarLista(_dio, _url);
    if (_desechado) return;
    await _video.initialize();
    if (_desechado) return;
    // The stream has no audio; muting keeps other apps' sound untouched.
    await _video.setVolume(0);
    await _video.play();
  }

  @override
  bool get listo => _video.value.isInitialized && !_video.value.hasError;

  // A live stream never ends: on iOS `video_player` reports a 1 ms duration for live HLS and
  // flags `isCompleted` as soon as the position passes it, so only an error counts as a cut. For
  // the same reason the position does not advance, so a stall is read from buffering instead.
  @override
  bool get cortado => _video.value.hasError;

  @override
  bool get detenido => _video.value.isBuffering || !_video.value.isPlaying;

  @override
  double get relacionAspecto => _video.value.aspectRatio;

  @override
  Widget vista() => VideoPlayer(_video);

  @override
  void dispose() {
    _desechado = true;
    _video.removeListener(notifyListeners);
    _video.dispose();
    super.dispose();
  }
}

typedef FabricaReproductorVivo = ReproductorVivo Function(Uri url);

final fabricaReproductorVivoProvider = Provider<FabricaReproductorVivo>(
  (ref) => ReproductorHls.new,
);
