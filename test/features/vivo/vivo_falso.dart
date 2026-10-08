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
  ProblemaApi? errorAbrir;
  ProblemaApi? errorCambiar;

  /// The mode the camera streams in, answered by the POST.
  ModoVista modo = ModoVista.video;
  List<AccesoVivo> lista = [];

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
  ReproductorVivoFalso(this.url, {required this.conImagen, this.falla});

  final Uri url;

  /// The first frame arrives as soon as playback starts.
  final bool conImagen;

  /// `iniciar` throws it, like a playlist the camera is not publishing yet.
  final Object? falla;

  bool _listo = false;
  bool _cortado = false;
  bool desechado = false;

  /// While false the position advances on every read, like a live stream.
  bool congelado = false;
  var _posicion = Duration.zero;

  @override
  Future<void> iniciar() async {
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
  Duration get posicion {
    if (!congelado) _posicion += const Duration(seconds: 1);
    return _posicion;
  }

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

  /// Whether new players show a frame as soon as they start.
  bool conImagen = true;

  /// How many of the next players fail to start.
  int fallasAlIniciar = 0;

  ReproductorVivoFalso get ultimo => creados.last;

  ReproductorVivo crear(Uri url) {
    final falla = fallasAlIniciar > 0 ? StateError('404') : null;
    if (fallasAlIniciar > 0) fallasAlIniciar--;
    final r = ReproductorVivoFalso(url, conImagen: conImagen, falla: falla);
    creados.add(r);
    return r;
  }
}
