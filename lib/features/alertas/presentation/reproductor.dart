import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// Video playback of a clip, replaceable in tests (`video_player` needs the platform).
abstract interface class ControladorClip implements Listenable {
  Future<void> iniciar();

  Future<void> reproducir();

  Future<void> pausar();

  bool get listo;
  bool get reproduciendo;
  Duration get posicion;
  Duration get duracion;

  Widget vista();

  void dispose();
}

class ControladorVideo extends ChangeNotifier implements ControladorClip {
  ControladorVideo(String url)
    : _video = VideoPlayerController.networkUrl(Uri.parse(url)) {
    _video.addListener(notifyListeners);
  }

  final VideoPlayerController _video;

  @override
  Future<void> iniciar() => _video.initialize();

  @override
  Future<void> reproducir() async {
    if (_video.value.position >= _video.value.duration) {
      await _video.seekTo(Duration.zero);
    }
    await _video.play();
  }

  @override
  Future<void> pausar() => _video.pause();

  @override
  bool get listo => _video.value.isInitialized;

  @override
  bool get reproduciendo => _video.value.isPlaying;

  @override
  Duration get posicion => _video.value.position;

  @override
  Duration get duracion => _video.value.duration;

  @override
  Widget vista() => AspectRatio(
    aspectRatio: _video.value.aspectRatio,
    child: VideoPlayer(_video),
  );

  @override
  void dispose() {
    _video.removeListener(notifyListeners);
    _video.dispose();
    super.dispose();
  }
}

typedef FabricaClip = ControladorClip Function(String url);

final fabricaClipProvider = Provider<FabricaClip>(
  (ref) => ControladorVideo.new,
);
