import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';
import 'package:te_tengo/features/vivo/presentation/reproductor_vivo.dart';

class VistaEnVivoRepositorioFalso implements VistaEnVivoRepositorio {
  final abiertas = <(String, String?)>[];
  final modosPedidos = <ModoVista?>[];
  final cambios = <(String, ModoVista)>[];
  final cerradas = <String>[];
  final preparadas = <String>[];
  ProblemaApi? errorAbrir;
  ProblemaApi? errorCambiar;

  /// The sessions also offer WebRTC (`urlWebrtc`), as an API with `TT_VIVO_URL_WEBRTC` does.
  bool conWebrtc = false;

  /// The mode the camera streams in, answered by the POST.
  ModoVista modo = ModoVista.video;
  List<AccesoVivo> lista = [];

  @override
  Future<void> preparar(String camaraId) async => preparadas.add(camaraId);

  @override
  Future<SesionVivo> abrir(
    String camaraId, {
    String? alertaId,
    ModoVista? modo,
  }) async {
    abiertas.add((camaraId, alertaId));
    modosPedidos.add(modo);
    if (errorAbrir != null) throw errorAbrir!;
    if (modo != null) this.modo = modo;
    final id = 'v-${abiertas.length}';
    return SesionVivo(
      sesionId: id,
      urlTransmision: Uri.parse(
        'https://api.tetengo.pe/vivo/camaras/$camaraId/index.m3u8?token=t-$id',
      ),
      urlWebrtc: conWebrtc
          ? Uri.parse(
              'https://api.tetengo.pe/vivo-webrtc/camaras/$camaraId/whep?token=t-$id',
            )
          : null,
      modo: this.modo,
    );
  }

  @override
  Future<ModoVista> cambiarModo(String sesionId, ModoVista modo) async {
    cambios.add((sesionId, modo));
    if (errorCambiar != null) throw errorCambiar!;
    return this.modo = modo;
  }

  @override
  Future<void> cerrar(String sesionId) async => cerradas.add(sesionId);

  @override
  Future<List<AccesoVivo>> accesos() async => lista;
}

/// A live stream without the platform plugin, driven by the test.
class ReproductorVivoFalso extends ChangeNotifier implements ReproductorVivo {
  ReproductorVivoFalso(
    this.url, {
    required this.conImagen,
    this.falla,
    this.cuelga = false,
  });

  final Uri url;

  /// The first frame arrives as soon as playback starts.
  final bool conImagen;

  /// `iniciar` throws it, like a playlist the camera is not publishing yet.
  final Object? falla;

  /// `iniciar` never completes, like `video_player_web_hls` 1.3.0 on a playlist that answered 404.
  final bool cuelga;

  bool _listo = false;
  bool _cortado = false;
  bool desechado = false;

  /// The stream stalls: the player keeps waiting for data.
  bool congelado = false;

  @override
  Future<void> iniciar() async {
    if (cuelga) return Completer<void>().future;
    if (falla != null) throw falla!;
    if (conImagen) mostrarImagen();
  }

  void mostrarImagen() {
    _listo = true;
    notifyListeners();
  }

  /// A playback error or the end of the stream.
  void cortar() {
    _cortado = true;
    notifyListeners();
  }

  @override
  bool get listo => _listo;

  @override
  bool get cortado => _cortado;

  @override
  bool get detenido => congelado;

  /// A 640 × 480 frame, like the agent's 480p.
  @override
  double get relacionAspecto => 4 / 3;

  @override
  Widget vista() => const SizedBox.expand(key: Key('video-en-vivo'));

  @override
  void dispose() {
    desechado = true;
    super.dispose();
  }
}

/// Creates [ReproductorVivoFalso]s and keeps them for the test.
class FabricaReproductorFalsa {
  final creados = <ReproductorVivoFalso>[];

  /// The viewer token each WebRTC player got.
  final tokens = <String?>[];

  /// Whether new players show a frame as soon as they start.
  bool conImagen = true;

  /// How many of the next players fail to start, and with what.
  int fallasAlIniciar = 0;
  Object Function() falla = () => StateError('404');

  /// How many of the next players never finish starting.
  int cuelguesAlIniciar = 0;

  ReproductorVivoFalso get ultimo => creados.last;

  ReproductorVivo crear(Uri url) {
    final falla = fallasAlIniciar > 0 ? this.falla() : null;
    if (fallasAlIniciar > 0) fallasAlIniciar--;
    final cuelga = cuelguesAlIniciar > 0;
    if (cuelga) cuelguesAlIniciar--;
    final r = ReproductorVivoFalso(
      url,
      conImagen: conImagen,
      falla: falla,
      cuelga: cuelga,
    );
    creados.add(r);
    return r;
  }

  /// A WebRTC (WHEP) player: the same fake, driven the same way.
  ReproductorVivo crearWebrtc(Uri endpoint, String? token) {
    tokens.add(token);
    return crear(endpoint);
  }
}
