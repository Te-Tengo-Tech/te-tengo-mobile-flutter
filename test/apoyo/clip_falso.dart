import 'package:flutter/widgets.dart';
import 'package:te_tengo/features/alertas/presentation/reproductor.dart';

/// Video controller without the platform plugin.
class ClipFalso extends ChangeNotifier implements ControladorClip {
  ClipFalso(this.url);

  final String url;
  bool _listo = false;
  bool _reproduciendo = false;
  Duration _posicion = Duration.zero;

  @override
  Future<void> iniciar() async {
    _listo = true;
    notifyListeners();
  }

  @override
  Future<void> reproducir() async {
    _reproduciendo = true;
    _posicion = const Duration(seconds: 8);
    notifyListeners();
  }

  @override
  Future<void> pausar() async {
    _reproduciendo = false;
    notifyListeners();
  }

  @override
  bool get listo => _listo;

  @override
  bool get reproduciendo => _reproduciendo;

  @override
  Duration get posicion => _posicion;

  @override
  Duration get duracion => const Duration(seconds: 12);

  @override
  Widget vista() => const SizedBox(width: 320, height: 200);
}
