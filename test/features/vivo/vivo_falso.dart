import 'dart:async';
import 'dart:typed_data';

import 'package:te_tengo/core/red/problema_api.dart';
import 'package:te_tengo/features/vivo/data/vista_en_vivo_repositorio.dart';
import 'package:te_tengo/features/vivo/domain/vista_en_vivo.dart';

class VistaEnVivoRepositorioFalso implements VistaEnVivoRepositorio {
  final abiertas = <(String, String?)>[];
  final cerradas = <String>[];
  ProblemaApi? errorAbrir;
  List<AccesoVivo> lista = [];

  @override
  Future<SesionVivo> abrir(String camaraId, {String? alertaId}) async {
    abiertas.add((camaraId, alertaId));
    if (errorAbrir != null) throw errorAbrir!;
    return SesionVivo(
      sesionId: 'v-${abiertas.length}',
      urlTransmision: Uri.parse('wss://api.tetengo.pe/vivo/v-1'),
    );
  }

  @override
  Future<void> cerrar(String sesionId) async => cerradas.add(sesionId);

  @override
  Future<List<AccesoVivo>> accesos() async => lista;
}

/// Frames pushed by the test.
class TransmisionFalsa {
  final urls = <Uri>[];
  final _fotogramas = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> abrir(Uri url) {
    urls.add(url);
    return _fotogramas.stream;
  }
}
