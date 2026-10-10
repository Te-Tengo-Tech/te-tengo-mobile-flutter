import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:te_tengo/features/alertas/presentation/reproductor.dart';

/// Video controller without the platform plugin. Time only moves with [avanzar].
class ClipFalso extends ChangeNotifier implements ControladorClip {
  ClipFalso(
    this.url, {
    this.duracionReal = const Duration(seconds: 12),
    this.falloAlIniciar = false,
    this.cuelga = false,
    this.nativa = false,
  });

  final String url;

  /// What the player reports once initialized; zero for a clip whose duration is not known.
  Duration duracionReal;
  bool falloAlIniciar;

  /// `iniciar()` never completes, as `video_player_web_hls` after an expired URL.
  bool cuelga;

  /// Web without the Fullscreen API: the video element's own full screen works.
  bool nativa;

  bool _listo = false;
  bool _reproduciendo = false;
  bool _fallo = false;
  bool dispuesto = false;
  Duration _posicion = Duration.zero;
  final buscadas = <Duration>[];
  int pantallasNativas = 0;

  @override
  Future<void> iniciar() async {
    if (cuelga) return Completer<void>().future;
    if (falloAlIniciar) {
      _fallo = true;
      notifyListeners();
      throw StateError('No se pudo abrir $url');
    }
    _listo = true;
    notifyListeners();
  }

  @override
  Future<void> reproducir() async {
    _reproduciendo = true;
    notifyListeners();
  }

  @override
  Future<void> pausar() async {
    _reproduciendo = false;
    notifyListeners();
  }

  @override
  Future<void> buscar(Duration posicion) async {
    buscadas.add(posicion);
    _posicion = posicion < Duration.zero
        ? Duration.zero
        : duracionReal > Duration.zero && posicion > duracionReal
        ? duracionReal
        : posicion;
    notifyListeners();
  }

  /// Plays on for [tiempo]; at the end it stops, as `video_player` does.
  void avanzar(Duration tiempo) {
    if (!_reproduciendo) return;
    _posicion += tiempo;
    if (duracionReal > Duration.zero && _posicion >= duracionReal) {
      _posicion = duracionReal;
      _reproduciendo = false;
    }
    notifyListeners();
  }

  /// Moves the playing position without a seek (time passing in a long test).
  void moverA(Duration posicion) {
    _posicion = posicion;
    notifyListeners();
  }

  /// The player breaks, as with an expired URL (`video_player` resets its value).
  void fallar() {
    _fallo = true;
    _listo = false;
    _reproduciendo = false;
    _posicion = Duration.zero;
    notifyListeners();
  }

  @override
  bool get listo => _listo;

  @override
  bool get reproduciendo => _reproduciendo;

  @override
  bool get fallo => _fallo;

  @override
  Duration get posicion => _posicion;

  @override
  Duration get duracion => _listo ? duracionReal : Duration.zero;

  @override
  Widget vista() => SizedBox(key: ValueKey(url), width: 320, height: 200);

  @override
  bool pantallaCompletaNativa() {
    pantallasNativas++;
    return nativa;
  }

  @override
  void dispose() {
    dispuesto = true;
    super.dispose();
  }
}

/// Creates [ClipFalso]s and keeps them, newest last.
class FabricaClipFalsa {
  FabricaClipFalsa({
    this.duracion = const Duration(seconds: 12),
    this.nativa = false,
  });

  Duration duracion;
  bool nativa;

  /// URLs whose player fails to open.
  final fallanAlIniciar = <String>{};

  /// URLs whose player never finishes opening.
  final cuelgan = <String>{};
  final creados = <ClipFalso>[];

  ClipFalso get ultimo => creados.last;

  ControladorClip crear(String url) {
    final clip = ClipFalso(
      url,
      duracionReal: duracion,
      falloAlIniciar: fallanAlIniciar.contains(url),
      cuelga: cuelgan.contains(url),
      nativa: nativa,
    );
    creados.add(clip);
    return clip;
  }
}
