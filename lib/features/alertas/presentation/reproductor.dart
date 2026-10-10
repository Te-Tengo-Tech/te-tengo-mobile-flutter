import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/web/navegador.dart';

/// Video playback of a clip, replaceable in tests (`video_player` needs the platform).
abstract interface class ControladorClip implements Listenable {
  Future<void> iniciar();

  Future<void> reproducir();

  Future<void> pausar();

  /// Moves to [posicion]; the player clamps it to the clip.
  Future<void> buscar(Duration posicion);

  bool get listo;
  bool get reproduciendo;

  /// The player failed (e.g. the pre-signed URL expired and the storage answered `403`). A failed
  /// player does not recover: it must be replaced by a new one.
  bool get fallo;
  Duration get posicion;

  /// Zero while the player does not know it.
  Duration get duracion;

  Widget vista();

  /// Web without the Fullscreen API (Safari on iPhone): shows the `<video>` element in the system's
  /// full-screen player. False when that is not possible either.
  bool pantallaCompletaNativa();

  void dispose();
}

class ControladorVideo extends ChangeNotifier implements ControladorClip {
  ControladorVideo(this._url)
    : _video = VideoPlayerController.networkUrl(Uri.parse(_url)) {
    _video.addListener(notifyListeners);
  }

  final String _url;
  final VideoPlayerController _video;

  @override
  Future<void> iniciar() async {
    await _video.initialize();
    // The clip has no sound (the camera sends none). Muted, a browser lets `play()` run outside a
    // tap, which resuming after a URL refresh needs (MDN, «Autoplay guide for media and Web Audio
    // APIs»).
    if (kIsWeb) await _video.setVolume(0);
  }

  @override
  Future<void> reproducir() async {
    final v = _video.value;
    // Only a known duration says the clip ended; while it is unknown (zero) every position would
    // look like the end and play would always rewind.
    if (v.duration > Duration.zero &&
        (v.isCompleted || v.position >= v.duration)) {
      await _video.seekTo(Duration.zero);
    }
    await _video.play();
  }

  @override
  Future<void> pausar() => _video.pause();

  @override
  Future<void> buscar(Duration posicion) => _video.seekTo(posicion);

  @override
  bool get listo => _video.value.isInitialized;

  @override
  bool get reproduciendo => _video.value.isPlaying;

  @override
  bool get fallo => _video.value.hasError;

  @override
  Duration get posicion => _video.value.position;

  @override
  Duration get duracion => _video.value.duration;

  /// The video at its own size, for a `FittedBox` to scale. An `AspectRatio` here gets unbounded
  /// constraints from the `FittedBox` and fails its layout («RenderAspectRatio has unbounded
  /// constraints»).
  @override
  Widget vista() {
    final tamano = _video.value.size;
    final conocido = tamano.width > 0 && tamano.height > 0;
    return SizedBox(
      width: conocido ? tamano.width : 16,
      height: conocido ? tamano.height : 10,
      child: VideoPlayer(_video),
    );
  }

  @override
  bool pantallaCompletaNativa() => videoAPantallaCompletaNavegador(_url);

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
