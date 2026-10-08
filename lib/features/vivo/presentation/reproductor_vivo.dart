import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// Playback of the camera's live stream, replaceable in tests (`video_player` needs the platform).
abstract interface class ReproductorVivo implements Listenable {
  /// Loads the playlist and starts playing; throws when the stream cannot be opened.
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

/// LL-HLS through `video_player`: AVPlayer on iOS, ExoPlayer on Android.
class ReproductorHls extends ChangeNotifier implements ReproductorVivo {
  ReproductorHls(Uri url)
    : _video = VideoPlayerController.networkUrl(
        url,
        formatHint: VideoFormat.hls,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      ) {
    _video.addListener(notifyListeners);
  }

  final VideoPlayerController _video;

  @override
  Future<void> iniciar() async {
    await _video.initialize();
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
    _video.removeListener(notifyListeners);
    _video.dispose();
    super.dispose();
  }
}

typedef FabricaReproductorVivo = ReproductorVivo Function(Uri url);

final fabricaReproductorVivoProvider = Provider<FabricaReproductorVivo>(
  (ref) => ReproductorHls.new,
);
